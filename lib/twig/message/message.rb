
class Twig
end

class Twig::Messages
  attr_accessor :client, :inbox, :outbox, :all
  def initialize(client)
    @client = client
  end

  # Provides access to the Twig::Inbox object.
  #
  # If _action_ is :destroy or :empty, or if _inbox_ hasn't been called before,
  # the @inbox instance variable will be set to a new, empty Twig::Inbox.
  #
  def inbox(action=nil)
    if @inbox
      case action
      when :destroy, :empty
        @inbox = Twig::Inbox.new(@client)
      when nil
        @inbox
      else
        raise ArgumentError, "#{action} is not a valid argument for @active."
      end
    else
      @inbox = Twig::Inbox.new(@client)
    end
  end

  # Provides access to the Twig::Outbox object.
  #
  # If _action_ is :destroy or :empty, or if _outbox_ hasn't been called before,
  # the @outbox instance variable will be set to a new, empty Twig::Outbox.
  #
  def outbox(action=nil)
    if @outbox
      case action
      when :destroy, :empty
        @outbox = Twig::Outbox.new(@client)
      when nil
        @outbox
      else
        raise ArgumentError, "#{action} is not a valid argument for @active."
      end
    else
      @outbox = Twig::Outbox.new(@client)
    end
  end

  # Returns the _contents_ of Twig::Inbox
  #
  # If there are no messages in the _inbox_, _nil_ will be returned.
  #
  def in
    inbox.contents
  end
  alias_method :received, :in

  # Returns the _contents_ of Twig::Inbox.
  #
  # If there are no messages in the _outbox_, _nil_ will be returned.
  #
  def out
    outbox.contents
  end
  alias_method :sent, :out

  # Returns contents of _inbox_ and _outbox_
  #
  def all
    inbox.contents + outbox.contents
  end

  # Returns the combined number of messages in the _inbox_ and _outbox_
  #
  def count
    inbox.size + outbox.size
  end
  alias_method :size, :count

end

class Twig::Message
  attr_accessor :client, :info
  def initialize(client, info)
    @client = client
    @info = info
  end

  # Deletes the selected Twig::Message object from the Twitter server.
  #
  def delete
    @client.message(:delete, @info)
  end

end

require 'message_box'

module Twig::Messages::Methods
  attr_reader :messages

  # Provides access to the Twig::Inbox and Twig::Outbox objects.
  #
  def messages(action=nil)
    if @messages
      case action
      when :update
        @messages = Twig::Messages.new(@client)
      when nil
        @messages
      else
        raise ArgumentError
      end
    else
      @messages = Twig::Messages.new(@client)
    end
  end

  # Provides access to the Twig::Inbox object
  #
  def inbox(action=nil)
    messages.inbox(action)
  end

  # Provides access to the Twig::Outbox object
  #
  def outbox(action=nil)
    messages.outbox(action)
  end
end
