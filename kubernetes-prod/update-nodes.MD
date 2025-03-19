### Подготовка

На каждой ноде кластера (master и worker) обновляем репозиторий:

```bash
sudo sed -i 's/v1.31/v1.32/g' /etc/apt/sources.list.d/kubernetes.list

sudo apt update
```

Определяем доступную версию kubeadm

```bash
sudo apt-cache madison kubeadm
```


### Обновление Control Plane 

1. **Обновляем kubeadm:**

   ```bash
   sudo apt-mark unhold kubeadm && \
   sudo apt-get update && sudo apt-get install -y kubeadm='1.32.3-1.1' && \
   sudo apt-mark hold kubeadm
   ```

2. **Проверяем версию kubeadm:**

   ```bash
   kubeadm version
   ```

3. **Проверяем план обновления:**

   ```bash
   sudo kubeadm upgrade plan
   ```

4. **Применяем обновление:**

   ```bash
   sudo kubeadm upgrade apply v1.32.3
   ```

5. **Подготовливаем ноду к обновлению kubelet и kubectl:**

   ```bash
   kubectl drain k8s-master --ignore-daemonsets
   ```

6. **Обновляем kubelet и kubectl:**

   ```bash
   sudo apt-mark unhold kubelet kubectl && \
   sudo apt-get update && sudo apt-get install -y kubelet='1.32.3-1.1' kubectl='1.32.3-1.1' && \
   sudo apt-mark hold kubelet kubectl
   ```

7. **Перезапускаем kubelet:**

   ```bash
   sudo systemctl daemon-reload && \
   sudo systemctl restart kubelet
   ```

8. **Возвращаем ноду:**

   ```bash
   kubectl uncordon k8s-master
   ```

### Обновление Worker нод

Повторяем следующие шаги для каждой worker ноды по очереди:

1. **Обновляем kubeadm на worker ноде:**

   ```bash
   sudo apt-mark unhold kubeadm && \
   sudo apt-get update && sudo apt-get install -y kubeadm='1.32.3-1.1' && \
   sudo apt-mark hold kubeadm
   ```

2. **Применяем обновление конфигурации:**

   ```bash
   sudo kubeadm upgrade node
   ```

3. **На master ноде подготовливаем worker ноду к обновлению:**

   ```bash
   kubectl drain <имя-worker-ноды> --ignore-daemonsets
   ```


4. **Обновляем kubelet и kubectl:**

   ```bash
   sudo apt-mark unhold kubelet kubectl && \
   sudo apt-get update && sudo apt-get install -y kubelet='1.32.3-1.1' kubectl='1.32.3-1.1' && \
   sudo apt-mark hold kubelet kubectl
   ```

5. **Перезапускаем kubelet на worker ноде:**

   ```bash
   sudo systemctl daemon-reload && \
   sudo systemctl restart kubelet
   ```

6. **Возвращаем ноду:**

   ```bash
   kubectl uncordon <имя-worker-ноды>
   ```

7. **Повторяем шаги 1-6 для каждой worker ноды.**
