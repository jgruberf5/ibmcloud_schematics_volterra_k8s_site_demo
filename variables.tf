##################################################################################
# ibm_resource_group - The IBM Cloud resource group to create the VPC
##################################################################################
variable "ibm_resource_group" {
  type        = string
  default     = "default"
  description = "The IBM Cloud resource group to create the VPC"
}

##################################################################################
# ibm_region - The IBM Cloud VPC Gen 2 region to create VPC environment
##################################################################################
variable "ibm_region" {
  default     = "us-south"
  description = "The IBM Cloud VPC Gen 2 region to create VPC environment"
}

##################################################################################
# ibm_zone - The zone within the IBM Cloud region to create the VPC environment
##################################################################################
variable "ibm_zone" {
  default     = "1"
  description = "The zone within the IBM Cloud region to create the VPC environment"
}

##################################################################################
# ibm_profile - The name of the VPC profile to use for the CE instances
##################################################################################
variable "ibm_profile" {
  type        = string
  default     = "bx2-4x16"
  description = "The name of the VPC profile to use for the CE instances"
}

##################################################################################
# ibm_ssh_key_name - The name of the existing SSH key to inject into infrastructure
##################################################################################
variable "ibm_ssh_key_name" {
  default     = ""
  description = "The ID of the existing SSH key to inject into infrastructure"
}

##################################################################################
# ibm_subnet_id - The VPC subnet ID for the K8s cluster
##################################################################################
variable "ibm_subnet_id" {
  default     = ""
  description = "The VPC subnet ID for the K8s cluster"
}


##################################################################################
# instance_name - The name of VPC VSI for the K8s server
##################################################################################
variable "instance_name" {
  default     = "k8s-01"
  description = "The name of VPC VSI for the K8s server"
}

##################################################################################
# podcidr - The CIDR of the internal POD network
##################################################################################
variable "podcidr" {
  default     = "172.15.0.0/16"
  description = "The CIDR of the internal POD network"
}

##################################################################################
# apifqdn - The FQDN to add to the K8s API certificate
##################################################################################
variable "apifqdn" {
  default     = "k8s-01.local"
  description = "The FQDN to add to the K8s API certificate"
}

##################################################################################
# volterra_tenant_name - The Volterra tenant (group) name
##################################################################################
variable "volterra_tenant_name" {
  type        = string
  default     = ""
  description = "The Volterra tenant (group) name"
}

##################################################################################
# volterra_site_name - The Volterra Site name for this VPC
##################################################################################
variable "volterra_site_name" {
  type        = string
  default     = ""
  description = "The Volterra Site name for this VPC"
}

##################################################################################
# volterra_site_token - The site registration token
##################################################################################
variable "volterra_site_token" {
  type        = string
  default     = ""
  description = "The site registration token"
}
