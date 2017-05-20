# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Uploading images', type: :feature do
  before do
    ENV['AWS_ACCESS_KEY_ID'] = 'ABC'
    ENV['AWS_SECRET_ACCESS_KEY'] = 'ABC'
  end

  it 'shows images to the user when the image contains faces' do
    stub_image_upload
    stub_successful_recognition_request

    visit '/'

    expect(page).to have_content('Look-a-Ryks')

    attach_file('file', 'spec/support/image.jpg')

    click_button 'Upload'

    expect(page.status_code).to eql(200), page.body
    expect(page).to have_content('Portret van een onbekende jonge Fransman, anoniem, ca. 1883 - 1886')
  end

  it 'shows an error if the image cannot be read' do
    stub_image_upload
    stub_failed_recognition_request

    visit '/'

    expect(page).to have_content('Look-a-Ryks')

    attach_file('file', 'spec/support/image.jpg')

    click_button 'Upload'

    expect(page.status_code).to eql(400)
    expect(page).to have_content('Sorry, but this image could not be processed. Please try again')
  end

  def stub_image_upload
    stub_request(:put, %r{https://rijks-aws-experiment.s3-eu-west-1.amazonaws.com/uploaded/*})
      .to_return(status: 200)
  end

  def stub_successful_recognition_request
    stub_request(:post, %r{https://rekognition.eu-west-1.amazonaws.com/*})
      .to_return(
        status: 200,
        body: JSON.dump(
          'FaceMatches' => [
            {
              'Face' => {
                'BoundingBox' => {
                  'Height' => 0.2811110019683838,
                  'Left' => 0.23749999701976776,
                  'Top' => 0.27000001072883606,
                  'Width' => 0.39531201124191284
                },
                'Confidence' => 96.3302001953125,
                'ExternalImageId' => 'RP-F-2007-66-57-3',
                'FaceId' => '3ddfd40c-a15e-55f3-8575-8cf66d422893',
                'ImageId' => 'ff9b0d76-348f-5db4-8522-b3fcb731d686'
              },
              'Similarity' => 47.679893493652344
            }
          ],
          'SearchedFaceBoundingBox' => {
            'Height' => 0.2516297399997711,
            'Left' => 0.21251629292964935,
            'Top' => 0.12255541235208511,
            'Width' => 0.2516297399997711
          },
          'SearchedFaceConfidence' => 99.76985168457031
        )
      )
  end

  def stub_failed_recognition_request
    stub_request(:post, %r{https://rekognition.eu-west-1.amazonaws.com/*})
      .to_return(
        status: 400,
        body: JSON.dump(
          '__type' => 'InvalidImageFormatException',
          'Message' => "Invalid Input, input image shouldn't be empty"
        )
      )
  end
end
