job "konga" {
  datacenters = ["dc1"]

  group "konga" {
    count = 1
    network {
      mode = "bridge"
      // port "kong" {}
      port "konga" {
        to = 1337
      }
    }
    // volume "certificate" {
    //   type      = "host"
    //   source    = "certificate"
    // }
    service {
      name = "konga"
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "kong-db"
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
          DB_HOST= "${NOMAD_UPSTREAM_IP_kong-db}"
          DB_PORT="${NOMAD_UPSTREAM_PORT_kong-db}"
          DB_USER= "kong"
          DB_PASSWORD="kong"
          TOKEN_SECRET= "km1GUr4RkcQD7DewhJPNXrCuZwcKmqjb"
          DB_DATABASE= "kong-db"
          NODE_ENV= "development"
        }

        config {
          image = "pantsel/konga:next"
          ports = ["konga"]
        }
    }
  }
}