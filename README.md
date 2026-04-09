# mediawiki
Mediawiki в Yandex Cloud

## Дорогому ревьюверу
- Привет, ревьювер!
- Для того чтобы сэкономить твое время я напишу список ролей ansible и для чего они
1. [common](ansible/roles/common)Общая роль с установкой общих компонентов 
2. [mediawiki-app](ansible/roles/mediawiki-app)Роль с установкой приложения MediaWiki 
3. [mediawiki-backup](ansible/roles/mediawiki-backup)Роль с настройкой бэкапа MediaWiki 
4. [nginx-lb](ansible/roles/nginx-lb)Роль с настройкой балансировщика Nginx 
5. [postgresql-master](ansible/roles/postgresql-master)Роль с настройкой мастера БД PostgreSQL 
6. [postgresql-replica](ansible/roles/postgresql-replica)Роль с настройкой реплики БД PostgreSQL 
7. [zabbix-server](ansible/roles/zabbix-server)Роль с настройкой Zabbix сервера 
8. [zabbix-agent](ansible/roles/zabbix-agent)Роль с настройкой Zabbix агента

- [pg_backup.md](docs/backup/pg_backup.md)Восстановление БД PostgreSQL
- [mw_backup.md](docs/backup/mw_backup.md)Восстановление ФС MediaWiki

 
## Как работать с репозиторием?
- Перед работой нужно заполнить шаблоны
- [terraform.tfvars](terraform/terraform.tfvars)Шаблон с переопределением переменных terraform
- [variables.tf](terraform/variables.tf)Внимательно посмотрите шаблон с переменными terraform, возможно вам потребуется их заменить под себя
- [all.yml.template](ansible/all.yml.template)Шаблон для переменных ansible
- [inventory.yml.template](ansible/inventory.yml.template)Шаблон inventory ansible

1. Создаем инфраструктуру с помощью terraform
```bash
cd terraform
terraform apply
```
2. Генерируем inventory.yml и all.yml
```bash
cd ..
chmod +x ./generate_inventory.sh
./generate_inventory.sh
```
3. Настройка инфраструктуры с помощью ansible
```bash
cd ansible
ansible-playbook site.yml
```
