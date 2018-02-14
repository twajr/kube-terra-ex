

variable "project_name" {}
variable "namespace" {}

provider "kubernetes" {
}

resource "kubernetes_namespace" "development" {
  metadata {
    name = "development"
  }
}
resource "kubernetes_namespace" "production" {
  metadata {
    name = "production"
  }
}

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
