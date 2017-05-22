# frozen_string_literal: true
require 'sinatra'
require 'appsignal/integrations/sinatra'
require 'aws-sdk'
require 'securerandom'
require 'base64'

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

post '/upload-image-capture' do
  client = Aws::Rekognition::Client.new(region: AWS_REGION)
  image = Base64.decode64(params[:image].gsub('data:image/png;base64,', ''))

  begin
    response = client.search_faces_by_image(
      collection_id: 'rijksmuseum-portrets',
      face_match_threshold: 10,
      image: { bytes: image },
      max_faces: 1,
    )

    result = response.face_matches.first
    artwork = Artwork.find(result.face.external_image_id)
    artwork.to_h.to_json
  rescue Aws::Rekognition::Errors::InvalidParameterException
    {}.to_json
  end
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
