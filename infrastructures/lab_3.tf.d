variable "lab_3_bucket_1" {
  type = string
  default = "cfst-3355-51066f98c5bef7cfd5fea5b3a-appconfigprod1-qqjxopegy0kt"
}

locals {
  lab_3_bucket_2 = format("%s-%s-%s", join("-", slice(split("-", var.lab_3_bucket_1), 0, 3)), "appconfigprod2", split("-", var.lab_3_bucket_1)[4])
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

resource "aws_iam_role" "assume_role" {
  name = "S3ReplicationRole"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "s3.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attachment_1" {
  role = aws_iam_role.assume_role.name
  policy_arn = aws_iam_policy.s3_replication_policy.arn
}

resource "aws_s3_bucket" "replication_2" {
  bucket = local.lab_3_bucket_2
  force_destroy = true
}

resource "aws_s3_bucket_acl" "replication_2_acl" {
  bucket = aws_s3_bucket.replication_2.id
  acl = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.replication_2.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_versioning" "appconfigprod1" {
  bucket = var.lab_3_bucket_1
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "appconfigprod2" {
  bucket = local.lab_3_bucket_2
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  role   = aws_iam_role.assume_role.arn
  bucket = var.lab_3_bucket_1

  rule {
    id = "replication-rule-1"

    status = "Enabled"

    destination {
      bucket = aws_s3_bucket.replication_2.arn
    }
  }
}
