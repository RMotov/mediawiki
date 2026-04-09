# Восстановление БД MediaWiki из резервной копии (Yandex Object Storage + PostgreSQL)

## Перед началом работы

- Восстановление выполняется **только на сервере-мастере**. Реплика после восстановления потеряет синхронизацию и должна быть пересоздана заново.
- Убедитесь, что у вас есть:
    - SSH-доступ к серверу мастера. IP-адрес можно посмотреть в Yandex Cloud.
    - Учётные данные PostgreSQL: `{{ db_user }}`, `{{ db_password }}`.
    - Настроенный `aws cli` с профилем `ephemeral-profile`.
    - Свободное место на диске (распакованный дамп может быть в 3–5 раз больше сжатого).
- Если вы использовали ansible, то нужные параметры можно найти в ansible/group_vars/all.yml.
- **Рекомендуется сделать резервную копию текущей БД** перед восстановлением:
  ```bash
  pg_dump -U {{ db_user }} -h localhost {{ db_name }} | gzip > /tmp/backup_before_restore_$(date +%Y%m%d_%H%M%S).sql.gz
  ```

## Восстановление
- Найти нужный дамп в Object Storage
  ```bash
  aws s3 ls s3://{{ s3_backups_bucket_name }}/db-dump/ --profile ephemeral-profile
  ```
- Скачать дамп на сервер мастера
  ```bash
  # Создать временную директорию
  mkdir -p /tmp/restore_wiki
  cd /tmp/restore_wiki
  # Скачать дамп с объектного хранилища
  aws s3 cp s3://{{ s3_backups_bucket_name }}/db-dump/my_wiki_20260409_020228.sql.gz . --profile ephemeral-profile
  ```
- Распаковать дамп
  ```bash
  gunzip -c my_wiki_20260409_020228.sql.gz > restore.sql
  ```
- Подготовить базу данных
  ```bash
  # Подключиться нужно пользователем с правами на создание
  sudo su - postgres
  psql
  ```
  ```sql
  -- Внутри psql выполните
  DROP DATABASE IF EXISTS {{ db_name }};
  CREATE DATABASE {{ db_name }} OWNER {{ db_user }};
  \q
  ```
- Восстановить данные из дампа (не прерывайте выполнение!)
  ```bash
  export PGPASSWORD="{{ db_password }}"
  psql -U {{ db_user }} -h localhost -d {{ db_name }} -f /tmp/restore_wiki/restore.sql
  ```
- Проверяем восстановление
  ```bash
  export PGPASSWORD="{{ db_password }}"
  psql -U {{ db_user }} -h localhost -d {{ db_name }}
  ```
  ```sql
  -- Посмотрим количество страниц
  SELECT COUNT(*) FROM page;
  -- Посмотрим наличие основных таблиц
  \dt
  ```
- Удаляем временные файлы
  ```bash
  rm -rf /tmp/restore_wiki
  ```
- Пересоздаем реплику
  ```bash
  # Остановите PostgreSQL на реплике
  sudo systemctl stop postgresql
  # Очистите каталог данных на реплике
  sudo rm -rf /var/lib/postgresql/14/main
  # Создайте новый каталог данных
  sudo mkdir -p /var/lib/postgresql/14/main
  # Установите права и владельца
  sudo chmod 700 /var/lib/postgresql/14/main
  sudo chown postgres:postgres /var/lib/postgresql/14/main
  # Выполните pg_basebackup с мастера
  sudo -u postgres pg_basebackup -h <IP_МАСТЕРА> -U replicator -D /var/lib/postgresql/14/main -Fp -Xs -P -R
  # Запустите PostgreSQL
  sudo systemctl start postgresql
  # Проверьте статус репликации на мастере
  sudo su - postgres
  psql
  SELECT client_addr, state, sync_state FROM pg_stat_replication;
  ```