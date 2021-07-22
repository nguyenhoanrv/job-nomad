job "nomadrepo" {
  datacenters = ["dc1"]

  group "db" {
    network {
      mode = "bridge"
    }

    service {
      name = "nomadrepodb"
      port = "5432"
      connect {
        sidecar_service {}
      }
    }

    task "postgres" {
      driver = "docker"
      config {
        image = "postgres:13"
      }

      env {
        POSTGRES_PASSWORD="nomadrepo9000"
      }

      resources {
        cpu    = 2000
        memory = 2000
      }
    }
  }

  group "frontend" {
    count = 3
//  service {
//         # This tells Consul to monitor the service on the port
//         # labelled "http". Since Nomad allocates high dynamic port
//         # numbers, we use labels to refer to them.
//         port = "http"

//         check {
//           type     = "http"
//           path     = "/"
//           interval = "10s"
//           timeout  = "2s"
//         }
//       }
    // network {
    //   mode = "bridge"

    //   port "ingress" {
    //     static =   80 
    //     // to     = 8000
    //   }
    // }

    service {
      name = "nomadrepofe"
      port = "8000"
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "nomadrepodb"
              local_bind_port  = 5432
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

      }

      resources {
        cpu    = 2000
        memory =  500
      }
    }

//     task "initdb" {
//       lifecycle {
//         hook = "prestart"
//         sidecar = false
//       }

//       driver = "docker"
//       config {
//         image   = "schmichael/nomadrepo:0.5"
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
// PGPASSWORD=nomadrepo9000 psql -h localhost -U postgres -c 'CREATE DATABASE nomadrepo;' || echo "Error code: $?"
// echo "==> Database initialized."
// echo "--> Migrating database..."
// . /opt/venv/bin/activate && python nomadrepo/manage.py migrate || echo "Error code: $?"
// echo "==> Migrated database."
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
