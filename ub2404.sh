#!/bin/bash -e

echo
echo "=== MikroTik 7 Installer ==="
echo
sleep 3

# Скачивание образа CHR
wget https://download.mikrotik.com/routeros/7.15.3/chr-7.15.3.img.zip -O chr.img.zip
if [ $? -ne 0 ]; then
    echo "Ошибка: не удалось скачать образ CHR."
    exit 1
fi

# Распаковка образа
gunzip -c chr.img.zip > chr.img
if [ $? -ne 0 ]; then
    echo "Ошибка: не удалось распаковать образ CHR."
    exit 1
fi

# Определение устройства хранения (SSD/HDD)
STORAGE=$(lsblk -dn -o NAME,TYPE | grep -w "disk" | head -n 1 | awk '{print $1}')
if [ -z "$STORAGE" ]; then
    echo "Ошибка: не удалось определить устройство хранения."
    exit 1
fi
echo "STORAGE is $STORAGE"

# Определение активного сетевого интерфейса
ETH=$(ip route show default | awk '/default/ {print $5}')
if [ -z "$ETH" ]; then
    echo "Ошибка: не удалось определить сетевой интерфейс."
    exit 1
fi
echo "ETH is $ETH"

# Получение IP-адреса
ADDRESS=$(ip addr show $ETH | grep 'inet ' | awk '{print $2}' | head -n 1)
if [ -z "$ADDRESS" ]; then
    echo "Ошибка: не удалось получить IP-адрес."
    exit 1
fi
echo "ADDRESS is $ADDRESS"

# Получение шлюза по умолчанию
GATEWAY=$(ip route show default | awk '/default/ {print $3}')
if [ -z "$GATEWAY" ]; then
    echo "Ошибка: не удалось получить шлюз по умолчанию."
    exit 1
fi
echo "GATEWAY is $GATEWAY"

sleep 5

# Запись образа на устройство хранения
echo "Запись образа на диск /dev/$STORAGE..."
dd if=chr.img of=/dev/$STORAGE bs=4M oflag=sync status=progress
if [ $? -ne 0 ]; then
    echo "Ошибка: не удалось записать образ на устройство хранения."
    exit 1
fi

echo "Установка завершена. Перезагрузка системы..."
echo 1 > /proc/sys/kernel/sysrq
echo b > /proc/sysrq-trigger
