job "test3" {
  datacenters = ["dc1"]

  group "db" {
    network {
      mode = "bridge"
    }
  
    service {
      name = "postgres"
      port = "5432"

      connect {
        sidecar_service {}
      }
    }

    task "postgres" {
      driver = "docker"
      config {
        image = "postgres"
      }

      env {
        POSTGRES_USER = "postgres"
        POSTGRES_PASSWORD="postgres"
        POSTGRES_DATABASE = "user-db"
      }

      resources {
        cpu    = 2000
        memory = 2000
      }
    }
  }

  group "frontend" {
    count = 1

    network {
      mode = "bridge"

      port "ingress" {
        static =   80 
        to     = 3000
      }
    }

    service {
      name = "nomadrepofe"
      port = "8000"

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

    task "frontend" {
      driver = "docker"
      config {
        image = "registry.gitlab.com/nguyenhoanrv/test-authen:latest"
        auth {
          username = "nguyenhoanrv"
          password = "hoanprono1"
          server_address  = "registry.gitlab.com"
        }
        // entrypoint = ["docker", "run", "-p", "5432:5432", "registry.gitlab.com/nguyenhoanrv/test-authen:latest"]
      }

      resources {
        cpu    = 2000
        memory =  500
      }
    }

//      task "initdb" {
//       lifecycle {
//         hook = "prestart"
//         sidecar = false
//       }

//       driver = "docker"
//       config {
//         image   = "registry.gitlab.com/nguyenhoanrv/test-authen:latest"
//         auth {
//           username = "nguyenhoanrv"
//           password = "hoanprono1"
//           server_address  = "registry.gitlab.com"
//         }
//         command = "/bin/bash"
//         args    = ["-c", "chmod +x local/initdb.sh && exec local/initdb.sh"]
//       }
//       template {
//         data = <<EOH
// #!/bin/sh
// echo "--> Waiting for envoy to start..."
// sleep 15
// # Use alloc index as jitter
// sleep {{ env "NOMAD_ALLOC_INDEX" }}
// echo "--> Initializing database..."
// PGPASSWORD=postgres psql -h localhost -U postgres -c 'CREATE DATABASE user-dbs;' || echo "Error code: $?"
// echo "==> Database initialized."
// EOH
//         destination   = "local/initdb.sh"
//         change_mode   = "noop"
//       }
//       resources {
//         cpu    =  500
//         memory =  500
//       }
//     }
  }
}
