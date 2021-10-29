# Volterra Demonstration K8s Site in an Existing VPC

## WARNING: Volterra K8s Sites are still Early Access

This Schematics Workspace module lifecycle manages:

- VSI which builds a single node K8s cluster using the community `kubeadmin` orchestration
- Volterra K8s CE Site
- Volterra Fleet
- Volterra Network Connector to the global shared/public network

The application of this Workspace module results in the creation of a Volterra CE site connected to the designated IBM VPC subnet and K8s cluster.

## Variables values

You will have to define the following variables:

| Key | Definition | Required/Optional | Default Value |
| --- | ---------- | ----------------- | ------------- |
| `ibm_resource_group` | The resource group to create the VPC and VSIs | optional | default |
| `ibm_region` | The IBM Cloud region to create the VPC | optional | us-south |
| `ibm_zone` | The zone number within the region to create the VPC | optional | 1 |
| `ibm_profile` | The IBM VPC profile to use for the CE instances | optional | bx2-4x16 |
| `ibm_ssh_key_name` | The name of the IBM stored SSH key to inject into VSIs | required |  |
| `ibm_subnet_id` | The IBM VPC subnet ID for the K8s cluster | required |  |
| `k8s_podcidr` | The IPv4 CIDR to use as the internal POD networking | required | 172.15.0.0/16 |
| `k8s_apifqdn` | The DNS FQDN to create certificates and K8s configuration file | required | k8s-01.local |
| `volterra_tenant_name` | The Volterra tenant (group) name | required | |
| `volterra_site_name` | The Volterra site name to create for this cluster | required | |
| `volterra_fleet_label` | The Volterra fleet label to create | optional | site name with '-fleet' |
| `volterra_api_token` | The Volterra API token used to manage Volterra resources | required | |
| `volterra_ssl_tunnels` | Allow SSL tunnels to connect the Volterra CE to the RE | optional | true |
| `volterra_ipsec_tunnels` | Allow IPSEC tunnels to connect the Volterra CE to the RE | optional | true |
| `demo_namespace` | The K8s namespace for the container-demo-runner deployment | optional | diag-container |
| `demo_banner_text` | The banner text for the container-demo-runner | optional | welcome message including the site name |
| `demo_banner_color` | The banner color in CSS RGB format (less the #) for the container-demo-runner | optional | e71b2a |
| `demo_banner_text_color` | The banner color text in CSS RGB format (less the #) for the container-demo-runner | optional | ffffff |
