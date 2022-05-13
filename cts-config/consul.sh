log_level = "INFO"
port = 8558
syslog {}

buffer_period {
  enabled = true
  min     = "5s"
  max     = "20s"
}

id = "cts-01"

consul {
    address = "10.0.0.100:8500"
    service_registration {
      enabled = true
      service_name = "cts"
      default_check {
        enabled = true
        address = "http://10.0.0.100:8558"
      }
    }
}

driver "terraform" {
  log = true
  required_providers {
    bigip = {
      source = "F5Networks/bigip"
    }
  }
}


terraform_provider "bigip" {
  address  = "10.0.0.200:8443"
  username = "admin"
  password = "IWmao2Gkob7MNGny"
}

task {
  name = "f5-frontend-workspace"
  description = "Front end Application Services"
  module = "github.com/maniak-academy/f5-nia-as3"
  providers = ["bigip"]
  condition "services" {
    names = ["secure-app"]
    datacenter = "dc1"
  }
}


