class Search
  attr_reader :file

  def initialize(file)
    @file = file
  end

  def results
    begin
      response.face_matches.map do |result|
        artwork = Artwork.find(result.face.external_image_id)
        artwork.merge('similarity' => result.similarity, 'pos' => result.face.bounding_box.to_h)
      end
    rescue Aws::Rekognition::Errors::InvalidImageFormatException
      raise Error, 'Sorry, but this image could not be processed. Please try again.'
    end
  end

  def uploaded_pos
    response.searched_face_bounding_box.to_h
  end

  class Error < StandardError
  end

private

  def response
    @response ||= client.search_faces_by_image(
      collection_id: 'rijksmuseum-portrets',
      face_match_threshold: 10,
      image: { s3_object: file.s3_object },
      max_faces: 4
    )
  end

  def client
    @client ||= Aws::Rekognition::Client.new(region: AWS_REGION)
  end
end
