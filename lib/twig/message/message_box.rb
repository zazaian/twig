
class Twig
end

class Twig::MessageBox
  attr_accessor :client, :sent, :received
  def initialize(client)
    @client = client
    update
  end

  def update(opts={})
    sent = opts[:sent] ? opts[:sent] : true
    received = opts[:sent] ? opts[:sent] : true

    @sent = client.messages(:sent) if sent
    @received = client.messages(:received) if received
  end
end

module Twig::MessageBox::Methods
  attr_reader :message_box
  def message_box(action=nil)
    if @message_box
      case action
      when :create
        @message_box = Twig::MessageBox.new(@client)
      when :update
        @message_box.update
      when nil
        @message_box
      else
        raise ArgumentError
      end
    else
      @message_box = Twig::MessageBox.new(@client)
    end
  end
  
  def inbox
    @message_box.received
  end

  def outbox
    @message_box.sent
  end

  def received
    inbox
  end

  def sent
    outbox
  end

end
