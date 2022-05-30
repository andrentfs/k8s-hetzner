terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.33.2"
    }
  }
}

provider "hcloud" {
  token = file("token_id")
}

resource "hcloud_ssh_key" "default" {
  name       = "K8S"
  public_key = file("id_rsa.pub")
}

resource "hcloud_network" "network" {
  name     = "network"
  ip_range = "192.168.0.0/16"
}

resource "hcloud_network_subnet" "network-subnet" {
  type         = "cloud"
  network_id   = hcloud_network.network.id
  network_zone = "eu-central"
  ip_range     = "192.168.0.0/24"
}

# Create a server K8S Master
resource "hcloud_server" "k8s-master" {
  name        = "k8s-master"
  server_type = "cx21"
  image       = "ubuntu-20.04"
  ssh_keys    = [hcloud_ssh_key.default.id]

  network {
    network_id = hcloud_network.network.id
    ip         = "192.168.0.5"
  }

  # copy over systemd unit
  provisioner "file" {
    connection {
      host        = self.ipv4_address
      type        = "ssh"
      private_key = file("id_rsa")
      timeout     = "30s"
    }
    source      = "install_master.sh"
    destination = "/root/install_master.sh"
  }

  provisioner "remote-exec" {
    connection {
      host        = self.ipv4_address
      type        = "ssh"
      private_key = file("id_rsa")
      #   timeout     = "30s"
    }
    inline = [
      "chmod +x /root/install_master.sh",
      "bash /root/install_master.sh",
    ]
  }
}

# Create a server K8S Worker
resource "hcloud_server" "k8s-worker" {
  name        = "k8s-worder"
  server_type = "cx21"
  image       = "ubuntu-20.04"
  ssh_keys    = [hcloud_ssh_key.default.id]

  network {
    network_id = hcloud_network.network.id
    ip         = "192.168.0.6"
  }

  # copy over systemd unit
  provisioner "file" {
    connection {
      host        = self.ipv4_address
      type        = "ssh"
      private_key = file("id_rsa")
      timeout     = "30s"
    }
    source      = "install_worker.sh"
    destination = "/root/install_worker.sh"
  }

  provisioner "remote-exec" {
    connection {
      host        = self.ipv4_address
      type        = "ssh"
      private_key = file("id_rsa")
      #   timeout     = "30s"
    }
    inline = [
      "chmod +x /root/install_worker.sh",
      "bash /root/install_worker.sh",
    ]
  }
}

output "ipv4-master" {
  value = hcloud_server.k8s-master.ipv4_address
}

output "ipv4-worker" {
  value = hcloud_server.k8s-worker.ipv4_address
}