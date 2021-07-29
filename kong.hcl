job "gateway10" {
  datacenters = ["dc1"]

  group "kong-db" {
    count = 1
    network {
      mode = "bridge"
    }
  
    service {
      name = "kong-db"
      port = 5432
      connect {
        sidecar_service {}
      }
    }

    task "init-db" {
      driver = "docker"
      env {
        POSTGRES_USER="kong"
        POSTGRES_PASSWORD="kong"
        POSTGRES_DB="kong-db"
      }
      config {
        image = "postgres:9.6"
      }

     resources {
        cpu = 1000
        memory = 1024
        
      }
    }
  }

  group "kong" {
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
      name = "kong"
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

    // task "kong-migration" {
    //   driver = "docker"
    //   env {
    //       KONG_DATABASE="postgres"
    //       KONG_PG_DATABASE = "kong-db"
    //       KONG_PG_HOST= "${NOMAD_UPSTREAM_IP_kong-db}"
    //       KONG_PG_USER = "kong"
    //       KONG_PG_PASSWORD = "kong"
    //   }
    //   config {
    //     image = "kong:2.5.0-alpine"
    //     command = "kong kong migrations bootstrap"
    //   }

    //   resources {
    //     cpu    = 1000
    //     memory =  500
    //   }
      //  restart {
      //   attempts = 10
      //   interval = "5m"
      //   delay = "5s"
      //   mode = "delay"
      // }
    // }
    
    task "kong" {
      driver = "docker"
     
      env {
          KONG_PROXY_LISTEN= "0.0.0.0:8000, 0.0.0.0:8443 ssl"
          KONG_ADMIN_LISTEN= "0.0.0.0:8001, 0.0.0.0:8444 ssl"
          KONG_DATABASE="off"
          KONG_PROXY_ACCESS_LOG="/dev/stdout"
          KONG_ADMIN_ACCESS_LOG="/dev/stdout"
          KONG_PROXY_ERROR_LOG="/dev/stderr"
          KONG_ADMIN_ERROR_LOG="/dev/stderr" 
          // KONG_PG_DATABASE = "kong-db"
          // KONG_PG_HOST= "${NOMAD_UPSTREAM_IP_kong-db}"
          // KONG_PG_USER = "kong"
          // KONG_PG_PASSWORD = "kong"
          KONG_SSL = "on"
          KONG_SSL_CERT = "/certificate/cert.pem"
          KONG_SSL_CERT_KEY= "/certificate/key.pem"
          KONG_ADMIN_SSL_CERT= "/certificate/cert.pem"
          KONG_ADMIN_SSL_CERT_KEY= "/certificate/key.pem"

      }
      config {
        image = "kong:latest"
        volumes = ["/home/hoanbk/Documents/Nomad/certificate:/certificate"]
        ports = ["kong"]
      }

      resources {
        cpu    = 1000
        memory =  500
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
