job "test27" {
  datacenters = ["dc1"]

  group "db" {
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
      config {
        image = "postgres:12.7-alpine"
      }

      env {
        POSTGRES_USER = "root"
        POSTGRES_PASSWORD=""
      }

      resources {
        cpu    = 2000
        memory = 2000
      }
    }
  }

  group "authen" {
    count = 1

    network {
      mode = "bridge"

      port "ingress" {
        static =   3000 
        to     = 3000
      }
    }

    service {
      name = "authen"
      port = "3000"

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
        DB_PASSWORD=""
        DB_DATABASE="authen"
      }
      config {
        image = "registry.gitlab.com/nguyenhoanrv/test-authen:latest"
        auth {
          username = "nguyenhoanrv"
          password = "hoanprono1"
          server_address  = "registry.gitlab.com"
        }
      }

      resources {
        cpu    = 2000
        memory =  1000
      }
    }
  }
}
