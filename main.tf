# terraform module to build a K3s cluster


data "vsphere_datacenter" "datacenter" {
  name = var.VMDatacenter
}

# Get the public SSH key to install on the new node
data "template_file" "ssh_key" {
  # count = var.k3smasternode == "" ? 1 : 0

  template = file("${var.userprofile}\\${var.ssh_rsa_keyfile}")
}


# Build K3s Master Node 
# only run if we are bulding master nodes
data "template_file" "master_userdata" {
  count = var.k3smasternode == "" ? 1 : 0

  template = file(var.vmuser_data)

  vars = {
    # ssh_rsa_key   = data.template_file.ssh_key[0].rendered
    ssh_rsa_key   = data.template_file.ssh_key.rendered
    adminuser     = var.adminuser
    adminpassword = var.adminpassword
  }
}



# Build K3s worker Node
# IP of primary master node
data "vsphere_virtual_machine" "masternode" {
  count = var.k3smasternode == "" ? 0 : 1

  name          = var.k3smasternode
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# copy the token file from the master to the local machine (running terraform)
resource "null_resource" "tokenfile" {
  count = var.k3smasternode == "" ? 0 : 1

  # connection {
  #   type     = "ssh"
  #   host     = data.vsphere_virtual_machine.masternode[0].default_ip_address
  #   user     = var.adminuser
  #   password = var.adminpassword
  # }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no  ${var.adminuser}@${data.vsphere_virtual_machine.masternode[0].default_ip_address}:/tmp/node-token node-token"
  }
}
# read the token from the newly downloaded file
data "local_file" "token" {
  count = var.k3smasternode == "" ? 0 : 1

  depends_on = [
    null_resource.tokenfile
  ]

  filename = "node-token"
}

# download the Kubeconfig to the local user profile from the master node
resource "null_resource" "kubeconfig" {
  count = var.k3smasternode == "" ? 0 : 1

  # connection {
  #   type     = "ssh"
  #   host     = data.vsphere_virtual_machine.masternode[0].default_ip_address
  #   user     = var.adminuser
  #   password = var.adminpassword
  # }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no  ${var.adminuser}@${data.vsphere_virtual_machine.masternode[0].default_ip_address}:/tmp/k3s.yaml kubeconfig"
    # command = "scp -o StrictHostKeyChecking=no  ${var.adminuser}@${data.vsphere_virtual_machine.masternode[0].default_ip_address}:/tmp/k3s.yaml ${var.userprofile}\\.kube\\config"
  }
}

# only run if we are bulding worker nodes
data "template_file" "worker_userdata" {
  count = var.k3smasternode == "" ? 0 : 1

  template = file(var.vmuser_data)

  vars = {
    adminuser       = var.adminuser
    adminpassword   = var.adminpassword
    k3smasternodeip = data.vsphere_virtual_machine.masternode[0].default_ip_address
    token           = trimspace(data.local_file.token[0].content)
    ssh_rsa_key     = data.template_file.ssh_key.rendered
  }
}



# Metadata Config for both types of node
data "template_file" "metadataconfig" {
  template = file(var.vmmetadata)

  vars = {
    hostname = var.vmname
  }
}

module "TF_MODULES_VMWare_VM" {
  source = "../TF_MODULE_VMWare_VM"

  VMDatacenter = var.VMDatacenter
  VMCluster    = var.VMCluster
  VMDatastore  = var.VMDatastore
  vmnetwork    = var.vmnetwork
  vmname       = var.vmname
  vmfolder     = var.vmfolder
  num_cpus     = var.num_cpus
  ram          = var.ram
  vmtemplate   = var.vmtemplate
  domain       = var.domain
  vmuser_data  = var.k3smasternode == "" ? data.template_file.master_userdata[0].rendered : data.template_file.worker_userdata[0].rendered
  vmmetadata   = data.template_file.metadataconfig.rendered
}




