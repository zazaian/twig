
class Twirp::Status
  attr_accessor :client, :id
  def initialize(client)
    @client = client
    last = @client.timeline_for(:me)
    if last
      @id = last[0].id
    else
      return "There are no status updates on the Twitter timeline for \"#{@client.login}\""
    end
  end

  def post(text)
    if text.size <= 140
      s = @client.status(:post, text)
      @id = s.id
      return "Stats \"#{text}\" successfully posted at #{Time.now.to_s}."
    else
      raise ArgumentError, "Status posts must be no longer than 140 characters."
    end
  end

  def get(id=nil)
    get_delete :action => :get, :id => id
  end
        
  def delete(id=nil)
    get_delete :action => :delete, :id => id
  end 


  private
  #######
  def get_delete(opts={})
    action = opts[:action] ? opts[:action] : :get
    id = opts[:id] ? opts[:id] : nil
    if id
      s = @client.status(action, id)
      if s
        @id = id
      else
        raise ArgumentError, "Status id##{id} doesn't seem to exist."
      end
    elsif @id
      s = @client.status(action, @id)
      unless s
        raise ArgumentError, "Status id##{@id} doesn't seem to exist."
      end
    else
      raise ArgumentError, "There is no active id for Twirp::Status."
    end
  end
end
