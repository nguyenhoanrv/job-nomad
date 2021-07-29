job "authen" {
  datacenters = ["dc1"]

  group "db" {
    count = 1
    network {
      mode = "bridge"
    }
  
    service {
      name = "postgres"
      port = 5432
      
      connect {
        sidecar_service {}
      }
    }

    task "postgres" {
      driver = "docker"
      env {
        POSTGRES_USER="root"
        POSTGRES_PASSWORD="postgres"
        POSTGRES_DB="authen"
      }
      config {
        image = "postgres:12.7-alpine"
      }

     resources {
        cpu = 1000
        memory = 1024
        
      }
    }
  }

  group "authen" {
    count = 1
    network {
      mode = "bridge"
      port "authen-api" {
        to = 4000
      }
    }

    service {
      name = "authen"
      port = "authen-api"
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "postgres"
              local_bind_port  = 5432
            }
          }
        }
      }
    }

    task "authen" {
      driver = "docker"
      env {
        DB_HOST = "${NOMAD_UPSTREAM_IP_postgres}"
        DB_PORT = "${NOMAD_UPSTREAM_PORT_postgres}"
        DB_USERNAME = "root"
        DB_PASSWORD="postgres"
        DB_DATABASE="authen"
        DB_CONNECTION="postgres"
      }
      config {
        image = "registry.gitlab.com/nguyenhoanrv/test-authen:latest"
        auth {
          username = "nguyenhoanrv"
          password = "hoanprono1"
          server_address  = "registry.gitlab.com"
        }
        ports = ["authen-api"]
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
