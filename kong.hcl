job "gateway10" {
  datacenters = ["dc1"]

  group "kong" {
    count = 1
    network {
      mode = "bridge"
      // port "kong" {}
      port "test1" {
        // static = 8000
        to = 8000
      }
      port "test2" {
        to = 8001
      }
       port "test3" {
        to = 8443
      }
       port "test4" {
        to = 8444
      }
    }
    service {
      name = "kong"
      port = "test1"
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

    task "kong-migration" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }
      driver = "docker"
      env {
          KONG_DATABASE="postgres"
          KONG_PG_DATABASE = "kongdb"
          KONG_PG_HOST= "${NOMAD_UPSTREAM_IP_kongdb}"
          KONG_PG_PORT="${NOMAD_UPSTREAM_PORT_kongdb}"
          KONG_PG_USER = "kong"
          KONG_PG_PASSWORD = "kong"
      }
      config {
        image = "kong:latest"
        command = "/bin/bash"
        args = [
          "-c",
          "kong migrations bootstrap"
        ]
      }

      resources {
        cpu    = 1000
        memory =  600
      }
    }
    
    task "kong" {
      driver = "docker"
     
      env {
          KONG_PROXY_LISTEN= "0.0.0.0:8000, 0.0.0.0:8443 ssl"
          KONG_ADMIN_LISTEN= "0.0.0.0:8001, 0.0.0.0:8444 ssl"
          // KONG_DATABASE="off"
          // KONG_DECLARATIVE_CONFIG="/usr/local/kong/declarative/kong.yml"
          // KONG_PROXY_ACCESS_LOG="/dev/stdout"
          // KONG_ADMIN_ACCESS_LOG="/dev/stdout"
          // KONG_PROXY_ERROR_LOG="/dev/stderr"
          // KONG_ADMIN_ERROR_LOG="/dev/stderr" 
          KONG_PG_DATABASE = "kongdb"
          KONG_PG_HOST= "${NOMAD_UPSTREAM_IP_kongdb}"
          KONG_PG_PORT="${NOMAD_UPSTREAM_PORT_kongdb}"
          KONG_PG_USER = "kong"
          KONG_PG_PASSWORD = "kong"
          KONG_SSL = "on"
          KONG_SSL_CERT = "/certificate/cert.pem"
          KONG_SSL_CERT_KEY= "/certificate/key.pem"
          KONG_ADMIN_SSL_CERT= "/certificate/cert.pem"
          KONG_ADMIN_SSL_CERT_KEY= "/certificate/key.pem"

      }
      config {
        image = "kong:latest"
        volumes = ["/home/hoanbk/Documents/Nomad/certificate:/certificate"]
        // command="kong migrations bootstrap"
        ports = ["test2", "test1", "test3", "test4"]
      }

      resources {
        cpu    = 1000
        memory =  1000
      }
    }
  }

}
