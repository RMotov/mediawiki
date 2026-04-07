#!/bin/bash
# Создаёт ansible/inventory.yml на основе outputs Terraform

set -e

cd terraform

echo -e "\e[34mПолучаем terraform outputs в JSON формате\e[0m"

# Получаем outputs в JSON формате
OUTPUTS=$(terraform output -json)

echo -e "\e[34mИзвлекаем IP адреса\e[0m"

# Извлекаем IP адреса (убираем кавычки -r)
LB_EXT=$(echo "$OUTPUTS" | jq -r '.lb_external_ip.value')
LB_INT=$(echo "$OUTPUTS" | jq -r '.lb_internal_ip.value')
APP1=$(echo "$OUTPUTS" | jq -r '.app1_external_ip.value')
APP1_INTERNAL_IP=$(echo "$OUTPUTS" | jq -r '.app1_internal_ip.value')
APP2=$(echo "$OUTPUTS" | jq -r '.app2_external_ip.value')
APP2_INTERNAL_IP=$(echo "$OUTPUTS" | jq -r '.app2_internal_ip.value')
DB_MASTER=$(echo "$OUTPUTS" | jq -r '.db_master_external_ip.value')
DB_MASTER_INTERNAL_IP=$(echo "$OUTPUTS" | jq -r '.db_master_internal_ip.value')
DB_REPLICA=$(echo "$OUTPUTS" | jq -r '.db_replica_external_ip.value')
DB_REPLICA_INTERNAL_IP=$(echo "$OUTPUTS" | jq -r '.db_replica_internal_ip.value')

echo -e "\e[34mПолучаем ключи S3\e[0m"

# Получаем ключи S3 (чувствительные, но они понадобятся в group_vars)
S3_ACCESS=$(echo "$OUTPUTS" | jq -r '.s3_access_key.value')
S3_SECRET=$(echo "$OUTPUTS" | jq -r '.s3_secret_key.value')
S3_BUCKET=$(echo "$OUTPUTS" | jq -r '.s3_bucket_name.value')
S3_BACKUPS_BUCKET=$(echo "$OUTPUTS" | jq -r '.s3_backups_bucket_name.value')
DB_PASS=$(echo "$OUTPUTS" | jq -r '.db_password.value')
REPL_PASS=$(echo "$OUTPUTS" | jq -r '.replication_password.value')

cd ../ansible

echo -e "\e[34mСоздаём inventory.yml\e[0m"

# Создаём inventory.yml из шаблона, заменяя переменные
sed -e "s/{{ LB_EXT }}/$LB_EXT/g" \
    -e "s/{{ LB_INT }}/$LB_INT/g" \
    -e "s/{{ APP1 }}/$APP1/g" \
    -e "s/{{ APP1_INTERNAL_IP }}/$APP1_INTERNAL_IP/g" \
    -e "s/{{ APP2 }}/$APP2/g" \
    -e "s/{{ APP2_INTERNAL_IP }}/$APP2_INTERNAL_IP/g" \
    -e "s/{{ DB_MASTER }}/$DB_MASTER/g" \
    -e "s/{{ DB_MASTER_INTERNAL_IP }}/$DB_MASTER_INTERNAL_IP/g" \
    -e "s/{{ DB_REPLICA }}/$DB_REPLICA/g" \
    -e "s/{{ DB_REPLICA_INTERNAL_IP }}/$DB_REPLICA_INTERNAL_IP/g" \
    inventory.yml.template > inventory.yml

echo -e "\e[34mОбновляем group_vars/all.yml\e[0m"

# Также обновляем group_vars/all.yml с секретами
#sed -i "s/{{ s3_access_key }}/$S3_ACCESS/g" group_vars/all.yml
#sed -i "s/{{ s3_secret_key }}/$S3_SECRET/g" group_vars/all.yml
#sed -i "s/{{ s3_bucket_name }}/$S3_BUCKET/g" group_vars/all.yml
#sed -i "s/{{ s3_bucket_name }}/$S3_BUCKET/g" group_vars/all.yml
#sed -i "s/{{ db_password }}/$DB_PASS/g" group_vars/all.yml
#sed -i "s/{{ replication_password }}/$REPL_PASS/g" group_vars/all.yml
sed -e "s/{{ s3_access_key }}/$S3_ACCESS/g" \
    -e "s/{{ s3_secret_key }}/$S3_SECRET/g" \
    -e "s/{{ s3_bucket_name }}/$S3_BUCKET/g" \
    -e "s/{{ s3_backups_bucket_name }}/$S3_BACKUPS_BUCKET/g" \
    -e "s/{{ DB_MASTER }}/$DB_MASTER/g" \
    -e "s/{{ db_host }}/$DB_MASTER_INTERNAL_IP/g" \
    -e "s/{{ db_password }}/$DB_PASS/g" \
    -e "s/{{ replication_password }}/$REPL_PASS/g" \
    -e "s/{{ LB_EXT }}/$LB_EXT/g" \
    all.yml.template > group_vars/all.yml

echo -e "\033[0;32mInventory и group_vars успешно обновлены.\033[0m"