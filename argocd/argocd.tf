terraform {
  required_version = ">= 1.1.0"

  required_providers {

    argocd = {
      source  = "oboukili/argocd"
      version = "~> 3.0.0"
    }
  }

}

provider "argocd" {
  server_addr = "localhost:8080"
  insecure = true

}
## nginx app
resource "argocd_application" "nginx-app" {
  metadata {
    name      = "nginx-app"
    namespace = "argocd"
    labels = {
      test = "true"
    }
  }

  spec {
    project = "default"

    source {
      repo_url        = "https://github.com/yasmeen-ahmed/task"
      path            = "nginx"
      target_revision = "master"

    }

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "nginx"
    }
    }

    #depends_on = [aws_eks_node_group.node-group]
  }


## api-app
  resource "argocd_application" "api-app" {
    metadata {
      name      = "api-app"
      namespace = "argocd"
      labels = {
        test = "true"
      }
    }

    spec {
      project = "default"

      source {
        repo_url        = "https://github.com/yasmeen-ahmed/task"
        path            = "api-app"
        target_revision = "master"

      }

      destination {
        server    = "https://kubernetes.default.svc"
        namespace = "echoserver"
      }
      }
    #depends_on = [aws_eks_node_group.node-group]
    }
