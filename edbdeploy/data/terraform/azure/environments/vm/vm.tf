variable "add_hosts_filename" {}
variable "azure_region" {}
variable "azure_offer" {}
variable "azure_publisher" {}
variable "azure_sku" {}
variable "barman_server" {}
variable "barman" {}
variable "dbt2" {}
variable "dbt2_client" {}
variable "dbt2_driver" {}
variable "cluster_name" {}
variable "network_count" {}
variable "pem_server" {}
variable "pooler_server" {}
variable "pooler_type" {}
variable "pooler_local" {}
variable "postgres_server" {}
variable "bdr_server" {}
variable "bdr_witness_server" {}
variable "project_tags" {}
variable "replication_type" {}
variable "resourcegroup_name" {}
variable "securitygroup_name" {}
variable "ssh_priv_key" {}
variable "ssh_pub_key" {}
variable "ssh_user" {}
variable "vnet_name" {}
variable "pg_type" {}
variable "rocky" {}

locals {
  lnx_device_names = [
    "/dev/sdc",
    "/dev/sdd",
    "/dev/sde",
    "/dev/sdf",
    "/dev/sdg",
  ]
}

locals {
  postgres_mount_points = [
    "/pgdata",
    "/pgwal",
    "/pgtblspc1",
    "/pgtblspc2",
    "/pgtblspc3"
  ]
}

locals {
  barman_mount_points = [
    "/var/lib/barman"
  ]
}

resource "azurerm_subnet" "all_subnet" {
  count                = var.network_count
  name                 = format("%s-%s-%s", var.cluster_name, "edb_subnet", count.index)
  resource_group_name  = var.resourcegroup_name
  virtual_network_name = var.vnet_name
  address_prefix       = "10.0.${count.index}.0/24"
}

resource "azurerm_public_ip" "postgres_public_ip" {
  count               = var.postgres_server["count"]
  name                = format("pg-%s-%s-%s", var.cluster_name, "edb_public_ip", count.index)
  location            = var.azure_region
  resource_group_name = var.resourcegroup_name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "postgres_public_nic" {
  count               = var.postgres_server["count"]
  name                = format("pg-%s-%s-%s", var.cluster_name, "edb_public_nic", count.index)
  resource_group_name = var.resourcegroup_name
  location            = var.azure_region

  ip_configuration {
    name      = "PG_Private_Nic_${count.index}"
    subnet_id = element(azurerm_subnet.all_subnet.*.id, count.index)

    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.postgres_public_ip.*.id, count.index)
  }
}

resource "azurerm_public_ip" "bdr_public_ip" {
  count               = var.bdr_server["count"]
  name                = format("bdr-%s-%s-%s", var.cluster_name, "edb_public_ip", count.index)
  location            = var.azure_region
  resource_group_name = var.resourcegroup_name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "bdr_public_nic" {
  count               = var.bdr_server["count"]
  name                = format("bdr-%s-%s-%s", var.cluster_name, "edb_public_nic", count.index)
  resource_group_name = var.resourcegroup_name
  location            = var.azure_region

  ip_configuration {
    name      = "BDR_Private_Nic_${count.index}"
    subnet_id = element(azurerm_subnet.all_subnet.*.id, count.index)

    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.bdr_public_ip.*.id, count.index)
  }
}

resource "azurerm_public_ip" "bdr_witness_public_ip" {
  count               = var.bdr_witness_server["count"]
  name                = format("bdr-witness-%s-%s-%s", var.cluster_name, "edb_public_ip", count.index)
  location            = var.azure_region
  resource_group_name = var.resourcegroup_name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "bdr_witness_public_nic" {
  count               = var.bdr_witness_server["count"]
  name                = format("bdr-witness-%s-%s-%s", var.cluster_name, "edb_public_nic", count.index)
  resource_group_name = var.resourcegroup_name
  location            = var.azure_region

  ip_configuration {
    name      = "BDR_Witness_Private_Nic_${count.index}"
    subnet_id = element(azurerm_subnet.all_subnet.*.id, count.index)

    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.bdr_witness_public_ip.*.id, count.index)
  }
}

resource "azurerm_public_ip" "pem_public_ip" {
  count               = var.pem_server["count"]
  name                = format("pem-%s-%s-%s", var.cluster_name, "edb_public_ip", count.index)
  location            = var.azure_region
  resource_group_name = var.resourcegroup_name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "pem_public_nic" {
  count               = var.pem_server["count"]
  name                = format("pem-%s-%s-%s", var.cluster_name, "edb_public_nic", count.index)
  resource_group_name = var.resourcegroup_name
  location            = var.azure_region

  ip_configuration {
    name      = "PEM_Private_Nic_${count.index}"
    subnet_id = element(azurerm_subnet.all_subnet.*.id, count.index)

    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.pem_public_ip.*.id, count.index)
  }
}

resource "azurerm_public_ip" "barman_public_ip" {
  count               = var.barman_server["count"]
  name                = format("barman-%s-%s-%s", var.cluster_name, "edb_public_ip", count.index)
  location            = var.azure_region
  resource_group_name = var.resourcegroup_name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "barman_public_nic" {
  count               = var.barman_server["count"]
  name                = format("barman-%s-%s-%s", var.cluster_name, "edb_public_nic", count.index)
  resource_group_name = var.resourcegroup_name
  location            = var.azure_region

  ip_configuration {
    name      = "Barman_Private_Nic_${count.index}"
    subnet_id = element(azurerm_subnet.all_subnet.*.id, count.index)

    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.barman_public_ip.*.id, count.index)
  }
}

resource "azurerm_public_ip" "dbt2_client_public_ip" {
  count               = var.dbt2_client["count"]
  name                = format("dbt2c-%s-%s-%s", var.cluster_name, "edb_public_ip", count.index)
  location            = var.azure_region
  resource_group_name = var.resourcegroup_name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "dbt2_client_public_nic" {
  count               = var.dbt2_client["count"]
  name                = format("dbt2c-%s-%s-%s", var.cluster_name, "edb_public_nic", count.index)
  resource_group_name = var.resourcegroup_name
  location            = var.azure_region

  ip_configuration {
    name      = "DBT2_Client_Private_Nic_${count.index}"
    subnet_id = element(azurerm_subnet.all_subnet.*.id, count.index)

    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.dbt2_client_public_ip.*.id, count.index)
  }
}

resource "azurerm_public_ip" "dbt2_driver_public_ip" {
  count               = var.dbt2_driver["count"]
  name                = format("dbt2d-%s-%s-%s", var.cluster_name, "edb_public_ip", count.index)
  location            = var.azure_region
  resource_group_name = var.resourcegroup_name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "dbt2_driver_public_nic" {
  count               = var.dbt2_driver["count"]
  name                = format("dbt2d-%s-%s-%s", var.cluster_name, "edb_public_nic", count.index)
  resource_group_name = var.resourcegroup_name
  location            = var.azure_region

  ip_configuration {
    name      = "DBT2_Driver_Private_Nic_${count.index}"
    subnet_id = element(azurerm_subnet.all_subnet.*.id, count.index)

    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.dbt2_driver_public_ip.*.id, count.index)
  }
}

resource "azurerm_public_ip" "pooler_public_ip" {
  count               = var.pooler_server["count"]
  name                = format("pooler-%s-%s-%s", var.cluster_name, "edb_public_ip", count.index)
  location            = var.azure_region
  resource_group_name = var.resourcegroup_name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "pooler_public_nic" {
  count               = var.pooler_server["count"]
  name                = format("pooler-%s-%s-%s", var.cluster_name, "edb_public_nic", count.index)
  resource_group_name = var.resourcegroup_name
  location            = var.azure_region

  ip_configuration {
    name      = "Pooler_Private_Nic_${count.index}"
    subnet_id = element(azurerm_subnet.all_subnet.*.id, count.index)

    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.pooler_public_ip.*.id, count.index)
  }
}

resource "azurerm_linux_virtual_machine" "postgres_server" {
  count               = var.postgres_server["count"]
  name                = (count.index == 0 ? format("%s-%s", var.cluster_name, "primary") : format("%s-%s%s", var.cluster_name, "standby", count.index))
  resource_group_name = var.resourcegroup_name
  location            = var.azure_region

  size           = var.postgres_server["instance_type"]
  admin_username = var.ssh_user

  network_interface_ids = [element(azurerm_network_interface.postgres_public_nic.*.id, count.index)]

  admin_ssh_key {
    username   = var.ssh_user
    public_key = file(var.ssh_pub_key)
  }

  identity {
    type = "SystemAssigned"
  }

  dynamic "plan" {
    for_each = toset(var.rocky == true ? ["1"] : [])
    content {
      name      = var.azure_sku
      product   = var.azure_offer
      publisher = lower(var.azure_publisher)
    }
  }

  source_image_reference {
    publisher = var.azure_publisher
    offer     = var.azure_offer
    sku       = var.azure_sku

    version = "latest"
  }

  os_disk {
    name                 = format("pg-%s-%s-%s", var.cluster_name, "EDB-VM-OS-Disk", count.index)
    storage_account_type = var.postgres_server["volume"]["storage_account_type"]
    caching              = "ReadWrite"
  }

  tags = var.project_tags
}

resource "azurerm_managed_disk" "postgres_managed_disk" {
  count                = var.postgres_server["count"] * var.postgres_server["additional_volumes"]["count"]
  name                 = format("pg-%s-%s-%s", var.cluster_name, "VM", count.index)
  resource_group_name  = var.resourcegroup_name
  location             = var.azure_region
  storage_account_type = var.postgres_server["additional_volumes"]["storage_account_type"]
  create_option        = "Empty"
  disk_size_gb         = var.postgres_server["additional_volumes"]["size"]
  tags                 = var.project_tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "postgres_managed_disk_attachment" {
  count              = var.postgres_server["count"] * var.postgres_server["additional_volumes"]["count"]
  managed_disk_id    = azurerm_managed_disk.postgres_managed_disk.*.id[count.index]
  virtual_machine_id = element(azurerm_linux_virtual_machine.postgres_server.*.id, count.index)
  lun                = count.index + 10
  caching            = "ReadWrite"
}

resource "null_resource" "postgres_copy_setup_volume_script" {
  count = var.postgres_server["count"]

  depends_on = [
    azurerm_linux_virtual_machine.postgres_server,
    azurerm_virtual_machine_data_disk_attachment.postgres_managed_disk_attachment
  ]

  provisioner "file" {
    content     = file("${abspath(path.module)}/setup_volume.sh")
    destination = "/tmp/setup_volume.sh"

    connection {
      type        = "ssh"
      user        = var.ssh_user
      host        = element(azurerm_public_ip.postgres_public_ip.*.ip_address, count.index)
      private_key = file(var.ssh_priv_key)
    }
  }
}

resource "null_resource" "postgres_setup_volume" {
  count = var.postgres_server["count"] * var.postgres_server["additional_volumes"]["count"]

  depends_on = [
    null_resource.postgres_copy_setup_volume_script
  ]

  provisioner "remote-exec" {
    inline = [
      "chmod a+x /tmp/setup_volume.sh",
      "/tmp/setup_volume.sh ${element(local.lnx_device_names, floor(count.index / var.postgres_server["count"]))} ${element(local.postgres_mount_points, floor(count.index / var.postgres_server["count"]))} >> /tmp/mount.log 2>&1"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      host        = element(azurerm_public_ip.postgres_public_ip.*.ip_address, count.index)
      private_key = file(var.ssh_priv_key)
    }
  }
}

resource "azurerm_linux_virtual_machine" "bdr_server" {
  count               = var.bdr_server["count"]
  name                = format("%s-%s-%s", var.cluster_name, "bdr", count.index + 1)
  resource_group_name = var.resourcegroup_name
  location            = var.azure_region

  size           = var.bdr_server["instance_type"]
  admin_username = var.ssh_user

  network_interface_ids = [element(azurerm_network_interface.bdr_public_nic.*.id, count.index)]

  admin_ssh_key {
    username   = var.ssh_user
    public_key = file(var.ssh_pub_key)
  }

  identity {
    type = "SystemAssigned"
  }

  dynamic "plan" {
    for_each = toset(var.rocky == true ? ["1"] : [])
    content {
      name      = var.azure_sku
      product   = var.azure_offer
      publisher = lower(var.azure_publisher)
    }
  }

  source_image_reference {
    publisher = var.azure_publisher
    offer     = var.azure_offer
    sku       = var.azure_sku

    version = "latest"
  }

  os_disk {
    name                 = format("bdr-%s-%s-%s", var.cluster_name, "EDB-VM-OS-Disk", count.index)
    storage_account_type = var.bdr_server["volume"]["storage_account_type"]
    caching              = "ReadWrite"
  }

  tags = var.project_tags
}

resource "azurerm_managed_disk" "bdr_managed_disk" {
  count                = var.bdr_server["count"] * var.bdr_server["additional_volumes"]["count"]
  name                 = format("bdr-%s-%s-%s", var.cluster_name, "VM", count.index)
  resource_group_name  = var.resourcegroup_name
  location             = var.azure_region
  storage_account_type = var.bdr_server["additional_volumes"]["storage_account_type"]
  create_option        = "Empty"
  disk_size_gb         = var.bdr_server["additional_volumes"]["size"]
  tags                 = var.project_tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "bdr_managed_disk_attachment" {
  count              = var.bdr_server["count"] * var.bdr_server["additional_volumes"]["count"]
  managed_disk_id    = azurerm_managed_disk.bdr_managed_disk.*.id[count.index]
  virtual_machine_id = element(azurerm_linux_virtual_machine.bdr_server.*.id, count.index)
  lun                = count.index + 10
  caching            = "ReadWrite"
}

resource "null_resource" "bdr_copy_setup_volume_script" {
  count = var.bdr_server["count"]

  depends_on = [
    azurerm_linux_virtual_machine.bdr_server,
    azurerm_virtual_machine_data_disk_attachment.bdr_managed_disk_attachment
  ]

  provisioner "file" {
    content     = file("${abspath(path.module)}/setup_volume.sh")
    destination = "/tmp/setup_volume.sh"

    connection {
      type        = "ssh"
      user        = var.ssh_user
      host        = element(azurerm_public_ip.bdr_public_ip.*.ip_address, count.index)
      private_key = file(var.ssh_priv_key)
    }
  }
}

resource "null_resource" "bdr_setup_volume" {
  count = var.bdr_server["count"] * var.bdr_server["additional_volumes"]["count"]

  depends_on = [
    null_resource.bdr_copy_setup_volume_script
  ]

  provisioner "remote-exec" {
    inline = [
      "chmod a+x /tmp/setup_volume.sh",
      "/tmp/setup_volume.sh ${element(local.lnx_device_names, floor(count.index / var.bdr_server["count"]))} ${element(local.postgres_mount_points, floor(count.index / var.bdr_server["count"]))} >> /tmp/mount.log 2>&1"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      host        = element(azurerm_public_ip.bdr_public_ip.*.ip_address, count.index)
      private_key = file(var.ssh_priv_key)
    }
  }
}

resource "azurerm_linux_virtual_machine" "pem_server" {
  count               = var.pem_server["count"]
  name                = format("%s-%s%s", var.cluster_name, "pemserver", count.index + 1)
  resource_group_name = var.resourcegroup_name
  location            = var.azure_region

  size           = var.pem_server["instance_type"]
  admin_username = var.ssh_user

  network_interface_ids = [element(azurerm_network_interface.pem_public_nic.*.id, count.index)]

  admin_ssh_key {
    username   = var.ssh_user
    public_key = file(var.ssh_pub_key)
  }

  identity {
    type = "SystemAssigned"
  }

  dynamic "plan" {
    for_each = toset(var.rocky == true ? ["1"] : [])
    content {
      name      = var.azure_sku
      product   = var.azure_offer
      publisher = lower(var.azure_publisher)
    }
  }

  source_image_reference {
    publisher = var.azure_publisher
    offer     = var.azure_offer
    sku       = var.azure_sku

    version = "latest"
  }

  os_disk {
    name                 = format("pem-%s-%s-%s", var.cluster_name, "EDB-VM-OS-Disk", count.index)
    storage_account_type = var.pem_server["volume"]["storage_account_type"]
    caching              = "ReadWrite"
  }

  tags = var.project_tags
}

resource "azurerm_linux_virtual_machine" "bdr_witness_server" {
  count               = var.bdr_witness_server["count"]
  name                = format("%s-%s%s", var.cluster_name, "bdr-witness", count.index + 1)
  resource_group_name = var.resourcegroup_name
  location            = var.azure_region

  size           = var.bdr_witness_server["instance_type"]
  admin_username = var.ssh_user

  network_interface_ids = [element(azurerm_network_interface.bdr_witness_public_nic.*.id, count.index)]

  admin_ssh_key {
    username   = var.ssh_user
    public_key = file(var.ssh_pub_key)
  }

  identity {
    type = "SystemAssigned"
  }

  dynamic "plan" {
    for_each = toset(var.rocky == true ? ["1"] : [])
    content {
      name      = var.azure_sku
      product   = var.azure_offer
      publisher = lower(var.azure_publisher)
    }
  }

  source_image_reference {
    publisher = var.azure_publisher
    offer     = var.azure_offer
    sku       = var.azure_sku

    version = "latest"
  }

  os_disk {
    name                 = format("bdr-witness-%s-%s-%s", var.cluster_name, "EDB-VM-OS-Disk", count.index)
    storage_account_type = var.bdr_witness_server["volume"]["storage_account_type"]
    caching              = "ReadWrite"
  }

  tags = var.project_tags
}

resource "azurerm_linux_virtual_machine" "pooler_server" {
  count               = var.pooler_server["count"]
  name                = format("%s-%s%s", var.cluster_name, "pooler", count.index + 1)
  resource_group_name = var.resourcegroup_name
  location            = var.azure_region

  size           = var.pooler_server["instance_type"]
  admin_username = var.ssh_user

  network_interface_ids = [element(azurerm_network_interface.pooler_public_nic.*.id, count.index)]

  admin_ssh_key {
    username   = var.ssh_user
    public_key = file(var.ssh_pub_key)
  }

  identity {
    type = "SystemAssigned"
  }

  dynamic "plan" {
    for_each = toset(var.rocky == true ? ["1"] : [])
    content {
      name      = var.azure_sku
      product   = var.azure_offer
      publisher = lower(var.azure_publisher)
    }
  }

  source_image_reference {
    publisher = var.azure_publisher
    offer     = var.azure_offer
    sku       = var.azure_sku

    version = "latest"
  }

  os_disk {
    name                 = format("pooler-%s-%s-%s", var.cluster_name, "EDB-VM-OS-Disk", count.index)
    storage_account_type = var.pooler_server["volume"]["storage_account_type"]
    caching              = "ReadWrite"
  }

  tags = var.project_tags
}

resource "azurerm_linux_virtual_machine" "barman_server" {
  count               = var.barman_server["count"]
  name                = format("%s-%s%s", var.cluster_name, "barman", count.index + 1)
  resource_group_name = var.resourcegroup_name
  location            = var.azure_region

  size           = var.barman_server["instance_type"]
  admin_username = var.ssh_user

  network_interface_ids = [element(azurerm_network_interface.barman_public_nic.*.id, count.index)]

  admin_ssh_key {
    username   = var.ssh_user
    public_key = file(var.ssh_pub_key)
  }

  identity {
    type = "SystemAssigned"
  }

  dynamic "plan" {
    for_each = toset(var.rocky == true ? ["1"] : [])
    content {
      name      = var.azure_sku
      product   = var.azure_offer
      publisher = lower(var.azure_publisher)
    }
  }

  source_image_reference {
    publisher = var.azure_publisher
    offer     = var.azure_offer
    sku       = var.azure_sku

    version = "latest"
  }

  os_disk {
    name                 = format("barman-%s-%s-%s", var.cluster_name, "EDB-VM-OS-Disk", count.index)
    storage_account_type = var.barman_server["volume"]["storage_account_type"]
    caching              = "ReadWrite"
  }

  tags = var.project_tags
}

resource "azurerm_managed_disk" "barman_managed_disk" {
  count                = var.barman_server["count"] * var.barman_server["additional_volumes"]["count"]
  name                 = format("barman-%s-%s-%s", var.cluster_name, "VM", count.index)
  resource_group_name  = var.resourcegroup_name
  location             = var.azure_region
  storage_account_type = var.barman_server["additional_volumes"]["storage_account_type"]
  create_option        = "Empty"
  disk_size_gb         = var.barman_server["additional_volumes"]["size"]
  tags                 = var.project_tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "barman_managed_disk_attachment" {
  count              = var.barman_server["count"] * var.barman_server["additional_volumes"]["count"]
  managed_disk_id    = azurerm_managed_disk.barman_managed_disk.*.id[count.index]
  virtual_machine_id = element(azurerm_linux_virtual_machine.barman_server.*.id, count.index)
  lun                = count.index + 10
  caching            = "ReadWrite"
}

resource "null_resource" "barman_copy_setup_volume_script" {
  count = var.barman_server["count"]

  depends_on = [
    azurerm_linux_virtual_machine.barman_server,
    azurerm_virtual_machine_data_disk_attachment.barman_managed_disk_attachment
  ]

  provisioner "file" {
    content     = file("${abspath(path.module)}/setup_volume.sh")
    destination = "/tmp/setup_volume.sh"

    connection {
      type        = "ssh"
      user        = var.ssh_user
      host        = element(azurerm_public_ip.barman_public_ip.*.ip_address, count.index)
      private_key = file(var.ssh_priv_key)
    }
  }
}

resource "null_resource" "barman_setup_volume" {
  count = var.barman_server["count"] * var.barman_server["additional_volumes"]["count"]

  depends_on = [
    null_resource.barman_copy_setup_volume_script
  ]

  provisioner "remote-exec" {
    inline = [
      "chmod a+x /tmp/setup_volume.sh",
      "/tmp/setup_volume.sh ${element(local.lnx_device_names, floor(count.index / var.barman_server["count"]))} ${element(local.barman_mount_points, floor(count.index / var.barman_server["count"]))} >> /tmp/mount.log 2>&1"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      host        = element(azurerm_public_ip.barman_public_ip.*.ip_address, count.index)
      private_key = file(var.ssh_priv_key)
    }
  }
}

resource "azurerm_linux_virtual_machine" "dbt2_client_server" {
  count               = var.dbt2_client["count"]
  name                = format("%s-%s%s", var.cluster_name, "dbt2c", count.index + 1)
  resource_group_name = var.resourcegroup_name
  location            = var.azure_region

  size           = var.dbt2_client["instance_type"]
  admin_username = var.ssh_user

  network_interface_ids = [element(azurerm_network_interface.dbt2_client_public_nic.*.id, count.index)]

  admin_ssh_key {
    username   = var.ssh_user
    public_key = file(var.ssh_pub_key)
  }

  identity {
    type = "SystemAssigned"
  }

  dynamic "plan" {
    for_each = toset(var.rocky == true ? ["1"] : [])
    content {
      name      = var.azure_sku
      product   = var.azure_offer
      publisher = lower(var.azure_publisher)
    }
  }

  source_image_reference {
    publisher = var.azure_publisher
    offer     = var.azure_offer
    sku       = var.azure_sku

    version = "latest"
  }

  os_disk {
    name                 = format("dbt2c-%s-%s-%s", var.cluster_name, "EDB-VM-OS-Disk", count.index)
    storage_account_type = var.dbt2_client["volume"]["storage_account_type"]
    caching              = "ReadWrite"
  }

  tags = var.project_tags
}

resource "azurerm_linux_virtual_machine" "dbt2_driver_server" {
  count               = var.dbt2_driver["count"]
  name                = format("%s-%s%s", var.cluster_name, "dbt2d", count.index + 1)
  resource_group_name = var.resourcegroup_name
  location            = var.azure_region

  size           = var.dbt2_driver["instance_type"]
  admin_username = var.ssh_user

  network_interface_ids = [element(azurerm_network_interface.dbt2_driver_public_nic.*.id, count.index)]

  admin_ssh_key {
    username   = var.ssh_user
    public_key = file(var.ssh_pub_key)
  }

  identity {
    type = "SystemAssigned"
  }

  dynamic "plan" {
    for_each = toset(var.rocky == true ? ["1"] : [])
    content {
      name      = var.azure_sku
      product   = var.azure_offer
      publisher = lower(var.azure_publisher)
    }
  }

  source_image_reference {
    publisher = var.azure_publisher
    offer     = var.azure_offer
    sku       = var.azure_sku

    version = "latest"
  }

  os_disk {
    name                 = format("dbt2d-%s-%s-%s", var.cluster_name, "EDB-VM-OS-Disk", count.index)
    storage_account_type = var.dbt2_driver["volume"]["storage_account_type"]
    caching              = "ReadWrite"
  }

  tags = var.project_tags
}
