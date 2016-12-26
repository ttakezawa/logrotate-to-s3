# logrotate-to-s3 [![Build Status](https://travis-ci.org/ttakezawa/logrotate-to-s3.svg?branch=master)](https://travis-ci.org/ttakezawa/logrotate-to-s3)

  gzip the log file, rename the file to the current timestamp, and upload to s3.

## Usage:

    logrotate-to-s3 your-bucket-name [ file ... ]

## Environment variables:

    S3_PATH is the path prefix of the S3. The default is "logrotate".
    NAME_PREFIX is the name prefix of the uploaded file. The default is "".
    UPLOAD_CMD is used for uploading to S3. The default is "aws s3 cp". You may set it as "s3cmd put", "gof3r cp --endpoint s3-ap-northeast-1.amazonaws.com" and so on.

## Examples:

    $ logrotate-to-s3 mybucket /var/log/nginx/access.log
      => s3://mybucket/logrotate/your-hostname/2016/01/access.log.20160102-030405.gz

    $ S3_PATH=archive/staging NAME_PREFIX=nginx logrotate-to-s3 mybucket /var/log/nginx/access.log
      => s3://mybucket/archive/staging/your-hostname/2016/01/nginx-access.log.20160102-030405.gz

## Configuration logroate:

  With postrotate without sharedscripts, this tool should work well.

    # good
    /var/log/nginx/*.log {
      postrotate
        NAME_PREFIX=nginx logrotate-to-s3 service-archive "$@"
      endscript
    }

  If you want to use sharescripts or lastaction, this may not work. You should avoid sharescripts and lastaction because whole pattern is passed to the script.

    # bad - because of quotes
    "/var/log/nginx/access.log" {
      sharedscripts
      postrotate
        logrotate-to-s3 mybucket "$@"
      endscript
    }

    # bad - because of wildcarded patterns
    /var/log/nginx/*.log {
      lastaction
        logrotate-to-s3 mybucket "$@"
      endscript
    }

    # bad - because space character is placed in the back of the pattern
    /var/log/nginx/access.log {
      sharedscripts
      postrotate
        logrotate-to-s3 mybucket "$@"
      endscript
    }

    # okish - it works, but "shardscripts" and "lastaction" are not recommended.
    /var/log/nginx/access.log{
      sharedscripts
      postrotate
        logrotate-to-s3 mybucket "$@"
      endscript
    }
