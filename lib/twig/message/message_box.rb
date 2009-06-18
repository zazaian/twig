
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

    user = self.class == Twig::Inbox ? :@sender : :@recipient

    page = opts[:page] ? opts[:page] : 1
    page_size = opts[:page_size] ? opts[:page_size] : 10
    dir = opts[:dir] ? opts[:dir] : :desc

    if ! msg_vars[ivar] && ! user_vars[ivar]
      raise ArgumentError, "#{ivar} is not a valid argument for sort_by."
    else
      output = contents.sort do |x,y|
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

class Twig::Inbox < Twig::Messages::Box
  def fill
    @client.messages(:received).collect {|m| Twig::Inbox::Message.new(@client, m) }
  end
end

class Twig::Outbox < Twig::Messages::Box
  def fill
    @client.messages(:sent).collect {|m| Twig::Outbox::Message.new(@client, m) }
  end
end

class Twig::Inbox::Message < Twig::Message
  def reply(text)
    @client.message(:post, text, @info.sender.id)
  end
  
  def forward_to(id_sn, preface=true)
    user = @client.user(id_sn)
    if user
    text = preface ? "#{@info.sender.screen_name} wrote: '#{@info.text}'" : @info.text
      if text.size > 140
        raise "Message '#{text}' is longer than 140 characters."
      else
        @client.message(:post, text, user.id)
      end
    end
  end   
end

class Twig::Outbox::Message < Twig::Message
  def reply(text)
    @client.message(:post, text, @info.recipient.id)
  end
  
  def forward_to(id_sn, preface=true)
    user = @client.user(id_sn)
    if user
    text = preface ? "#{@info.recipient.screen_name} wrote: '#{@info.text}'" : @info.text
      if text.size > 140
        raise "Message '#{text}' is longer than 140 characters."
      else
        @client.message(:post, text, user.id)
      end
    end
  end   
end
