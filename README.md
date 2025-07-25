# Kubetask

Kubetask is a simple Kubernetes application deploying an Nginx web server with its storage backed by an NFS (Network File System) volume. This repository provides the necessary configuration files to set up the application using Kubernetes and Kustomize.

## Prerequisites

Before you begin, ensure you have the following installed:
- [Git](https://git-scm.com/) to clone the repository
- [kubectl](https://kubernetes.io/docs/tasks/tools/) to interact with your Kubernetes cluster
- [Kustomize](https://kustomize.io/) (or use `kubectl` with Kustomize integration, available in `kubectl` v1.14+)
- A Kubernetes cluster (e.g., Minikube, Kind, or a cloud provider like GKE, EKS, or AKS)
- An NFS server configured and accessible within your network
- `kubectl` configured to communicate with your cluster

## Getting Started

Follow these steps to clone the repository, set up the NFS storage, and deploy the application.

### 1. Clone the Repository

Clone the `kubetask` repository to your local machine:

```bash
git clone https://github.com/ronthesoul/kubetask.git
cd kubetask
```

Run the `nfs-setup.sh` script to automate the NFS server setup:

```bash
chmod +x nfs-setup.sh
./nfs-setup.sh
```

The `nfs-setup.sh` script performs the following tasks:
- Downloads and installs the NFS server package.
- Creates a shared directory at the default path: `/src/nfs/shared`.
- Generates a template `index.html` file in the shared directory.
- Exports the NFS share and restarts the NFS service automatically.

> **Note**: Ensure you have sufficient permissions (e.g., `sudo`) to run the script, as it modifies system configurations. Verify that the NFS server is accessible from your Kubernetes cluster after setup.

### 2. Configure NFS Storage

The application uses an NFS volume for persistent storage. Ensure your NFS server is running and accessible. Update the NFS configuration in the Kubernetes manifest files (e.g., `nfs-pv.yaml` or similar) with your NFS server details.

#### Example NFS Configuration

Assuming a file named `nfs-pv.yaml` exists in the repository, it might look like this:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: <your-nfs-server-ip>
    path: "/exports"
```

Update `<your-nfs-server-ip>` and `/exports` to match your NFS server's IP address and shared directory path. Apply the NFS configuration:

```bash
kubectl apply -f nfs-pv.yaml
kubectl apply -f nfs-pvc.yaml
```

> **Note**: Ensure the NFS server is reachable from your Kubernetes cluster, and the NFS share is properly exported with appropriate permissions.

### 3. Apply the Kustomize Script

The repository uses Kustomize to manage Kubernetes manifests. To deploy the Nginx application with NFS storage, run the following command from the repository root:

```bash
kubectl apply -k .
```

This command uses the `kustomization.yaml` file to apply all resources defined in the repository, including the Nginx deployment, service, and NFS-backed PersistentVolumeClaim (PVC).

> **Note**: If you need to customize the deployment (e.g., change the namespace or NFS paths), edit the `kustomization.yaml` file or the referenced manifests before applying.

### 4. Verify the Deployment

Check that the Nginx pod is running:

```bash
kubectl get pods
```

Verify the service is accessible (assuming a `ClusterIP` or `NodePort` service is defined):

```bash
kubectl get services
```

If using a `NodePort` service, access the Nginx application via the node's IP and the assigned port. For example:

```bash
curl http://<node-ip>:<node-port>
```

### 5. Cleaning Up

To remove the deployed resources:

```bash
kubectl delete -k .
```

This deletes all resources defined in the `kustomization.yaml` file.

## Project Structure

Below is the directory structure of the `kubetask` repository:

```
kubetask/
├── base/
│   ├── deployment.yaml       # Nginx deployment configuration
│   ├── service.yaml          # Service configuration for Nginx
│   ├── nfs-pv.yaml           # PersistentVolume for NFS
│   ├── nfs-pvc.yaml          # PersistentVolumeClaim for NFS
│   └── kustomization.yaml    # Kustomize configuration for base resources
├── overlays/
│   ├── dev/
│   │   └── kustomization.yaml  # Optional: Dev environment customizations
│   └── prod/
│       └── kustomization.yaml  # Optional: Prod environment customizations
└── kustomization.yaml        # Root Kustomize configuration
```

### File Descriptions

- **base/deployment.yaml**: Defines the Nginx deployment, mounting the NFS volume.
- **base/service.yaml**: Exposes the Nginx application via a Kubernetes service.
- **base/nfs-pv.yaml**: Configures the PersistentVolume for the NFS share.
- **base/nfs-pvc.yaml**: Defines the PersistentVolumeClaim to request NFS storage.
- **base/kustomization.yaml**: Kustomize configuration referencing the base resources.
- **overlays/**: Optional environment-specific customizations (e.g., `dev` or `prod`).
- **kustomization.yaml**: Root Kustomize file for applying resources.

## Troubleshooting

- **NFS Connection Issues**: Ensure the NFS server is running, the share is exported, and the Kubernetes nodes can reach the NFS server IP. Check firewall rules and NFS export permissions.
- **Pod Not Starting**: Verify the PVC is bound (`kubectl get pvc`) and check pod logs (`kubectl logs <pod-name>`).
- **Kustomize Errors**: Ensure the `kustomization.yaml` file references valid resources and that all required files exist.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request on the [GitHub repository](https://github.com/ronthesoul/kubetask) for bug fixes, improvements, or new features.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.