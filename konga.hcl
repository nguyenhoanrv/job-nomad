job "konga" {
  datacenters = ["dc1"]

  group "konga" {
    count = 1
    network {
      mode = "bridge"
      port "konga" {
        to = 1337
      }
    }
    service {
      name = "konga"
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "kongdb"
              local_bind_port  = 5432
            }
          }
        }

      }
    }


    task "konga" {
      driver = "docker"
      env {
        DB_ADAPTER= "postgres"
        DB_HOST= "${NOMAD_UPSTREAM_IP_kongdb}"
        DB_PORT="${NOMAD_UPSTREAM_PORT_kongdb}"
        DB_USER= "kong"
        DB_PASSWORD="kong"
        TOKEN_SECRET= "km1GUr4RkcQD7DewhJPNXrCuZwcKmqjb"
        DB_DATABASE= "kongdb"
        NODE_ENV= "development"
      }

      config {
        image = "pantsel/konga:next"
        ports = ["konga"]
      }
      resources {
        cpu = 1000
        memory = 200
      }
    }
  }
}