#!/bin/bash
# Install a single node kubernetes cluster using kubeadm on Ubuntu 22.04

# Forwrding IPv4 and letting iptables see bridged traffic
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
# Apply sysctl params without reboot
sudo sysctl --system


# Disabling SWAP
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab


# Install containerd
# https://docs.docker.com/engine/install/ubuntu/
sudo mkdir -p /etc/apt/keyrings
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install containerd.io=1.6.15-1
sudo apt-mark hold containerd.io
# Fix if cri is disabled
sudo sed -i 's/^disabled_plugins = \["cri"\]/#&/' /etc/containerd/config.toml
sudo systemctl enable containerd
sudo systemctl start containerd
sudo systemctl restart containerd


# Install latest kubeadm, kubelet, and kubectl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/kubernetes-xenial.gpg
sudo apt-add-repository -y "deb http://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt update
sudo apt -y install kubeadm=1.26.6-00 kubelet=1.26.6-00 kubectl=1.26.6-00
sudo apt-mark hold kubelet kubeadm kubectl


# Run kubeadm init
# https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/
sudo kubeadm init --apiserver-advertise-address=$(hostname -I | awk '{print $1}')


# Make kubectl work for non-root user doing installation:
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


seconds=60
echo Sleeping for $seconds seconds.
sleep $seconds


# fixing kubectl tab completion and alias for user doing installation:
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc


# Install the weavenet network add-on:
# https://www.weave.works/docs/net/latest/kubernetes/kube-addon/
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml


# Untaint the Master Node
# https://stackoverflow.com/questions/43147941/allow-scheduling-of-pods-on-kubernetes-master
kubectl taint nodes `hostname` node-role.kubernetes.io/control-plane-


# tip to enable kubectl tab completion
echo You still need to log out and back in or run:
echo source ~/.bashrc
echo to enable kubectl completion for bash.
