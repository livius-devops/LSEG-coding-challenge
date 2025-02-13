output "sg_id" {
  value = [for sg in aws_security_group.this : sg.id]
}