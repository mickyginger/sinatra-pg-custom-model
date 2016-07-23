require_relative '../models/quote'

get "/quotes" do
  @quotes = Quote.all
  erb :"quotes/index"
end

get "/quotes/new" do
  erb :"quotes/new"
end

post "/quotes" do
  Quote.create(params[:quote])
  redirect '/quotes'
end

get "/quotes/:id" do
  @quote = Quote.find(params[:id])
  erb :"quotes/show"
end

get "/quotes/:id/edit" do
  @quote = Quote.find(params[:id])
  erb :"quotes/edit"
end

put "/quotes/:id" do
  data = params[:quote]
  quote = Quote.find(params[:id])

  quote.text = data[:text]
  quote.author = data[:author]
  quote.save

  redirect "/quotes/#{quote.id}"
end

delete "/quotes/:id" do
  quote = Quote.find(params[:id])
  quote.destroy

  redirect "/quotes"
end