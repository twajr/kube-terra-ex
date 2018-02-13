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
### Kubernetes Deployments and Replica Sets
This example demonstrates using terraform to create an initial deployment for a simple container-based application. It uses a basic 'hello-world' node application. The basic code is shown below:
```
resource "kubernetes_replication_controller" "hello-web" {
  metadata {
    name = "hello-web"
    labels {
      app = "hello-web"
    }
  }

  spec {
    selector {
      app = "hello-web"
    }
    template {
      container {
        image = "gcr.io/onehq-192515/hello-app:v1"
        name  = "hello-web"
        port {
          container_port = 8080
        }
        resources{
          limits{
            cpu    = "0.5"
            memory = "512Mi"
          }
          requests{
            cpu    = "250m"
            memory = "50Mi"
          }
        }
      }
    }
  }
}
```
