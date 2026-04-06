# Выводим IP-адреса и ключи для последующего использования в Ansible

output "lb_external_ip" {
  description = "Внешний IP балансировщика"
  value       = yandex_compute_instance.lb.network_interface.0.nat_ip_address
}

output "lb_internal_ip" {
  description = "Внутренний IP балансировщика"
  value       = yandex_compute_instance.lb.network_interface.0.ip_address
}

output "app1_external_ip" {
  description = "Внешний IP app1"
  value       = yandex_compute_instance.app1.network_interface.0.nat_ip_address
}

output "app1_internal_ip" {
  description = "Внутренний IP app1"
  value       = yandex_compute_instance.app1.network_interface.0.ip_address
}

output "app2_external_ip" {
  description = "Внешний IP app2"
  value       = yandex_compute_instance.app2.network_interface.0.nat_ip_address
}

output "app2_internal_ip" {
  description = "Внутренний IP app2"
  value       = yandex_compute_instance.app2.network_interface.0.ip_address
}

output "db_master_external_ip" {
  description = "Внешний IP мастера PostgreSQL"
  value       = yandex_compute_instance.db_master.network_interface.0.nat_ip_address
}

output "db_master_internal_ip" {
  description = "Внутренний IP мастера PostgreSQL"
  value       = yandex_compute_instance.db_master.network_interface.0.ip_address
}

output "db_replica_external_ip" {
  description = "Внешний IP реплики PostgreSQL"
  value       = yandex_compute_instance.db_replica.network_interface.0.nat_ip_address
}

output "db_replica_internal_ip" {
  description = "Внутренний IP реплики PostgreSQL"
  value       = yandex_compute_instance.db_replica.network_interface.0.ip_address
}

# S3 ключи (чувствительные)
output "s3_access_key" {
  description = "Access Key для Object Storage"
  value       = yandex_iam_service_account_static_access_key.mediawiki_sa_key.access_key
  sensitive   = true
}

output "s3_secret_key" {
  description = "Secret Key для Object Storage"
  value       = yandex_iam_service_account_static_access_key.mediawiki_sa_key.secret_key
  sensitive   = true
}

output "s3_bucket_name" {
  description = "Имя бакета для загрузок MediaWiki"
  value       = yandex_storage_bucket.mediawiki_files.bucket
}

output "s3_backups_bucket_name" {
  description = "Имя бакета для хранения дампов PostgreSQL"
  value       = yandex_storage_bucket.mediawiki_backups.bucket
}

# Пароль для БД (выводим, чтобы потом передать в Ansible, но помечаем sensitive)
output "db_password" {
  description = "Пароль пользователя wikiuser"
  value       = var.db_password
  sensitive   = true
}

output "replication_password" {
  description = "Пароль пользователя replicator"
  value       = var.replication_password
  sensitive   = true
}