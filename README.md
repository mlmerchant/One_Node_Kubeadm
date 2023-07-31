# Kubernetes Single Node Cluster Setup Script

This bash script will guide you on how to set up a single node Kubernetes cluster using kubeadm on Ubuntu 22.04. The script includes several steps like:

1. Forwarding IPv4 and allowing iptables to see bridged traffic.
2. Disabling swap on the system.
3. Installing containerd as the container runtime.
4. Installing the latest version of kubeadm, kubelet, and kubectl.
5. Initiating kubeadm.
6. Setting up the .kube configuration for the current user.
7. Installing Weave Net as the network add-on.
8. Removing the control-plane taint from the master node.

## Pre-requisites

This script assumes that you have a Ubuntu 22.04 LTS system with administrative privileges. 

## Usage

Save the above bash script in a file, give it execute permission and then run the script.

```bash
# Give execution permissions
chmod +x install.sh

# Execute the script
./install.sh
```

After running the script, you need to either log out and back in, or run the following command to enable kubectl completion for bash.

```bash
source ~/.bashrc
```

## Notes

This script sets up a single node Kubernetes cluster. The master node in this setup is untainted, allowing pods to be scheduled on it. This is not a recommended setup for a production environment, but it can be useful for learning, testing or development purposes.

## Disclaimer

Use this script at your own risk. Please understand that it makes changes to the system settings and installs several packages. Make sure you understand what each command in the script does before running it.

## References

- [Kubernetes Setup](https://kubernetes.io/docs/setup/)
- [Weave Net for Kubernetes Add-ons](https://www.weave.works/docs/net/latest/kubernetes/kube-addon/)
