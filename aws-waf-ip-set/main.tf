resource "aws_wafv2_ip_set" "blacklist_ip_set" {

  ip_address_version = "IPV4"
  scope              = "${var.blacklist_scope}"
  description        = var.blacklist_ip_set_description
  name               = var.blacklist_ip_set_name
  addresses          = var.blacklist_ip_addresses


}

resource "aws_wafv2_ip_set" "whitelist_ip_set" {
  ip_address_version = "IPV4"
  scope              = "${var.whitelist_scope}"
  description        = var.ip_set_description
  name               = var.ip_set_name
  addresses          = var.ip_set_addresses

}