#!/usr/local/bin/python
#
# Generate signed URL for bucket and file
# Misha, January 2016
#
# Example usage: ./script/get-signed-url.py -b leo-photos-development -k avatar/1/misha.jpg -s 86400
# Output: https://leo-photos-development.s3.amazonaws.com/avatar/1/misha.jpg?Signature=q5Kn9CSWsipw7vUXswSrt4izNLg%3D&Expires=1452122898&AWSAccessKeyId=AKIAJ7QKABP4V4ORLHRQ
#
# Make sure you have AWS credentials in ENV and boto library installed

import boto
import argparse

parser = argparse.ArgumentParser(description='Generate an S3 signed URL')
parser.add_argument('-b', '--bucket', help='bucket name')
parser.add_argument('-k', '--key', help='prefix/key')
parser.add_argument('-s', '--seconds', type=int, help='time in seconds until the URL will expire')
args = parser.parse_args()

s3 = boto.connect_s3()
bucket = s3.get_bucket(args.bucket)
key = bucket.get_key(args.key)
if bucket.get_key(args.key):
  print key.generate_url(args.seconds)
else:
  print 's3://' + args.bucket + '/' + args.key + ' does not exist'
