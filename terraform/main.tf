# Создание сети, ВМ, Object Storage, сервисных аккаунтов

# --- Сеть и подсеть ---
resource "yandex_vpc_network" "mediawiki_net" {
  name        = "mediawiki-network"
  description = "VPC для MediaWiki проекта"
}

resource "yandex_vpc_subnet" "mediawiki_subnet" {
  name           = "mediawiki-subnet"
  description    = "Подсеть в зоне ru-central1-a"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.mediawiki_net.id
  v4_cidr_blocks = [var.vpc_cidr]
}

# --- Сервисный аккаунт для Object Storage (S3) ---
resource "yandex_iam_service_account" "mediawiki_sa" {
  name        = "mediawiki-sa"
  description = "Сервисный аккаунт для доступа к Object Storage из MediaWiki"
}

resource "yandex_iam_service_account_iam_member" "signer" {
  service_account_id = yandex_iam_service_account.mediawiki_sa.id
  role   = "editor"
  member = "serviceAccount:${yandex_iam_service_account.mediawiki_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "sa_storage_editor" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.mediawiki_sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "mediawiki_sa_key" {
  service_account_id = yandex_iam_service_account.mediawiki_sa.id
  description        = "Статический ключ для MediaWiki (S3 API)"
}

# Бакет для загружаемых файлов (уникальное имя через суффикс)
resource "yandex_storage_bucket" "mediawiki_files" {
  bucket     = "mediawiki-files-${substr(yandex_iam_service_account.mediawiki_sa.id, 0, 8)}"
  acl        = "private"
  folder_id  = var.folder_id
  force_destroy = true
  depends_on = [yandex_resourcemanager_folder_iam_member.sa_storage_editor]
}

# Бакет для резервных копий БД
resource "yandex_storage_bucket" "mediawiki_backups" {
  bucket = "mediawiki-backups-${substr(yandex_iam_service_account.mediawiki_sa.id, 0, 8)}"
  acl    = "private"
  folder_id  = var.folder_id
  force_destroy = true
  # Настройка жизненного цикла: автоматически удалять бэкапы старше 30 дней
  lifecycle_rule {
    id      = "expire-old-backups"
    enabled = true

    expiration {
      days = 30
    }

    filter {
      prefix = "db-dump/"
    }
  }

  depends_on = [yandex_resourcemanager_folder_iam_member.sa_storage_editor]
}

# --- Виртуальные машины ---

# Балансировщик (Nginx) + Zabbix Server (можно совместить для экономии)
resource "yandex_compute_instance" "lb" {
  name        = "mediawiki-lb"
  description = "Балансировщик Nginx и Zabbix Server"
  zone        = var.default_zone
  platform_id = "standard-v2"

  resources {
    cores  = var.instance_specs["lb"].cores
    memory = var.instance_specs["lb"].memory
  }

  boot_disk {
    initialize_params {
      image_id = var.ubuntu_image_id
      size     = var.instance_specs["lb"].disk
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.mediawiki_subnet.id
    nat       = true # публичный IP для доступа из интернета
  }

  metadata = {
    ssh-keys = "${var.vm_username}:${file(var.public_ssh_key_path)}"
  }
}

# Сервер приложения 1
resource "yandex_compute_instance" "app1" {
  name        = "mediawiki-app1"
  zone        = var.default_zone
  platform_id = "standard-v2"

  resources {
    cores  = var.instance_specs["app"].cores
    memory = var.instance_specs["app"].memory
  }

  boot_disk {
    initialize_params {
      image_id = var.ubuntu_image_id
      size     = var.instance_specs["app"].disk
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.mediawiki_subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "${var.vm_username}:${file(var.public_ssh_key_path)}"
  }
}

# Сервер приложения 2
resource "yandex_compute_instance" "app2" {
  name        = "mediawiki-app2"
  zone        = var.default_zone
  platform_id = "standard-v2"

  resources {
    cores  = var.instance_specs["app"].cores
    memory = var.instance_specs["app"].memory
  }

  boot_disk {
    initialize_params {
      image_id = var.ubuntu_image_id
      size     = var.instance_specs["app"].disk
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.mediawiki_subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "${var.vm_username}:${file(var.public_ssh_key_path)}"
  }
}

# Мастер PostgreSQL
resource "yandex_compute_instance" "db_master" {
  name        = "mediawiki-db-master"
  zone        = var.default_zone
  platform_id = "standard-v2"

  resources {
    cores  = var.instance_specs["db"].cores
    memory = var.instance_specs["db"].memory
  }

  boot_disk {
    initialize_params {
      image_id = var.ubuntu_image_id
      size     = var.instance_specs["db"].disk
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.mediawiki_subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "${var.vm_username}:${file(var.public_ssh_key_path)}"
  }
}

# Реплика PostgreSQL
resource "yandex_compute_instance" "db_replica" {
  name        = "mediawiki-db-replica"
  zone        = var.default_zone
  platform_id = "standard-v2"

  resources {
    cores  = var.instance_specs["replica"].cores
    memory = var.instance_specs["replica"].memory
  }

  boot_disk {
    initialize_params {
      image_id = var.ubuntu_image_id
      size     = var.instance_specs["replica"].disk
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.mediawiki_subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "${var.vm_username}:${file(var.public_ssh_key_path)}"
  }
}