output "cluster_id" {
  value       = aws_ecs_cluster.this.id
  description = "ECS Cluster ID"
}

output "cluster_name" {
  value       = aws_ecs_cluster.this.name
  description = "ECS Cluster name"
}

output "autoscaling_group_name" {
  value       = aws_autoscaling_group.ecs.name
  description = "Name of the autoscaling group"
}