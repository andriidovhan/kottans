require "sinatra"
require "sinatra/activerecord"
require "./aes_crypt"
# https://gist.github.com/subwindow/728456
require 'openssl'
require 'json'
require 'zlib'
require 'securerandom'
require_relative "remove_message_worker"

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

set :database, {adapter: "postgresql", database: "kottans_db_development"}

class MyApplication < Sinatra::Base
  register Sinatra::ActiveRecordExtension
end

class Messages < ActiveRecord::Base
  validates_presence_of :message
end

get '/' do
  redirect '/messages'
end

get '/messages' do
  @r_m = RemoveMessageWorker.new
  @r_m.perform
  @messages = Messages.all
  erb :index
end

get '/messages.json' do
  content_type :json
  @messages = Messages.all.to_json
end

get '/messages/' do
  redirect '/messages'
end

get '/messages/new' do
  @message = Messages.new
  erb :new
end

post '/messages' do
  a = params[:message].to_a
  c = AESCrypt.encrypt(a[0][1], OpenSSL::Digest::SHA256.new(1234.to_s).digest, nil, "AES-256-CBC")
  d = params[:destruction].to_a
  @message = Messages.new("message"=>"#{c}","destruction"=>d[0][1].to_i, "created_at"=>Time.now, "link"=>"#{SecureRandom.urlsafe_base64(5)}")
  if @message.save
    # redirect "/messages/#{@message.id}"
    redirect "/messages"
  else
    erb :new
  end
end

def diff_time(time)
  Time.now - time
end

get '/messages/:link' do
  if  Messages.where(link: "#{params[:link]}").exists?
  protected!
  a = Messages.where(link: "#{params[:link]}")
  @message = AESCrypt.decrypt(a[0].message, OpenSSL::Digest::SHA256.new(1234.to_s).digest, nil, "AES-256-CBC")
  if a[0].destruction == 1
    a[0].destroy
    erb :show
  elsif diff_time(a[0].created_at) >= 3600.0
   a[0].destroy
    erb :show
  else
    erb :show
  end
  else
    halt 404, message_404
  end
end

def message_404
  erb :error_404
end

post '/messages/:link' do
  a = Messages.where(link: "#{params[:link]}")
  @message = a[0].destroy
  redirect '/'
end

delete '/messages/:id.json' do
  content_type :json
  @message = Messages.find(params[:id]).destroy
  return 204
end

# require 'pry'; binding.pry;