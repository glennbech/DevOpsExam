variable "service_name" {
  description = "Navnet på App Runner-tjenesten"
  type        = string
  default     = "2001"  #
}

resource "aws_iam_role" "role_for_apprunner_service" {
  name               = var.service_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["tasks.apprunner.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "policy" {
  statement {
    effect    = "Allow"
    actions   = ["rekognition:*"]
    resources = ["*"]
  }
  
  statement  {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["*"]
  }

  statement  {
    effect    = "Allow"
    actions   = ["cloudwatch:*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "policy" {
  name        = "kjell-apr-policy-thingy"
  description = "Policy for apprunner instance I think"
  policy      = data.aws_iam_policy_document.policy.json
}

resource "aws_iam_role_policy_attachment" "attachment" {
  role       = aws_iam_role.role_for_apprunner_service.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_apprunner_service" "service" {
  service_name = var.service_name

  instance_configuration {
    instance_role_arn = aws_iam_role.role_for_apprunner_service.arn
    cpu               = 256  # Endret fra standardverdi
    memory            = 1024 # Endret fra standardverdi
  }

  source_configuration {
    authentication_configuration {
      access_role_arn = "arn:aws:iam::244530008913:role/service-role/AppRunnerECRAccessRole"
    }
    image_repository {
      image_configuration {
        port = "8080"
      }
      image_identifier      = "244530008913.dkr.ecr.eu-west-1.amazonaws.com/kjell:latest"
      image_repository_type = "ECR"
    }
    auto_deployments_enabled = true
  }
}
