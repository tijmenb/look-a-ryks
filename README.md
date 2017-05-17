# Look-a-Ryks

Look-a-Ryks uses facial recognition to find people who look like you from the [Rijksmuseum art collection](https://www.rijksmuseum.nl/en/rijksstudio).

## How it works

This is a Sinatra app that allows users to upload a picture. The picture is uploaded to an S3 bucket. We then [Amazon Rekognition][Rekognition] to find similar faces in a collection of portraits we've uploaded.

[Rekognition]: https://aws.amazon.com/rekognition/

## Collection

The collection we currently match against contains some 7,000 portraits from the Rijksmuseum. The uploading was a bit of a manual process, but [you can find the code here][training].

[training]: https://github.com/tijmenb/rijksmuseum-aws-experiment

## License

[MIT License](LICENSE)

Copyright (c) 2017 Tijmen Brommet
