job "sickrage" {
  type = "service"
  datacenters = ["lhr-armhf"]
  update {
    stagger      = "30s"
    max_parallel = 1
  }

  group "webs" {
    count = 1

    ephemeral_disk {
      migrate = true
      size    = "500"
      sticky  = true
    }

    task "frontend" {
      driver = "docker"

      config {
        image = "ncorrare/sickrage-armhf:c568139"
        #network_mode = "public"
        port_map {
          http = 8081
        }
        volumes = [
          "/opt/sickrage/data:/data",
          "/opt/sickrage/data/sickrage:/config"
        ] 
      }

      service {
        port = "http"
        name = "sickrage"

        check {
          type     = "http"
          path     = "/home/status/"
          interval = "10s"
          timeout  = "2s"
        }
      }

      # Specify the maximum resources required to run the job,
      # include CPU, memory, and bandwidth.
      resources {
        cpu    = 500 # MHz
        memory = 256 # MB

        network {
          mbits = 20

          # This requests a dynamic port named "http". This will
          # be something like "46283", but we refer to it via the
          # label "http".
          port "http" {
            static = 8081
          }

        }
      }
    }
  }
}
