resource "aws_sqs_queue" "diagram_process" {
  name = "diagram-process"
}

resource "aws_sqs_queue" "status_update" {
  name = "diagram-status-update"
}
