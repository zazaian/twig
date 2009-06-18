
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

  def outbox(action=nil)
    if @outbox
      case action
      when :update
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

end

require 'message_box'

module Twig::Messages::Methods
  attr_reader :messages
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

  def inbox(action=nil)
    messages.inbox(action)
  end

  def outbox(action=nil)
    messages.outbox(action)
  end
end
