resource "kubernetes_namespace" "nginx" {
  metadata {
    annotations = {
      name = "nginx"
    }

    labels = {
      app = "nginx"
    }

    name = "nginx"
  }
  depends_on = [helm_release.lbc]
}


resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "nginx-deployment"
    namespace = "nginx"
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          image = "nginx:latest"
          name  = "nginx"
          port {
            container_port = "80"
          }

        }
      }
    }
  }
  depends_on = [
    kubernetes_namespace.nginx
  ]
}

resource "kubernetes_service" "nginx" {
  metadata {
    annotations = {
      "alb.ingress.kubernetes.io/target-type" = "ip"
    }
    name      = "nginx-service"
    namespace = "nginx"
  }
  spec {
    selector = {
      app = "nginx"
    }
    session_affinity = "ClientIP"
    port {
      port        = 80
      target_port = 80
    }

    type = "NodePort"
  }
  depends_on = [kubernetes_deployment.nginx]

}

resource "kubernetes_ingress_v1" "nginx" {
  metadata {
    name      = "nginx-ingress"
    namespace = "nginx"
    annotations = {
      "kubernetes.io/ingress.class"      = "alb"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
    }
    labels = {
      "app" = "nginx"
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/"
          backend {
            service {
              name = "nginx-service"
              port {
                number = 80
              }
            }

          }


        }


      }
    }
  }
  depends_on = [kubernetes_service.nginx]
}