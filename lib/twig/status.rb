
class Twig::Status
  attr_accessor :client, :active
  def initialize(client)
    @client = client
    update
  end

  def update
    @active = ago
  end

  def ago(num=0)
    timeline = @client.timeline_for(:me)
    selected = timeline[num]
    if selected
      output = selected
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

  
  def fav(id=nil)
    favorite(id)
  end

  def unfav(id=nil)
    unfavorite(id)
  end

  def favorite(id=nil)
    f = id ? get(id) : @active

    if ! f.favorited
      @client.favorite(:add, f.id)
      f.favorited = true
      output = f
    else
      output = nil
      raise ArgumentError, "Status id##{f.id}, '#{f.text}' is already a favorite."
    end

    return output
  end

  def unfavorite(id=nil)
    f = id ? get(id) : @active

    if f.favorited
      @client.favorite(:remove, f.id)
      f.favorited = false
      output = f
    else
      output = nil
      raise ArgumentError, "Status id##{f.id}, '#{f.text}' is not a favorite."
    end

    return output
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
    activate = opts[:activate] ? opts[:activate] : true
    
    if id
      s = @client.status(action, id)
      if s
        if action == :get
          @active = s if activate
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

module Twig::Status::Methods
  attr_reader :status
  def status(action=nil)
    if @status
      case action
      when :create
        @status = Twig::Status.new(@client)
      when :update
        @status.update
      when nil
        @status
      else
        raise ArgumentError, "#{action} is not a valid argument for @status."
      end
    else
      @status = Twig::Status.new(@client)
    end
  end  
end
