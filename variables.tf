# variable "vsphere_user" {
#   description = "vCenter User"
#   type        = string
# }

# variable "vsphere_password" {
#   description = "vCenter User password."
#   type        = string
# }

# variable "vsphere_server" {
#   description = "vCenter Server"
#   type        = string
# }

variable "VMDatacenter" {
  description = "VM Datacenter"
  type        = string
}

variable "VMDatastore" {
  description = "Datastore for the VM Placement"
  type        = string
}

variable "vmnetwork" {
  description = "network to connect to the VM"
  type        = string
}

# ----- With a standalone single node VMWare cluster use the host name / IP for the Cluster Name
variable "VMCluster" {
  description = "vCenter Cluster"
  type        = string
}

variable "vmname" {
  description = "Name of the VM"
  type        = string
}

variable "vmfolder" {
  description = "vCenter folder where you want to create the VM"
  type        = string
}

variable "num_cpus" {
  description = "number of cpus for the VM"
  type        = number
}

variable "ram" {
  description = "GBs of RAM for the VM"
  type        = number
}

variable "vmtemplate" {
  description = "Name of the VM Template"
  type        = string
}

variable "domain" {
  description = "Domain"
  type        = string
}

variable "vmuser_data" {
  description = "full path to a user data yaml file."
  type        = string
}

variable "vmmetadata" {
  description = "full path to metadata yaml file"
  type        = string
}

variable "adminpassword" {
  description = "VM admin password."
  type        = string
}

variable "adminuser" {
  description = "vm admin user"
  type        = string
}

variable "k3smasternode" {
  description = "server name of the k3s master node"
  type        = string
}

variable "ssh_rsa_keyfile" {
  description = "path to your rsa public ssh key"
  type        = string
}

variable "userprofile" {
  description = "local users profile.  This is you..."
  type        = string
}

