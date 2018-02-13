# kube-terra-ex

An example that demonstrates creating deployments and services on an existing google cloud Kubernetes cluster using the terraform kubernetes provider.

### Requirements
  1. An existing gloud GKE cluster
  1. terraform installed
  1. gloud and its K8s requirements installed

### Credentials
Credentials for the Kubernetes provider are best retrieved from your ~/.kube directory. Before running terraform commands associate to the appropriate cluster
```
gcloud config set project 'your-project-id'
gcloud container clusters get-credentials 'cluster-name'

```
With the above, nothing is provided for cluster name or credentials in the provider block:
```
provider "kubernetes" {
}
```
