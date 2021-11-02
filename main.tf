data "ibm_is_ssh_key" "ssh_key" {
  name = var.ibm_ssh_key_name
}

data "ibm_is_subnet" "subnet" {
  identifier = var.ibm_subnet_id
}

data "ibm_is_vpc" "k8s_vpc" {
  name = data.ibm_is_subnet.subnet.vpc_name
}

data "ibm_is_instance_profile" "instance_profile" {
  name = var.ibm_profile
}

# lookup image name for a custom image in region if we need it
data "ibm_is_image" "ubuntu" {
  name = "ibm-ubuntu-20-04-minimal-amd64-2"
}

locals {
  # user admin_password if supplied, else set a random password
  vpc_gen2_region_location_map = {
    "au-syd" = {
      "latitude"  = "-33.8688",
      "longitude" = "151.2093"
    },
    "ca-tor" = {
      "latitude"  = "43.6532",
      "longitude" = "-79.3832"
    },
    "eu-de" = {
      "latitude"  = "50.1109",
      "longitude" = "8.6821"
    },
    "eu-gb" = {
      "latitude"  = "51.5074",
      "longitude" = "0.1278"
    },
    "jp-osa" = {
      "latitude"  = "34.6937",
      "longitude" = "135.5023"
    },
    "jp-tok" = {
      "latitude"  = "35.6762",
      "longitude" = "139.6503"
    },
    "us-east" = {
      "latitude"  = "38.9072",
      "longitude" = "-77.0369"
    },
    "us-south" = {
      "latitude"  = "32.7924",
      "longitude" = "-96.8147"
    },
    "br-sao" = {
      "latitude"  = "-23.5558",
      "longitude" = "-46.6396"
    }
  }
  site_name   = var.volterra_site_name == "" ? "${var.ibm_instance_name}-site" : var.volterra_site_name
  fleet_label = var.volterra_fleet_label == "" ? "${local.site_name}-fleet" : var.volterra_fleet_label
  #cluster_size = var.volterra_cluster_size
  cluster_size = 1
  #cluster_masters = var.volterra_cluster_size > 2 ? 3 : 1
  cluster_masters  = 1
  demo_banner_text = var.demo_banner_text == "" ? "Welcome to ${local.site_name} cluster" : var.demo_banner_text
}

resource "null_resource" "site" {
  triggers = {
    tenant      = var.volterra_tenant_name
    token       = var.volterra_api_token
    site_name   = local.site_name
    fleet_label = local.fleet_label
    # always force update
    timestamp = timestamp()

  }

  provisioner "local-exec" {
    when       = create
    command    = "${path.module}/volterra_resource_site_create.py --site '${self.triggers.site_name}' --fleet '${self.triggers.fleet_label}' --tenant '${self.triggers.tenant}' --token '${self.triggers.token}'"
    on_failure = fail
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "${path.module}/volterra_resource_site_destroy.py --site '${self.triggers.site_name}' --fleet '${self.triggers.fleet_label}' --tenant '${self.triggers.tenant}' --token '${self.triggers.token}'"
    on_failure = fail
  }
}

data "local_file" "site_token" {
  filename   = "${path.module}/${local.site_name}_site_token.txt"
  depends_on = [null_resource.site]
}

data "template_file" "k8s_userdata" {
  template = file("${path.module}/userdata.yaml")
  vars = {
    podcidr             = var.k8s_podcidr
    instance_name       = var.ibm_instance_name
    apifqdn             = var.k8s_apifqdn
    sitename            = local.site_name
    replicas            = local.cluster_size
    latitude            = lookup(local.vpc_gen2_region_location_map, var.ibm_region).latitude
    longitude           = lookup(local.vpc_gen2_region_location_map, var.ibm_region).longitude
    sitetoken           = data.local_file.site_token.content
    democontaineriamge  = var.demo_container_image
    demonamespace       = var.demo_namespace
    demobanner          = local.demo_banner_text
    demobannercolor     = var.demo_banner_color
    demobannertextcolor = var.demo_banner_text_color
  }
}

# create server 01
resource "ibm_is_instance" "k8s_instance" {
  name           = var.ibm_instance_name
  resource_group = data.ibm_resource_group.group.id
  image          = data.ibm_is_image.ubuntu.id
  profile        = data.ibm_is_instance_profile.instance_profile.id
  primary_network_interface {
    name            = "internal"
    subnet          = data.ibm_is_subnet.subnet.id
    security_groups = [data.ibm_is_vpc.k8s_vpc.default_security_group]
  }
  vpc       = data.ibm_is_subnet.subnet.vpc
  zone      = data.ibm_is_subnet.subnet.zone
  keys      = [data.ibm_is_ssh_key.ssh_key.id]
  user_data = data.template_file.k8s_userdata.rendered
  timeouts {
    create = "60m"
    delete = "120m"
  }
}

resource "ibm_is_floating_ip" "floating_ip" {
  name           = "fip-${var.ibm_instance_name}-k8s"
  resource_group = data.ibm_resource_group.group.id
  target         = ibm_is_instance.k8s_instance.primary_network_interface.0.id
}

resource "null_resource" "site_registration" {
  triggers = {
    site                = local.site_name,
    tenant              = var.volterra_tenant_name
    token               = var.volterra_api_token
    size                = local.cluster_masters,
    allow_ssl_tunnels   = var.volterra_ssl_tunnels ? "true" : "false"
    allow_ipsec_tunnels = var.volterra_ipsec_tunnels ? "true" : "false"
  }

  depends_on = [ibm_is_instance.k8s_instance, ibm_is_floating_ip.floating_ip]
  provisioner "local-exec" {
    when       = create
    command    = "${path.module}/volterra_site_registration_actions.py --delay 420 --action 'registernodes' --site '${self.triggers.site}' --tenant '${self.triggers.tenant}' --token '${self.triggers.token}' --ssl ${self.triggers.allow_ssl_tunnels} --ipsec ${self.triggers.allow_ipsec_tunnels} --size ${self.triggers.size}"
    on_failure = fail
  }

}
