job "demo-webapp" {
  datacenters = ["[[ .datacenter ]]"]

constraint {
  operator = "!="
  attribute = "${node.unique.name}"
  value = "metal1"
}

  group "demo" {
    count = 2

    network {
      port "http" {
        to = -1
      }
    }

    service {
      name = "demo-webapp"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.myapp.rule=Host(`myapp.[[ .lantld ]]`)",
        "traefik.http.routers.myapp.entrypoints=web",
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "2s"
        timeout  = "2s"
      }
    }

    task "server" {
      env {
        PORT    = "${NOMAD_PORT_http}"
        NODE_IP = "${NOMAD_IP_http}"
      }

      driver = "docker"

      config {
        image = "hashicorp/demo-webapp-lb-guide"
        ports = ["http"]
      }
    }
  }
}