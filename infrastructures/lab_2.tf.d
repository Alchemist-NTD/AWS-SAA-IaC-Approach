resource "aws_iam_policy" "s3_restricted_policy" {
  name = "S3RestrictedPolicy"
  description = "Allows read-only access to S3 buckets"
  
  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "VisualEditor0",
			"Effect": "Allow",
			"Action": [
				"s3:ListAccessPointsForObjectLambda",
				"s3:GetAccessPoint",
				"s3:PutAccountPublicAccessBlock",
				"s3:ListAccessPoints",
				"s3:CreateStorageLensGroup",
				"s3:ListJobs",
				"s3:PutStorageLensConfiguration",
				"s3:ListMultiRegionAccessPoints",
				"s3:ListStorageLensGroups",
				"s3:ListStorageLensConfigurations",
				"s3:GetAccountPublicAccessBlock",
				"s3:ListAllMyBuckets",
				"s3:ListAccessGrantsInstances",
				"s3:PutAccessPointPublicAccessBlock",
				"s3:CreateJob"
			],
			"Resource": "*"
		},
		{
			"Sid": "VisualEditor1",
			"Effect": "Allow",
			"Action": "s3:*",
			"Resource": "arn:aws:s3::${var.account_digit}:accesspoint/*"
		},
		{
			"Sid": "VisualEditor2",
			"Effect": "Allow",
			"Action": "s3:*",
			"Resource": [
				"arn:aws:s3:*:${var.account_digit}:accesspoint/*",
				"arn:aws:s3:us-west-2:${var.account_digit}:async-request/mrap/*/*",
				"arn:aws:s3:*:${var.account_digit}:storage-lens/*",
				"arn:aws:s3:*:${var.account_digit}:storage-lens-group/*",
				"arn:aws:s3:::*/*",
				"arn:aws:s3:::cfst-3352-9c13658ed300deb7fbbd016e1-appconfigprod1-vb8vylnww7ov",
				"arn:aws:s3:::cfst-3352-9c13658ed300deb7fbbd016e1-appconfigprod2-a94zgvwabara",
				"arn:aws:s3-object-lambda:*:${var.account_digit}:accesspoint/*",
				"arn:aws:s3:*:${var.account_digit}:access-grants/default",
				"arn:aws:s3:*:${var.account_digit}:access-grants/default/location/*",
				"arn:aws:s3:*:${var.account_digit}:job/*",
				"arn:aws:s3:*:${var.account_digit}:access-grants/default/grant/*"
			]
		}
	]
}
EOF
}

resource "aws_iam_role" "assume_role_1" {
    name = "S3RestrictedRole"
    assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${var.account_digit}:root",
            "arn:aws:iam::${var.account_digit}:user/user2"
          ]
        },
        "Action" : "sts:AssumeRole",
        "Condition": {}
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attachment_1" {
  role = aws_iam_role.assume_role_1.name
  policy_arn = aws_iam_policy.s3_restricted_policy.arn
}

resource "aws_iam_user" "user_1" {
  name = "user1"
}

resource "aws_iam_user_policy_attachment" "user_policy_attachment" {
  user = aws_iam_user.user_1.name
  policy_arn = aws_iam_policy.s3_restricted_policy.arn
}