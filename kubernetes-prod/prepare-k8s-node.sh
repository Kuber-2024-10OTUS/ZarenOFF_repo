#!/bin/bash

set -e

echo "Отключение swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

echo "Настройка маршрутизации между интерфейсами..."
echo "net.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/10-k8s.conf
sudo sysctl -f /etc/sysctl.d/10-k8s.conf

echo "Проверка настройки маршрутизации..."
sysctl net.ipv4.ip_forward

echo "Настройка автозагрузки модулей ядра..."
printf "%s\n" "overlay" "br_netfilter" | sudo tee /etc/modules-load.d/k8s.conf
sudo modprobe overlay
sudo modprobe br_netfilter

echo "Проверка загрузки модулей..."
lsmod | grep -i -E 'br_netfilter|overlay'

echo "Подготовка ноды завершена успешно!"