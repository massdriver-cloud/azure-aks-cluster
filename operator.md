### Azure AKS (Azure Kubernetes Service)

Azure AKS (Azure Kubernetes Service) is a managed Kubernetes service that makes it easy to deploy, manage, and scale containerized applications using Kubernetes. AKS takes care of the heavy lifting of cluster management and provides features to enhance operational efficiency.

### Design Decisions

1. **Azure Policy**: Enabling Azure Policy ensures compliance and governance across the AKS resources.
2. **RBAC and AAD Integration**: Role-Based Access Control (RBAC) combined with Azure Active Directory (AAD) integration ensures secure access and management.
3. **Automatic Upgrade**: Clusters are set to stable automatic channel upgrade to ensure they are up-to-date with the latest stable features.
4. **Log Analytics**: Integration with Azure Log Analytics to provide monitoring and logging capabilities.
5. **Auto-scaling**: Both default and additional node pools are configured with auto-scaling capabilities to manage workloads efficiently.
6. **Networking**: The networking profile uses the `azure` network plugin and policy to integrate seamlessly with Azure's ecosystem.

### Connecting

After you have deployed a Kubernetes cluster through Massdriver, you may want to interact with the cluster using the powerful [kubectl](https://kubernetes.io/docs/reference/kubectl/) command line tool.

#### Install Kubectl

You will first need to install `kubectl` to interact with the kubernetes cluster. Installation instructions for Windows, Mac and Linux can be found [here](https://kubernetes.io/docs/tasks/tools/#kubectl).

Note: While `kubectl` generally has forwards and backwards compatibility of core capabilities, it is best if your `kubectl` client version is matched with your kubernetes cluster version. This ensures the best stability and compability for your client.


The standard way to manage connection and authentication details for kubernetes clusters is through a configuration file called a [`kubeconfig`](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) file.

#### Download the Kubeconfig File

The standard way to manage connection and authentication details for kubernetes clusters is through a configuration file called a [`kubeconfig`](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) file. The `kubernetes-cluster` artifact that is created when you make a kubernetes cluster in Massdriver contains the basic information needed to create a `kubeconfig` file. Because of this, Massdriver makes it very easy for you to download a `kubeconfig` file that will allow you to use `kubectl` to query and administer your cluster.

To download a `kubeconfig` file for your cluster, navigate to the project and target where the kubernetes cluster is deployed and move the mouse so it hovers over the artifact connection port. This will pop a windows that allows you to download the artifact in raw JSON, or as a `kubeconfig` yaml. Select "Kube Config" from the drop down, and click the button. This will download the `kubeconfig` for the kubernetes cluster to your local system.

![Download Kubeconfig](https://github.com/massdriver-cloud/azure-aks-cluster/blob/main/images/kubeconfig-download.gif?raw=true)

#### Use the Kubeconfig File

Once the `kubeconfig` file is downloaded, you can move it to your desired location. By default, `kubectl` will look for a file named `config` located in the `$HOME/.kube` directory. If you would like this to be your default configuration, you can rename and move the file to `$HOME/.kube/config`.

A single `kubeconfig` file can hold multiple cluster configurations, and you can select your desired cluster through the use of [`contexts`](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/#context). Alternatively, you can have multiple `kubeconfig` files and select your desired file through the `KUBECONFIG` environment variable or the `--kubeconfig` flag in `kubectl`.

Once you've configured your environment properly, you should be able to run `kubectl` commands.

### Runbook

#### Unable to Connect to AKS

If you encounter connectivity issues with your AKS cluster:

Use `kubectl` to check the cluster nodes' status.

```sh
kubectl get nodes
```

Ensure the nodes are all in a "Ready" state.

```sh
kubectl describe node <node-name>
```

Check for events or descriptions that might indicate issues.

#### Pod Not Starting

If a pod is stuck in `Pending` or `CrashLoopBackOff`:

Describe the pod to check for detailed error messages.

```sh
kubectl describe pod <pod-name>
```

Look into the events section for reasons like insufficient resources or failed image pulls.

Check the logs of the pod to understand why it is crashing.

```sh
kubectl logs <pod-name>
```

#### DNS Resolution Not Working

If the applications inside the cluster have DNS issues:

Check if the CoreDNS pod is running correctly.

```sh
kubectl get pods -n kube-system -l k8s-app=kube-dns
```

If CoreDNS is running, describe the CoreDNS pod to check for issues.

```sh
kubectl describe pod <coredns-pod-name> -n kube-system
```

#### AKS Cluster Scaling Issues

If your cluster seems not to scale pods correctly:

Check the cluster autoscaler logs.

```sh
kubectl -n kube-system logs -l component=cluster-autoscaler
```

Identify if there are any errors or warnings that prevent scaling events from being processed.

#### Permissions and Roles Issue

If users are having trouble accessing resources:

List current role bindings.

```sh
kubectl get rolebinding --all-namespaces
```

Describe a particular role binding to verify its settings.

```sh
kubectl describe rolebinding <rolebinding-name> -n <namespace>
```

#### Checking Azure AD Integration

If there are authentication issues via Azure AD:

Verify the AKS cluster's AAD integration status.

```sh
az aks show --resource-group <resource-group> --name <aks-cluster> --query "enableAzureRBAC"
```

Ensure it returns `true` if you have RBAC configured.

#### Checking Cluster Metrics & Logs

To check metrics and logs if Azure Monitor is configured:

Use Azure CLI to query logs in Log Analytics workspace.

```sh
az monitor log-analytics query -w <workspace-id> --analytics-query "KubePodInventory | summarize count() by ClusterId, Computer"
```

This returns a summary of pod counts by cluster and node.

#### Certificate Issues

For issues with cert-manager in obtaining certificates:

Describe the certificate request:

```sh
kubectl describe certificaterequest <certificaterequest-name>
```

Check If the challenge is failing:

```sh
kubectl describe challenge <challenge-name>
```

This should provide details on why the validation is failing, such as DNS issues or misconfiguration.

