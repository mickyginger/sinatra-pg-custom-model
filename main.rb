require 'sinatra'
require 'sinatra/reloader' if development?

require_relative File.dirname(__FILE__) + '/controllers/quotes'

class QuotesApp < Sinatra::Application

  get '/' do
    redirect "/quotes"
  end

end