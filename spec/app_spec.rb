require_relative '../app.rb'
require 'rspec'
require 'rack/test'

describe 'Server Service' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "should load the home page" do
    get '/'
    expect(last_response.status).to eq 200
    expect(last_response.body).to eq ('Hello!')
  end

  it "should load the message page" do
    get '/messages'
    expect(last_response.status).to eq 200
    expect(last_response.body).to include ('Welcome to my message store!')
  end

  it "should load the message/ page" do
    get '/messages/'
    expect(last_response.body).to eq("")
    expect(last_response.status).to eq 302
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
end
    # require 'pry'; binding.pry;
