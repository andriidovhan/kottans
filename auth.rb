# auth for specific link
helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, message_for_no_auth_user
  end

  def message_for_no_auth_user
    a = Messages.where(link: "#{params[:link]}")
    @message = a[0].message

    erb :show
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['admin', 'password']
  end
end

#auth for everything
# use Rack::Auth::Basic, "Restricted Area" do |username, password|
#   username == 'admin' and password == 'admin'
# end