job "db" {
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

    }
  }
}