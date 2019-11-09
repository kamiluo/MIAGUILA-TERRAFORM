resource "aws_elasticache_cluster" "cache_ma_redis" {
  cluster_id           = "cache-ma-redis"
  engine               = "redis"
  node_type            = "${var.elas_cache_node_type}"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  engine_version       = "3.2.10"
  port                 = 6379
}
