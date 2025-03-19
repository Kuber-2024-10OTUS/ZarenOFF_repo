#!/bin/bash

set -e

K8S_VERSION="1.31"

echo "Установка containerd..."
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update && sudo apt-get install -y containerd.io

sudo mkdir -p /etc/containerd/
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo systemctl restart containerd

echo "Установка kubeadm, kubelet, kubectl..."
curl -fsSL https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable --now kubelet

echo "Установка компонентов Kubernetes завершена!"

if [ "$1" = "master" ]; then
    echo "Инициализация кластера Kubernetes..."
    sudo kubeadm init --pod-network-cidr 10.244.0.0/16

    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    kubectl create -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

    echo "Кластер Kubernetes успешно инициализирован!"
    echo "Для подключения worker-нод используйте команду, выведенную выше."
else
    echo "Для инициализации мастер-ноды запустите скрипт с параметром 'master':"
    echo "  $0 master"
fi