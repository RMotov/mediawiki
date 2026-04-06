# Все переменные, которые нужно заполнить перед запуском

# --- Обязательные (без значений по умолчанию) ---
variable "yandex_cloud_token" {
  description = "OAuth-токен Yandex Cloud"
  type        = string
  sensitive   = true
}

variable "cloud_id" {
  description = "ID облака Yandex Cloud"
  type        = string
}

variable "folder_id" {
  description = "ID каталога, где будут создаваться ресурсы"
  type        = string
}

# --- Опциональные с разумными значениями по умолчанию ---
variable "default_zone" {
  description = "Зона доступности Yandex Cloud"
  type        = string
  default     = "ru-central1-a"
}

variable "public_ssh_key_path" {
  description = "Путь к вашему публичному SSH-ключу"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "vm_username" {
  description = "Имя пользователя на ВМ (для Ubuntu по умолчанию ubuntu)"
  type        = string
  default     = "ubuntu"
}

variable "ubuntu_image_id" {
  description = "ID образа Ubuntu 22.04 LTS в Yandex Cloud"
  type        = string
  default     = "fd81radk00nmm2jpqh94"  # актуальный на момент написания. Можно тут подсмотреть: yc compute image list --folder-id standard-images
}

# Размеры виртуальных машин (cores, memory GB, disk GB)
variable "instance_specs" {
  description = "Конфигурация ВМ по ролям"
  type = map(object({
    cores  = number
    memory = number
    disk   = number
  }))
  default = {
    lb      = { cores = 2, memory = 2, disk = 10 }
    app     = { cores = 2, memory = 4, disk = 20 }
    db      = { cores = 2, memory = 4, disk = 30 }
    replica = { cores = 2, memory = 4, disk = 30 }
  }
}

# Параметры сети
variable "vpc_cidr" {
  description = "CIDR блока для VPC подсети"
  type        = string
  default     = "10.10.0.0/24"
}

# Пароль для репликации PostgreSQL (лучше переопределить в terraform.tfvars)
variable "replication_password" {
  description = "Пароль для пользователя replicator в PostgreSQL"
  type        = string
  sensitive   = true
  default     = "replicator"
}

# Пароль для БД MediaWiki
variable "db_password" {
  description = "Пароль для пользователя wikiuser в PostgreSQL"
  type        = string
  sensitive   = true
  default     = "wikiuser"
}