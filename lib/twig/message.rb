
class Twig
end

class Twig::Messages
  attr_accessor :client, :inbox, :outbox, :all
  def initialize(client)
    @client = client
  end

  def inbox(action=nil)
    if @inbox
      case action
      when :update
        @inbox = Twig::Messages::Inbox.new(@client)
      when nil
        @inbox
      else
        raise ArgumentError, "#{action} is not a valid argument for @active."
      end
    else
      @inbox = Twig::Messages::Inbox.new(@client)
    end
  end

  def outbox(action=nil)
    if @outbox
      case action
      when :update
        @outbox = Twig::Messages::Outbox.new(@client)
      when nil
        @outbox
      else
        raise ArgumentError, "#{action} is not a valid argument for @active."
      end
    else
      @outbox = Twig::Messages::Outbox.new(@client)
    end
  end

  def in
    inbox.contents
  end

  def out
    outbox.contents
  end
  
  def received
    inbox.contents
  end

  def sent
    outbox.contents
  end

  def all
    inbox.contents + outbox.contents
  end

  def count
    inbox.size + outbox.size
  end

  def size
    count
  end
end

class Twig::Message
  attr_accessor :client, :info
  def initialize(client, info)
    @client = client
    @info = info
  end

  def delete
    @client.message(:delete, @info)
  end

  def reply(text)  
    @client.message(:post, text, @info.sender.id)
  end
end


class Twig::Messages::Box
  attr_accessor :client, :contents, :active
  def initialize(client)
    @client = client
  end

  def contents(action=nil)
    if @contents
      case action
      when :update
        @contents = fill
      when nil
        @contents
      else
        raise ArgumentError, "#{action} is not a valid argument for @contents."
      end
    else
      @contents = fill
    end
  end
  
  def size
    contents.size
  end

  def active(action=nil)
    if @active
      case action
      when :update
        @active = first
      when nil
        @active
      else
        raise ArgumentError, "#{action} is not a valid argument for @active."
      end
    else
      @active = first
    end
  end

  def sort_by(ivar, opts={})

    msg_vars = {
      :id => :@id,
      :created => :@created_at
      }

    user_vars = {
      :screen_name => :@screen_name,
      :id => :@id,
      :name => :@name
    }

    user = self.class == Twig::Messages::Inbox ? :@sender : :@recipient

    page = opts[:page] ? opts[:page] : 1
    page_size = opts[:page_size] ? opts[:page_size] : 10
    dir = opts[:dir] ? opts[:dir] : :desc

    if ! msg_vars[ivar] && ! user_vars[ivar]
      raise ArgumentError, "#{ivar} is not a valid argument for sort_by."
    else
      output = all.sort do |x,y|
        if msg_vars[ivar]
          y.info.instance_variable_get(msg_vars[ivar]) <=> \
            x.info.instance_variable_get(msg_vars[ivar])
        else
          y.info.instance_variable_get(user).instance_variable_get(user_vars[ivar]) <=> \
            x.info.instance_variable_get(user).instance_variable_get(user_vars[ivar])
        end
      end
      
      output.reverse! if dir == :asc
      starts, ends = ((page_size * page) - page_size), (page_size * page)
      
      return output[starts, ends]
    end
  end
  
  def find(opts={})
    id = opts[:id] ? opts[:id] : nil
    screen_name = opts[:screen_name] ? opts[:screen_name] : nil
    activate = opts[:activate] ? opts[:activate] : false

    if id || screen_name
      if id && screen_name
        output = nil
        raise ArgumentError, "Use only screen name OR id # when finding a friend."
      else
        messages = contents
        if id 
          messages.each do |f|
            if f.info.id == id
              output = f
              break
            end
          end
        elsif screen_name
          messages.each do |f|
            if f.info.screen_name == screen_name
              output = f
              break
            end
          end
        end

        if output
          @active = output if activate
        else
          output = nil
          if id
            raise "Couldn't find friend ##{id}"
          else
            raise "Couldn't find friend with screen_name '#{screen_name}'"
          end
        end
      end
    else
      output = nil
      raise ArgumentError, "You must use either an id# or a screen name to find a friend."
    end

    return output
  end

  def activate(arg)
    case arg
    when Fixnum
      find :id => arg, :activate => true
    when String
      find :screen_name => arg, :activate => true
    else
      raise ArgumentError, "#{action} is not a valid argument for @activate."
    end
  end
 
  def first
    contents[0]
  end

  def last
    contents[contents.size - 1]
  end
end

class Twig::Messages::Inbox < Twig::Messages::Box
  def fill
    @client.messages(:received).collect {|m| Twig::Message.new(@client, m) }
  end
end

class Twig::Messages::Outbox < Twig::Messages::Box
  def fill
    @client.messages(:sent).collect {|m| Twig::Message.new(@client, m) }
  end
end


module Twig::Messages::Methods
  attr_reader :message_box
  def messages(action=nil)
    if @messages
      case action
      when :create
        @messages = Twig::Messages.new(@client)
      when :update
        @messages.update
      when nil
        @messages
      else
        raise ArgumentError
      end
    else
      @messages = Twig::Messages.new(@client)
    end
  end

  def inbox
    messages.inbox
  end

  def outbox
    messages.outbox
  end
end
