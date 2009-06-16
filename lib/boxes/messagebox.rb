
class Twirp::MessageBox
  attr_accessor :sent, :received
  def initialize(client)
    @sent = client.messages(:sent)
    @received = client.messages(:received)
  end
end
