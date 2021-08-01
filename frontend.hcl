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
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "kong"
              // local_bind_port  = 8000
            }
          }
        }
      }
    }

    task "frontend" {
      driver = "docker"
      env {
        REACT_APP_KONG_URL= "${NOMAD_ADDR_web}"
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
        cpu    = 800
        memory =  800
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
