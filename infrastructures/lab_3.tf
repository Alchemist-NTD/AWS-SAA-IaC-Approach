data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "replication" {
  name = "tf-iam-role-replication-12345"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_s3_bucket" "replication_2" {
  bucket = "cfst-3355-d4ca7508621ecf2275861ab32-appconfigprod2-qtnzsyekzjhs"
  acl = "private"
  versioning {
    enabled = true
  }

  lifecycle_rule {
    id = "ReplicateDeleteMarkers"
    enabled = true

    noncurrent_version_expiration {
      days = 7
    }
  }
}

# resource "aws_s3_bucket_policy" "replication_2" {
#   bucket = aws_s3_bucket.replication_2.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Sid       = "ReplicationPolicyStmt",
#         Effect    = "Allow",
#         Principal = "*",
#         Action    = "s3:GetReplicationConfiguration",
#         Resource  = aws_s3_bucket.replication_2.arn
#       }
#     ]
#   })
# }

resource "aws_s3_bucket_versioning" "appconfigprod1" {
  bucket = "cfst-3355-d4ca7508621ecf2275861ab32-appconfigprod1-qtnzsyekzjhs"
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  role   = aws_iam_role.replication.arn
  bucket = "cfst-3355-d4ca7508621ecf2275861ab32-appconfigprod1-qtnzsyekzjhs"

  rule {
    id = "foobar"

    # filter {}

    status = "Enabled"

    # source_selection_criteria {
    #   replica_modifications {
    #     status = "Enabled"
    #   }
    # }

    destination {
      bucket = aws_s3_bucket.replication_2.arn
      # storage_class = "STANDARD"
    }

    # delete_marker_replication {
    #     status = "Enabled"
    # }
  }
}

# arn:aws:s3:::cfst-3355-ff3fe06ad13b9e2d1eec3e42e-appconfigprod1-l7is5ahnt5pt
