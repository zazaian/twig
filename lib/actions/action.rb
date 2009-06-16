
require 'message'
require 'timeline'
require 'status'

class Action
  attr_accessor
  def initialize()
  end

end

module Actions

  def message(opts={})
    @messages << Twirp::Message.new(self, opts)
  end

