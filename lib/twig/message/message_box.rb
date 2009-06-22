
class Twig::Messages::Box
  attr_accessor :client, :contents, :active
  def initialize(client)
    @client = client
  end

  # Returns all of the Twig::Message objects in the selected box.
  #
  # If _action_ is :update, :sync, or :refresh, or if contents has never been
  # called before, contents will _fill_ itself with all of the Twig::Message
  # objects from the Twitter server.
  #
  def contents(action=nil)
    if @contents
      case action
      when :update, :sync, :refresh
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

  # Returns the number of Twig::Message objects in the Twig::Message::Box object.
  #
  def size
    contents.size
  end

  # Returns the _active_ Twig::Message object in the Twig::Message::Box object.
  #
  # If active hasn't been called before, or if _action_ is :update, :sync, or
  # :refresh, the most recent Twig::Message object in the Twig::Message::Box
  # will be returned.
  #
  def active(action=nil)
    if @active
      case action
      when :update, :sync, :refresh
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

  # Returns an Array of Twig::Mesage objects, sorted by the following criteria:
  #
  # _ivar_ can be either an aspect of the Twig::Message objects being searched for,
  # or the Twig::User objects that created the messages:
  #
  # MESSAGE _ivars_
  # * :id OR :msg_id
  # * :created OR :date
  #
  # USER _ivars_
  # * :screen_name OR :sn
  # * :user_id OR :uid
  # * :name OR :real_name
  #
  # If _sort_by_ is called from a Twig::Message::Inbox object, the USER _ivars_ will
  # apply to the message's sender.  If _sort_by_ is called from a
  # Twig::Message::Outbox, then _ivars_ will apply to the message's recipient.
  #
  # Results can also be adjusted with the following _OPTIONS_:
  #
  # Page Size (:page_size => Fixnum)
  # * Number of results to return per page
  # * Defaults to 10
  #
  # Page (:page => Fixnum)
  # * Page number to return
  # * Defaults to 1
  # 
  # Direction (:dir => :asc OR :desc)
  # * Direction in which to return sorted results
  # * Defaults to :desc [descending]
  #
  def sort_by(ivar, opts={})

    msg_vars = {
      :id => :@id,
      :msg_id => :@id,
      :created => :@created_at,
      :date => :@created_at
      }

    user_vars = {
      :screen_name => :@screen_name,
      :sn => :@screen_name,
      :user_id => :@id,
      :uid => :@id,
      :name => :@name,
      :real_name => :@name
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
  
  # Find and return a Twig::Message object based on user ID or screen name of
  # the sender/recipient.
  #
  # If _find()_ is searching through a Twig::Message::Inbox object, it will
  # search for the :id or :screen_name of the Message's sender.  If _find()_
  # is searching through a Twig::Message::Outbox object, it will search for
  # the :id or :screen_name fo the Message's recipient.
  #
  # OPTIONS
  # 
  # ID [ :id => Fixnum ]
  # * Search for friend by ID number
  # * Must be a Fixnum object
  #
  # Screen Name [ :screen_name => String ]
  # * Search for a friend by screen name
  # * Must be a String
  #
  # Activate [ :activate => false OR true ]
  # * Determines whether or not the found friend is set as the active friend.
  # * Defaults to FALSE
  #
  # Returns nil and raises an error if no friend is found.
  #
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

  # Returns a Twig::Message object sent/received by a Twig::User with an ID or screen_name
  # matching _friend_, and sets it as the ACTIVE Twig::Friend.
  #
  # If no message is found nil will be returned and an error will be raised.
  #
  # _msg_user_ can be entered as either a Twitter user ID (Fixnum), or the user's 
  # screen name (String).
  #
  def activate(msg_user)
    case msg_user
    when Fixnum
      find :id => msg_user, :activate => true
    when String
      find :screen_name => msg_user, :activate => true
    else
      raise ArgumentError, "#{action} is not a valid argument for @activate."
    end
  end
 
  # Returns the most recent Twig::Message object in your Twig::Message::Box
  # _contents_ Array
  #
  def first
    contents[0]
  end

  # Returns the oldest Twig::Message object in your Twig::Message::Box
  # _contents_ Array
  #
  def last
    contents[contents.size - 1]
  end
end

class Twig::Inbox < Twig::Messages::Box
  # Fills the Twig::Inbox object with Twig::Inbox::Message objects from the 
  # Twitter server.
  #
  def fill
    @client.messages(:received).collect {|m| Twig::Inbox::Message.new(@client, m) }
  end
end

class Twig::Outbox < Twig::Messages::Box
  # Fills the Twig::Outbox object with Twig::Outbox::Message objects from the 
  # Twitter server.
  def fill
    @client.messages(:sent).collect {|m| Twig::Outbox::Message.new(@client, m) }
  end
end

class Twig::Inbox::Message < Twig::Message
  
  # Sends a reply to the sender of the original message.
  #
  # Raises an error if _text_ is greater than 140 characters.
  #
  def reply(text)
    if text.size <= 140
      @client.message(:post, text, @info.sender.id)
    else
      raise ArgumentError, "Direct Messages (DMs) must be no longer than 140 characters.  " +
                           "Please trim #{text.size - 140} characters from your message " +
                           "and try again."
    end
  end

  # Forwards the selected Twig::Message to a user with screen name (String) or
  # id # (Fixnum) _id_sn_.  Returns the Twig::Message object if sent successfully.
  #
  # If _preface_ is set to _true_ (default), it will prepend the message with
  # the words '_sender_screen_name_ said:'.  If _preface_ is false, no preface
  # will be prepended to the message.
  #
  # If the message (plus the preface) is greater than 140 characters, _nil_ is
  # returned and an error is raised.
  #
  def forward_to(id_sn, preface=true)
    
    case id_sn
    when Fixnum, String
      user = @client.user(id_sn)
    end

    if user
    text = preface ? "#{@info.sender.screen_name} wrote: '#{@info.text}'" : @info.text
      if text.size > 140
        output = nil
        raise "Message '#{text}' is longer than 140 characters."
      else
        output = @client.message(:post, text, user.id)
      end
    else
      case id_sn
      when Fixnum
        output = nil
        raise ArgumentError, "Could not find Twig::User id #{id_sn}."
      when String
        output = nil
        raise ArgumentError, "Could not find Twig::User '#{id_sn}'."
      end
    end

    return output
  end   
end

class Twig::Outbox::Message < Twig::Message
  
  # Sends a reply to the recipient of the original message.
  #
  # Raises an error if _text_ is greater than 140 characters.
  #
  def reply(text)
    if text.size <= 140
      @client.message(:post, text, @info.recipient.id)
    else
      raise ArgumentError, "Direct Messages (DMs) must be no longer than 140 characters.  " +
                           "Please trim #{text.size - 140} characters from your message " +
                           "and try again."
    end
  end
  
  # Forwards the selected Twig::Message to a user with screen name (String) or
  # id # (Fixnum) _id_sn_.  Returns the Twig::Message object if sent successfully.
  #
  # If _preface_ is set to _true_ (default), it will prepend the message with
  # the words '_sender_screen_name_ said:'.  If _preface_ is false, no preface
  # will be prepended to the message.
  #
  # If the message (plus the preface) is greater than 140 characters, _nil_ is
  # returned and an error is raised.
  #
  def forward_to(id_sn, preface=true)
    
    case id_sn
    when Fixnum, String
      user = @client.user(id_sn)
    end

    if user
    text = preface ? "#{@info.recipient.screen_name} wrote: '#{@info.text}'" : @info.text
      if text.size > 140
        output = nil
        raise "Message '#{text}' is longer than 140 characters."
      else
        output = @client.message(:post, text, user.id)
      end
    else
      case id_sn
      when Fixnum
        output = nil
        raise ArgumentError, "Could not find Twig::User id #{id_sn}."
      when String
        output = nil
        raise ArgumentError, "Could not find Twig::User '#{id_sn}'."
      end
    end

    return output
  end   
end
