
class Twirp::MessageBox
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

