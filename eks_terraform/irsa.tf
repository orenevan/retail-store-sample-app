

# IAM role for the IAM user to assume
resource "aws_iam_role" "eks_access_role" {
  name               = "eks-access-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::171536096671:user/testeks"
      },
      "Action": "sts:AssumeRole",
      "Condition": {}
    }
  ]
}
EOF
}

# Policy defining read-only access to EKS resources
resource "aws_iam_policy" "eks_read_only_policy" {
  name        = "eks-read-only-policy"
  description = "Provides read-only access to EKS resources"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "eks:Describe*",
        "eks:List*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Attach the read-only policy to the IAM role
resource "aws_iam_role_policy_attachment" "eks_access_attachment" {
  role       = aws_iam_role.eks_access_role.name
  policy_arn = aws_iam_policy.eks_read_only_policy.arn
}

# Kubernetes service account to associate with the IAM role
resource "kubernetes_service_account" "eks_service_account" {
  metadata {
    name      = "eks-service-account"
    namespace = "kube-system"

    # Associate the IAM role with the Kubernetes service account
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks_access_role.arn
    }
  }

  # Automount service account token
  automount_service_account_token = true
}
