job "kongdb" {
  datacenters =["dc1"]
  group "kongdb" {
    count = 1
    network {
      mode = "bridge"
    }
  
    service {
      name = "kongdb"
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
        POSTGRES_DB="kongdb"
      }
      config {
        image = "postgres:9.6"
      }

     resources {
        cpu = 200
        memory = 200
        
      }
    }
  }

}