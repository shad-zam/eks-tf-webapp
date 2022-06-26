resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx-deployment"
    namespace = "default"
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
  depends_on = [helm_release.lbc]
}

resource "kubernetes_service" "nginx" {
  metadata {
    annotations = {
        "alb.ingress.kubernetes.io/target-type" = "ip"  
    }
    name = "nginx-service"
    namespace = "default"
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
    namespace = "default"
    annotations = {
      "kubernetes.io/ingress.class"           = "alb"
      "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
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

output "load_balancer_hostname" {
  value = kubernetes_ingress_v1.nginx.status.0.load_balancer.0.ingress.0.hostname
}