class UploadedFile
  BUCKET = 'rijks-aws-experiment'

  attr_reader :id

  def initialize(id)
    @id = id
  end

  def upload(path)
    object.upload_file(path)
  end

  def signed_url
    object.presigned_url(:get)
  end

  def s3_object
    {
      bucket: BUCKET,
      name: "uploaded/#{id}",
    }
  end

private

  def object
    @object ||= s3.bucket(BUCKET).object("uploaded/#{id}")
  end

  def s3
    @s3 ||= Aws::S3::Resource.new(region: AWS_REGION)
  end
end
