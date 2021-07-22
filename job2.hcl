job "test15" {
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
        POSTGRES_PASSWORD="postgres"
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
    count = 2

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
              local_bind_port  = 5433
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
        DB_DATABASE="authen1"
        DB_CONNECTION="postgres"
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
