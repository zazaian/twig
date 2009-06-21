
class Twig::Users
  def initialize(client)
    @client = client
  end

  def user(id_sn, action=nil)
    unless [String, Fixnum, Twitter::User].member?(user.class)
      raise "User must be inputted as either a screen_name(String), a user id#(Fixnum)," \
          + " or a Twitter::User object."
    else
      if @user[id_sn]
        id = id_sn
      else
        user_check = @client.user(user)
        if user_check
          id = user_check.id
        else
          raise "Twitter user '#{user}' could not be found."
        end
      end
    end
    
    if @user
      case action
      when :update
        @user = {}
        @user[id] = Twig::Timeline::User.new(@client, user_check)
      when nil
        @user
      else
        raise ArgumentError, "#{action} is not a valid argument for @active."
      end
    else
      @user = {}
      @user[id] = Twig::Timeline::User.new(@client, user_check)
    end
  end
end


