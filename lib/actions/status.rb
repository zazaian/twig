
require 'rubygems'
gem 'twitter4r', '>=0.2.4'
require 'twitter'


class Status
  attr_accessor :client, :active
  def initialize#(client)
    @client = Twitter::Client.new(:login => "zazaian", :password => "Mistered1") #client
    ago
  end

  def ago(num=0)
    timeline = @client.timeline_for(:me)
    selected = timeline[num]
    if selected
      @active = selected
      output = @active
    else
      output = nil
      total = timeline.size
      raise ArgumentError, "There are no status updates at #{num} ago.  There are only #{total} updates on your timeline."
    end

    return output
  end

  def post(text)
    if text.size <= 140
      s = @client.status(:post, text)
      @active = s
      return @active
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
        if action == :get
          @active = s
        elsif action == :delete
          @active = ago
        end
        output = s
      else
        raise ArgumentError, "Status id##{id} doesn't seem to exist."
      end
    elsif @active
      id = @active.id
      @active = ago(1) if action == :delete
      s = @client.status(action, id)
      if s
        output = s
      else
        output = nil
        raise ArgumentError, "Status id##{@active.id} doesn't seem to exist."
      end
    else
      output = nil
      raise ArgumentError, "There is no active status object for Twirp::Status."
    end
    return output
  end
end
