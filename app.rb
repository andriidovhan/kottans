require "sinatra"
require "sinatra/activerecord"

set :database, {adapter: "sqlite3", database: "foo.sqlite3"}

class MyApplication < Sinatra::Base
  register Sinatra::ActiveRecordExtension
end

class Messages < ActiveRecord::Base
  validates_presence_of :message
end

get '/' do
  p 'Hello!'
end

get '/messages' do
  # require 'pry'; binding.pry;
  @messages = Messages.all
  erb :index
end

get '/messages/new' do
  @message = Messages.new
  erb :new
end

post '/messages' do
  @message = Messages.new(params[:message])
  if @message.save
    redirect "/messages/#{@message.id}"
  else
    erb :new
  end
end


get '/messages/:id' do
  @message = Messages.find(params[:id])
  erb :show
end

post '/messages/:id' do
  @message = Messages.find(params[:id]).destroy
  # @message.delete
  redirect '/'
end
