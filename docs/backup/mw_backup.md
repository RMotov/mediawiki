# Восстановление файловой системы MediaWiki из резервной копии (Yandex Object Storage)

## Перед началом работы

- Определите точку восстановления. Найдите нужный архив в Yandex Object Storage
- Убедитесь, что у вас есть:
    - SSH-доступ к серверам mediawiki. IP-адрес можно посмотреть в Yandex Cloud.
    - Настроенный `aws cli` с профилем `ephemeral-profile`.
    - Свободное место на диске.
- Если вы использовали ansible, то нужные параметры можно найти в ansible/group_vars/all.yml.

## Восстановление ручное
- Скачайте архив из Yandex Object Storage
  ```bash
  # Создаем временную директорию
  mkdir -p /tmp/restore_mediawiki
  cd /tmp/restore_mediawiki
  # Ищем нужный файл
  aws s3 ls s3://{{ s3_backups_bucket_name }}/fs-backups/ \
    --profile ephemeral-profile \
    --endpoint-url https://storage.yandexcloud.net
  # Качаем файл
  aws s3 cp "s3://{{ s3_backups_bucket_name }}/fs-backups/mw_fs_20260409_014507.tar.gz" . \
    --profile ephemeral-profile \
    --endpoint-url "https://storage.yandexcloud.net"
  # Остановка веб-сервера
  sudo systemctl stop nginx
  sudo systemctl stop php8.3-fpm
  # Резервное копирование текущих файлов
  sudo cp -a "/var/www/mediawiki" "/var/www/mediawiki.bak.$(date +%Y%m%d_%H%M%S)"
  # Очистка целевой директории
  sudo rm -rf /var/www/mediawiki
  # Вернем директорию и права
  sudo mkdir -p /var/www/mediawiki
  sudo chmod 755 /var/www/mediawiki
  sudo chown www-data:www-data /var/www/mediawiki
  # Распаковка архива
  sudo tar -xzf "/tmp/restore_mediawiki/mw_fs_20260409_014507.tar.gz" -C "/var/www/mediawiki"
  # Запуск веб-сервера
  sudo systemctl start php8.3-fpm
  sudo systemctl start nginx
  # Удаляем временные файлы
  rm -rf /tmp/restore_wiki
  ```
