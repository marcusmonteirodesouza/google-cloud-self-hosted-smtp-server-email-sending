locals {
  mailinabox_email_server_tag = "mailinabox-email-server"
  iap_ip_cidr_range           = "35.235.240.0/20"
}

data "google_compute_zones" "available" {
}

data "google_compute_network" "public_network" {
  name = var.public_network_name
}

data "google_secret_manager_secret_version" "email_password" {
  secret = var.email_password_secret_id
}

# See https://mailinabox.email/guide.html
resource "google_compute_firewall" "mailinabox_email_server_ingress" {
  name        = "mailinabox-email-server-ingress"
  network     = data.google_compute_network.public_network.id
  description = "Ingress firewall rule targeting Mail-in-a-Box email server instances"

  allow {
    protocol = "tcp"
    ports = [
      "25",
      "53",
      "80",
      "443",
      "465",
      "587",
      "993",
      "995",
      "4190"
    ]
  }

  allow {
    protocol = "udp"
    ports = [
      "53"
    ]
  }

  source_ranges = [
    "0.0.0.0/0"
  ]

  target_tags = [
    local.mailinabox_email_server_tag
  ]
}

resource "google_compute_firewall" "mailinabox_email_server_egress" {
  name        = "mailinabox-email-server-egress"
  network     = data.google_compute_network.public_network.id
  description = "Egress firewall rule targeting Mail-in-a-Box email server instances"
  direction   = "EGRESS"

  allow {
    protocol = "tcp"
    ports = [
      "25",
    ]
  }

  source_ranges = [
    "0.0.0.0/0"
  ]

  target_tags = [
    local.mailinabox_email_server_tag
  ]
}

resource "google_compute_firewall" "mailinabox_email_server_allow_iap_ssh" {
  name        = "mailinabox-email-server-allow-iap-ssh"
  network     = data.google_compute_network.public_network.id
  description = "Allow Identity-Aware Proxy ssh targeting Mail-in-a-Box email server instances"

  allow {
    protocol = "tcp"
    ports = [
      "22",
    ]
  }

  source_ranges = [
    local.iap_ip_cidr_range
  ]

  target_tags = [
    local.mailinabox_email_server_tag
  ]
}

resource "google_service_account" "mailinabox_email_server" {
  account_id   = "mailinabox-email-server"
  display_name = "mailinabox Email Server Service Account"
}

resource "google_compute_instance" "mailinabox_email_server" {
  name         = "mailinabox-email-server"
  machine_type = var.email_server_machine_type
  zone         = data.google_compute_zones.available.names[0]

  tags = [
    local.mailinabox_email_server_tag
  ]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = var.public_network_name
    access_config {
      nat_ip                 = var.email_server_ip_address
      public_ptr_domain_name = var.email_server_hostname
    }
  }

  service_account {
    email  = google_service_account.mailinabox_email_server.email
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot = true
  }

  metadata_startup_script = <<EOF
export NONINTERACTIVE=1
export PUBLIC_IP='${var.email_server_ip_address}'
export PUBLIC_IPV6='auto'
export PRIMARY_HOSTNAME='${var.email_server_hostname}'
export EMAIL_ADDR='${var.email_from}'
export EMAIL_PW='${data.google_secret_manager_secret_version.email_password.secret_data}'
curl https://mailinabox.email/setup.sh | sudo -E bash
EOF

  depends_on = [
    google_compute_firewall.mailinabox_email_server_ingress,
    google_compute_firewall.mailinabox_email_server_egress,
    google_compute_firewall.mailinabox_email_server_allow_iap_ssh
  ]
}
