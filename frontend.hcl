job "frontend" {
  datacenters = ["dc1"]

  group "frontend" {
    count = 1
    network {
      mode = "bridge"
      port "web" {
        to = 3000
      }
    }
    service {
      name = "frontend"
      port = "web"
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "authen"
              local_bind_port  = 4000
            }
          }
        }
      }
    }

    task "frontend" {
      driver = "docker"
      env {
        KONG_URL= "${NOMAD_UPSTREAM_ADDR_authen}"
      }
      config {
        image = "registry.gitlab.com/nguyenhoanrv/test-front-end:latest"
        auth {
          username = "nguyenhoanrv"
          password = "hoanprono1"
          server_address  = "registry.gitlab.com"
        }
        ports =["web"]
      }

      resources {
        cpu    = 4000
        memory =  1000
      }
      //  restart {
      //   attempts = 10
      //   interval = "5m"
      //   delay = "5s"
      //   mode = "delay"
      // }
    }
      
  }

}
