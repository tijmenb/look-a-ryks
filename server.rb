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
  set :bind, '0.0.0.0'
end

get '/' do
  erb :view
end

post '/upload' do
  random = SecureRandom.uuid
  UploadedFile.new(random).upload(params[:file][:tempfile].path)
  redirect "/lookalikes/#{random}"
end

get '/lookalikes/:id' do |id|
  begin
    file = UploadedFile.new(id)
    search = Search.new(file)
    @results = search.results
    @uploaded_pos = search.uploaded_pos
    @uploaded_url = file.signed_url
  rescue Search::Error => e
    status 400
    @error_message = e.message
  end

  erb :view
end
