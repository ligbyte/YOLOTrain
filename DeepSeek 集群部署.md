# DeepSeek 集群部署

## 1. 部署架构规划
首先，你需要决定集群的架构。一般来说，可以使用 **多节点集群**，其中包括多个计算节点、存储节点和管理节点。

- **计算节点**：用于运行 DeepSeek 模型的推理或训练任务。
- **存储节点**：用于存储数据、模型和输出结果。
- **管理节点**：用于管理和调度任务（如使用 Kubernetes）。

## 2. 系统要求
集群的计算节点和存储节点需要满足以下要求：

- **操作系统**：推荐使用 **Ubuntu 20.04** 或 **Ubuntu 22.04**，支持深度学习库和 NVIDIA 驱动。
- **硬件要求**：
  - **GPU**：建议使用 NVIDIA GPU（如 RTX 30 系列、A100 等），支持 **CUDA** 和 **cuDNN**。
  - **CPU**：高性能的多核处理器（如 Intel Xeon 或 AMD Ryzen）。
  - **内存**：每台计算节点建议至少 **32GB RAM**，大规模训练需要更多内存。
  - **存储**：使用 **SSD** 存储（至少 **1TB SSD**）用于快速数据加载。
- **网络**：确保集群中各节点之间有高速的网络连接。

## 3. 安装环境与依赖

### 1) 安装 NVIDIA 驱动与 CUDA
在所有计算节点上安装 **NVIDIA 驱动** 和 **CUDA**：

```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装 NVIDIA 驱动
sudo apt install nvidia-driver-460

# 安装 CUDA 和 cuDNN
sudo apt install nvidia-cuda-toolkit
sudo apt install libcudnn8
```


2) 安装 Docker
为了简化部署和管理，推荐使用 Docker 来容器化 DeepSeek 的服务：

```shell
# 安装 Docker
sudo apt-get update
sudo apt-get install docker.io

# 启动 Docker 服务
sudo systemctl enable --now docker

# 配置 Docker 运行 DeepSeek
sudo groupadd docker
sudo usermod -aG docker $USER
``` 

3) 安装 DeepSeek 依赖
DeepSeek 的依赖包括一些深度学习框架（如 TensorFlow、PyTorch）和其他必要的库。假设使用 Docker 容器部署：
```shell
# 拉取 DeepSeek 镜像
docker pull deepseek/deepseek:latest

# 运行 DeepSeek 容器
docker run --gpus all -it deepseek/deepseek:latest bash
```

# 4. 配置分布式部署
1) 配置任务调度（Kubernetes）
Kubernetes 是一个容器编排工具，可以用来在多个节点上调度和管理任务。你可以使用 Kubernetes 集群来管理 DeepSeek 的分布式部署。

安装 Kubernetes（需要在所有计算节点上安装）：
```shell
# 安装 Kubernetes
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

# 添加 Kubernetes GPG 密钥
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# 添加 Kubernetes 仓库
sudo sh -c 'echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list'

# 更新并安装 kubeadm, kubelet 和 kubectl
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

# 禁用 swap 分区
sudo swapoff -a
```

2) 初始化 Kubernetes 集群
在 主节点（Master Node）上初始化 Kubernetes 集群：
```shell
# 初始化 Kubernetes 集群
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# 配置 kubectl 使用当前集群
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

```
在 工作节点（Worker Node）上加入集群：
```shell
# 加入 Kubernetes 集群（命令在主节点 kubeadm init 输出中）
kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

3) 部署 Pod 网络插件
安装网络插件（如 Flannel 或 Calico）来连接集群中的所有节点：
```shell
# 安装 Flannel 网络插件
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

4) 部署 DeepSeek 服务
创建 Kubernetes 配置文件，定义 DeepSeek 的容器化服务（可以使用 Kubernetes 的 Deployment 或 StatefulSet 进行管理）。

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deepseek-deployment
spec:
  replicas: 3  # 设置副本数
  selector:
    matchLabels:
      app: deepseek
  template:
    metadata:
      labels:
        app: deepseek
    spec:
      containers:
      - name: deepseek
        image: deepseek/deepseek:latest
        resources:
          limits:
            memory: "8Gi"
            cpu: "4"
        ports:
        - containerPort: 8080

```

```shell
# 应用部署配置
kubectl apply -f deepseek-deployment.yaml

```

5) 配置 GPU 支持（如果有 GPU）
在 Kubernetes 上配置 NVIDIA GPU 支持，以便深度学习任务可以在 GPU 上运行。

安装 NVIDIA GPU 插件：
```shell
# 安装 NVIDIA Device Plugin
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.11.0/nvidia-device-plugin.yml

```

5. 数据存储与共享
为了在多个计算节点之间共享数据，使用分布式文件系统（如 Ceph、NFS 或 GlusterFS）来存储和共享数据。

安装 NFS：
```shell
# 安装 NFS 服务器
sudo apt install nfs-kernel-server

# 配置 NFS 共享目录
sudo mkdir -p /mnt/deepseek_data
sudo chown nobody:nogroup /mnt/deepseek_data
sudo chmod 777 /mnt/deepseek_data
sudo echo "/mnt/deepseek_data *(rw,sync,no_subtree_check)" >> /etc/exports

# 启动 NFS 服务
sudo systemctl restart nfs-kernel-server

```

在其他节点挂载 NFS 共享目录：
```
sudo mount -t nfs <nfs-server-ip>:/mnt/deepseek_data /mnt/deepseek_data
```


6. 集群监控和管理
为了监控和管理 DeepSeek 集群，你可以使用以下工具：

Prometheus + Grafana：监控集群的资源使用情况。
Kubectl：用于管理和查看 Kubernetes 集群。
NVIDIA DCGM：监控 GPU 使用情况。
7. 集群自动化和负载均衡
可以使用 Kubernetes 内置的自动扩展（Horizontal Pod Autoscaler）来自动扩展计算资源，保证在负载增加时动态调整计算节点数量。同时，配置负载均衡（如 NGINX Ingress Controller）来分发请求。

总结
部署 DeepSeek 集群 涉及以下几个关键步骤：

硬件要求：选择适合深度学习的硬件（如 GPU、CPU、内存、存储）。
环境配置：安装必要的驱动和依赖，使用 Docker 容器化 DeepSeek 服务。
集群管理：使用 Kubernetes 部署和管理集群，配置节点间的网络和存储共享。
性能优化：通过 GPU 支持和自动扩展确保集群的高效运行。
通过使用集群部署，你可以充分利用多个节点的计算资源，实现更高效的训练和推理任务。
