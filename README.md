image
=========
Processes images and finds thumbnails for Feedbin

### Requirements
* OpenCV and calib3d module (`libopencv-dev` and `libopencv-calib3d-dev` on Debian)
* Ruby 2.3
* An AWS S3 bucket
* Redis shared with the main Feedbin instance

### Environment variables
* `AWS_ACCESS_KEY_ID` - Your AWS access key ID
* `AWS_SECRET_ACCESS_KEY` - You AWS secret access key
* `AWS_S3_BUCKET` - The bucket to upload the thumbnails to
* `REDIS_URL` - The URL to the Redis instance used by the main Feedbin instance
* `AWS_S3_REGION` - The AWS region of your bucket

Optional variables, you might need these for non-AWS providers:

* `AWS_S3_HOST` - domain of your endpoint
* `AWS_S3_ENDPOINT` - Same but with the scheme and port
* `AWS_S3_PATH_STYLE` - Need to be set to `true` for Minio

### Setup
Clone the repo and install dependencies:
```
git clone https://github.com/feedbin/image.git
cd image
bundle
```

Start the server with `bundle exec foreman start`

You may need to adjust the `ENTRY_IMAGE_HOST` environment variable of the main Feedbin instance if you want to use a reverse proxy to S3 or if you're using an alternative file server. The variable can be used to replace the hostname clients use to get the images, but the path can't be changed.
