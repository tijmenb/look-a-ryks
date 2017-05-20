# frozen_string_literal: true
require 'sinatra'
require 'appsignal/integrations/sinatra'
require 'aws-sdk'
require 'securerandom'

require_relative 'lib/artwork'
require_relative 'lib/uploaded_file'

BUCKET = 'rijks-aws-experiment'
AWS_REGION = 'eu-west-1'

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
  client = Aws::Rekognition::Client.new(region: AWS_REGION)

  begin
    resp = client.search_faces_by_image(
      collection_id: 'rijksmuseum-portrets',
      face_match_threshold: 10,
      image: {
        s3_object: {
          bucket: BUCKET,
          name: "uploaded/#{id}"
        }
      },
      max_faces: 4
    )

    @uploaded_url = UploadedFile.new(id).signed_url

    @results = resp.face_matches.map do |result|
      artwork = Artwork.find(result.face.external_image_id)
      artwork.merge('similarity' => result.similarity)
    end
  rescue Aws::Rekognition::Errors::InvalidImageFormatException
    status 400
    @error_message = 'Sorry, but this image could not be processed. Please try again.'
  end

  erb :view
end
