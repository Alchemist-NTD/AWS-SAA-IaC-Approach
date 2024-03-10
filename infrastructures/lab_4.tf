resource "aws_s3_bucket" "bucket_1" {
  bucket = ""
  force_destroy = true
}

resource "aws_iam_policy" "s3_replication_policy" {
  name = "S3ReplicationPolicy"
  
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:ListBucket",
                "s3:GetReplicationConfiguration",
                "s3:GetObjectVersionForReplication",
                "s3:GetObjectVersionAcl",
                "s3:GetObjectVersionTagging",
                "s3:GetObjectRetention",
                "s3:GetObjectLegalHold"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${var.lab_3_bucket_1}",
                "arn:aws:s3:::${var.lab_3_bucket_1}/*",
                "arn:aws:s3:::${local.lab_3_bucket_2}",
                "arn:aws:s3:::${local.lab_3_bucket_2}/*"
            ]
        },
        {
            "Action": [
                "s3:ReplicateObject",
                "s3:ReplicateDelete",
                "s3:ReplicateTags",
                "s3:ObjectOwnerOverrideToBucketOwner"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${var.lab_3_bucket_1}/*",
                "arn:aws:s3:::${local.lab_3_bucket_2}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_s3_object" "static_web" {
  bucket = "your_bucket_name"
  key    = "new_object_key"
  source = "path/to/file"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("path/to/file")
}

