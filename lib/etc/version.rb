
class TinyTweet
  VERSION = [1,0,4] unless defined? TinyTweet::VERSION
  REVISION = 1
  
  # Returns the current version of TinyTweet
  def self.version
    VERSION.join('.')
  end
end

