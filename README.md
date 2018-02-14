# kube-terra-ex

An example that demonstrates creating deployments and services on an existing google cloud kubernetes cluster using the terraform kubernetes provider. This example builds on gke-terra-ex where the cluster itself is provisioned.

The general thinking is that the gke-terra-ex project provides our 'infrastrcture-as-a-service' layer where terraform manages the gcloud gke cluster creation and management. This project then adds the 'application infrastructure' layer using the kubernetes provider to create deployments and services.

### Requirements
  1. An existing gloud GKE cluster
  1. terraform installed
  1. gloud and its K8s requirements installed
  1. This project uses the secrets file described in gke-terra-ex

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
### Kubernetes Namespaces
This project creates two namespaces, development and production. A variable for namespace is provided and it defaults to 'development'. The deployment and service described below then create the workloads within the development namespace.

### Kubernetes Deployments and Replica Sets / Controllers
This example demonstrates using terraform to create an initial deployment for a simple container-based application. It uses a basic 'hello-world' node application. The basic code is shown below:
```
resource "kubernetes_replication_controller" "hello-web" {
  metadata {
    name = "hello-web"
    namespace = "${var.namespace}"    
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
The current terraform provider only provides a replication controller resource whereas the current standard is to use a 'deployment' resource but this is a recent change. The replication controller is basically the same. It provides a template for a 'pod' and ensures the required number of instances are made available.

### Kubernetes Services
Deployments are exposed to via a Kubernetes service that basically creates a load-balance in front of a series of pod instances. The code below demonstrates attaching this service to our RC noted above:
```
resource "kubernetes_service" "hello-web" {
  metadata {
    name = "hello-web"
    namespace = "${var.namespace}"    
  }
  spec {
    selector {
      app = "${kubernetes_replication_controller.hello-web.metadata.0.labels.app}"
    }
    session_affinity = "ClientIP"
    port {
      port = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}
```
### Building the Application RCs and Services
Running the terraform plan and apply goes something is the same as described in the cluster build project:
```
terraform plan \
 -var-file="~/.gcloud/gke-secrets.tfvars"
```
