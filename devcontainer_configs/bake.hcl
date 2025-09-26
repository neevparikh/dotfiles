group "default" {
  targets = [ "unfetched", "prefetched" ]
}

target "unfetched" {
  target = "unfetched"
  dockerfile = "Dockerfile"
  tags = ["docker.io/npx27/dev-unfetched:latest"]
  args = {
    username = "neev"
    uid      = "1000"
  } 
  platforms = [ "linux/amd64" ]
  ssh = [ "default" ]
}

target "prefetched" {
  target = "prefetched"
  dockerfile = "Dockerfile"
  tags = ["docker.io/npx27/dev-prefetched:latest"]
  args = {
    username = "neev"
    uid      = "1000"
  }
  platforms = [ "linux/amd64" ]
  ssh = [ "default" ]
}
