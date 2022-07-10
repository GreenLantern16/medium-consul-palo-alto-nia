
resource "panos_nat_rule_group" "app" {
  rule {
    name = "web_app"
    original_packet {
      source_zones          = ["public"]
      destination_zone      = "public"
      source_addresses      = ["any"]
      destination_addresses = [data.terraform_remote_state.deploy-infra.outputs.privateipfwnic1]
    }
    translated_packet {
      source {
        dynamic_ip_and_port {
          interface_address {
            interface = panos_ethernet_interface.ethernet1_2.name
          }
        }
      }
      destination {
        static_translation {
          address = data.terraform_remote_state.deploy-infra.outputs.web-lb
        }
      }
    }
  }
}

resource "panos_nat_rule_group" "egress-nat" {
  rule {
    name          = "egress-nat"
    audit_comment = "Ticket 12345"
    original_packet {
      source_zones          = [panos_zone.private_zone.name]
      destination_zone      = panos_zone.public_zone.name
      destination_interface = panos_ethernet_interface.ethernet1_1.name
      source_addresses      = ["any"]
      destination_addresses = ["any"]
    }
    translated_packet {
      source {
        dynamic_ip_and_port {
          interface_address {
            interface = panos_ethernet_interface.ethernet1_1.name
          }
        }
      }
      destination {}
    }
  }
}