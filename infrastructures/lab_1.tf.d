
resource "aws_iam_group" "ec2_admin" {
  name = "EC2-Admin" 
}

resource "aws_iam_group" "ec2_support" {
  name = "EC2-Support" 
}

resource "aws_iam_group" "s3_support" {
  name = "S3-Support" 
}

resource "aws_iam_group_policy" "gp_ec2_admin" {
  name   = "ec2-admin"
  group  = aws_iam_group.ec2_admin.name
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:Describe*",
                "ec2:StartInstances",
                "ec2:StopInstances"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": "elasticloadbalancing:Describe*",
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "cloudwatch:ListMetrics",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:Describe*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": "autoscaling:Describe*",
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_group_policy_attachment" "gp_ec2_support" {
  group      = aws_iam_group.ec2_support.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_user" "user_1" {
  name = "user-1"
}

resource "aws_iam_user" "user_2" {
  name = "user-2"
}

resource "aws_iam_user" "user_3" {
  name = "user-3"
}

resource "aws_iam_group_membership" "group_membership_1" {
  name = aws_iam_user.user_1.name
  users = [
    aws_iam_user.user_1.name
  ]
  group = aws_iam_group.s3_support.name
}

resource "aws_iam_group_membership" "group_membership_2" {
  name = aws_iam_user.user_2.name
  users = [
    aws_iam_user.user_2.name
  ]
  group = aws_iam_group.ec2_support.name
}

resource "aws_iam_group_membership" "group_membership_3" {
  name = aws_iam_user.user_3.name
  users = [
    aws_iam_user.user_3.name
  ]
  group = aws_iam_group.ec2_admin.name
}

