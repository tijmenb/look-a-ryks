require 'sinatra'
require 'aws-sdk'
require 'securerandom'

BUCKET = "rijks-aws-experiment"
AWS_REGION = 'eu-west-1'
DATABASE = JSON.parse(File.read('db.json'))

get '/' do
  erb :view
end

post '/upload' do
  file = params[:file][:tempfile]

  s3 = Aws::S3::Resource.new(region: AWS_REGION)
  random = SecureRandom.uuid
  object = s3.bucket(BUCKET).object("uploaded/#{random}")
  object.upload_file(file.path)

  redirect "/lookalikes/#{random}"
end

get '/lookalikes/:id' do |id|
  client = Aws::Rekognition::Client.new(region: AWS_REGION)

  resp = client.search_faces_by_image(
    collection_id: "rijksmuseum-portrets",
    face_match_threshold: 10,
    image: {
      s3_object: {
        bucket: BUCKET,
        name: "uploaded/#{id}",
      },
    },
    max_faces: 3,
  )

  s3 = Aws::S3::Resource.new(region: AWS_REGION)
  obj = s3.bucket(BUCKET).object("uploaded/#{id}")
  @uploaded_url = obj.presigned_url(:get)

  @results = resp.face_matches.map do |r|
    e = DATABASE.find { |entry| entry["object_number"] == r.face.external_image_id }
    e.merge("similarity" => r.similarity)
  end

  erb :view
end
