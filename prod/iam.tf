data "aws_iam_policy_document" "ecs_assume_role" {

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_role" {
  name               = format("%s-task-execution-role", var.app_name)
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}