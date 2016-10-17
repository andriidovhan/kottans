require_relative '../app.rb'
require 'rspec'
require 'rack/test'

describe 'main actions' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "should load the home(/) page" do
    get '/'
    expect(last_response.status).to eq 302
    expect(last_response.redirect?).to be true
    expect(last_response.body).to eq("")
    expect(last_request.path).to eq('/')
  end

  it "should load the home(/messages) page" do
    get '/messages'
    expect(last_response.status).to eq 200
    expect(last_response.body).to include ("Listing messages!")
    expect(last_response.body).to include ("All messages are encrypted.")
    expect(last_response.body).to include ("Only users with correct credentials are able to see decryption version.")
    expect(last_response.body).to include ("Delete This Message Immediatly")

  end

  it "should load the home(/messages/) page" do
    get '/messages/'
    expect(last_response.status).to eq 302
    expect(last_response.redirect?).to be true
    expect(last_response.body).to eq("")
    expect(last_request.path).to eq('/messages/')
  end

  it "should load the message/new page" do
    get '/messages/new'
    expect(last_response.status).to eq 200
    expect(last_response.body).to include ('Here you can add a New Message')
    expect(last_response.body).to include ('input type="submit" value="Create Message"')
    expect(last_response.body).to include ('form action="/messages" method="post"')
  end

  it "should not load the wrong page" do
    get '/blabla'
    expect(last_response).to_not be_ok
  end

  it "should be created message" do
    c = AESCrypt.encrypt("smth text", OpenSSL::Digest::SHA256.new(1234.to_s).digest, nil, "AES-256-CBC")
    @@a = Messages.create("message"=>"#{c}","destruction"=>0, "created_at"=>Time.now, "link"=>"#{SecureRandom.urlsafe_base64(5)}")
    expect(@@a.id).not_to be nil
    expect(@@a.message).to eq "68257ad42969749635b5fbac72e0d363"
    expect(@@a.destruction).to eq 0
    expect(@@a.link).not_to be nil
  end

  it "should get message without credentials" do
    get "/messages/#{@@a.link}"
    expect(last_response.body).to include "68257ad42969749635b5fbac72e0d363"
    expect(last_response.status).to eq 401
  end

  it "should get message with bad credentials" do
    authorize 'admin', 'admin'
    get "/messages/#{@@a.link}"
    expect(last_response.body).to include "68257ad42969749635b5fbac72e0d363"
    expect(last_response.status).to eq 401
  end

  it "should get message from db" do
    authorize 'admin', 'password'
    get "/messages/#{@@a.link}"
    expect(last_response.body).to include "smth text"
    expect(last_response.body).to include "Back to all messages"
    expect(last_response.status).to eq 200
  end

  it "should get message from db" do
    post "/messages/#{@@a.link}"
    expect(last_response.status).to eq 302
  end

  it "should make sure message has been deleted" do
    get "/messages/#{@@a.link}"
    expect(last_response.status).to eq 500
  end
end

describe 'message 1 hour' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "should be created message" do
    c = AESCrypt.encrypt("smth text", OpenSSL::Digest::SHA256.new(1234.to_s).digest, nil, "AES-256-CBC")
    @@a = Messages.create("message"=>"#{c}","destruction"=>0, "created_at"=>Time.now, "link"=>"#{SecureRandom.urlsafe_base64(5)}")
    expect(@@a.id).not_to be nil
    expect(@@a.message).to eq "68257ad42969749635b5fbac72e0d363"
    expect(@@a.destruction).to eq 0
    expect(@@a.link).not_to be nil
  end

  it "should get message without credentials" do
    get "/messages/#{@@a.link}"
    expect(last_response.body).to include "68257ad42969749635b5fbac72e0d363"
    expect(last_response.status).to eq 401
  end

  it "should get message with bad credentials" do
    authorize 'admin', 'admin'
    get "/messages/#{@@a.link}"
    expect(last_response.body).to include "68257ad42969749635b5fbac72e0d363"
    expect(last_response.status).to eq 401
  end

  it "should get message with correct credentials" do
    authorize 'admin', 'password'
    get "/messages/#{@@a.link}"
    expect(last_response.body).to include "smth text"
    expect(last_response.body).to include "Back to all messages"
    expect(last_response.status).to eq 200
  end

  it "should be deleted" do
    post "/messages/#{@@a.link}"
    expect(last_response.status).to eq 302
  end

  it "should make sure message has been deleted" do
    get "/messages/#{@@a.link}"
    expect(last_response.status).to eq 500
  end
end

describe 'message 1 click' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "should be created message" do
    c = AESCrypt.encrypt("smth text", OpenSSL::Digest::SHA256.new(1234.to_s).digest, nil, "AES-256-CBC")
    @@a = Messages.create("message"=>"#{c}","destruction"=>1, "created_at"=>Time.now, "link"=>"#{SecureRandom.urlsafe_base64(5)}")
    expect(@@a.id).not_to be nil
    expect(@@a.message).to eq "68257ad42969749635b5fbac72e0d363"
    expect(@@a.destruction).to eq 1
    expect(@@a.link).not_to be nil
  end

  it "should get message without credentials" do
    get "/messages/#{@@a.link}"
    expect(last_response.body).to include "68257ad42969749635b5fbac72e0d363"
    expect(last_response.status).to eq 401
  end

  it "should get message with bad credentials" do
    authorize 'admin', 'admin'
    get "/messages/#{@@a.link}"
    expect(last_response.body).to include "68257ad42969749635b5fbac72e0d363"
    expect(last_response.status).to eq 401
  end

  it "should get message with correct credentials" do
    authorize 'admin', 'password'
    get "/messages/#{@@a.link}"
    expect(last_response.body).to include "smth text"
    expect(last_response.body).to include "Back to all messages"
    expect(last_response.status).to eq 200
  end

  it "should make sure message has been deleted after first click" do
    get "/messages/#{@@a.link}"
    expect(last_response.status).to eq 500
  end

  it "should be created message(again, for removing)" do
    c = AESCrypt.encrypt("smth text", OpenSSL::Digest::SHA256.new(1234.to_s).digest, nil, "AES-256-CBC")
    @@a = Messages.create("message"=>"#{c}","destruction"=>1, "created_at"=>Time.now, "link"=>"#{SecureRandom.urlsafe_base64(5)}")
    expect(@@a.id).not_to be nil
    expect(@@a.message).to eq "68257ad42969749635b5fbac72e0d363"
    expect(@@a.destruction).to eq 1
    expect(@@a.link).not_to be nil
  end

  it "should be deleted" do
    post "/messages/#{@@a.link}"
    expect(last_response.status).to eq 302
  end

  it "should make sure message has been deleted" do
    get "/messages/#{@@a.link}"
    expect(last_response.status).to eq 500
  end
end
    # require 'pry'; binding.pry;
