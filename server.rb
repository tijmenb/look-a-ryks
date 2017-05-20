# frozen_string_literal: true
require 'sinatra'
require 'appsignal/integrations/sinatra'
require 'aws-sdk'
require 'securerandom'

require_relative 'lib/artwork'
require_relative 'lib/uploaded_file'
require_relative 'lib/search'

AWS_REGION = 'eu-west-1'

configure :development do
  set :show_exceptions, false
  set :raise_errors, true
end

get '/' do
  erb :view
end

post '/upload' do
  file = params[:file][:tempfile]

  random = SecureRandom.uuid
  UploadedFile.new(random).upload(file.path)

  redirect "/lookalikes/#{random}"
end

get '/lookalikes/:id' do |id|
  begin
    file = UploadedFile.new(id)
    @results = Search.new(file).results
    @uploaded_url = file.signed_url
  rescue Search::Error => e
    status 400
    @error_message = e.message
  end

  erb :view
end
