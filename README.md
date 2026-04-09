# mediawiki
Mediawiki в Yandex Cloud


## Как работать с репозиторием?
- Перед работой нужно заполнить шаблоны
- Шаблон для переменных ansible: ansible/all.yml.template
- Шаблон inventory ansible: ansible/inventory.yml.template

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
