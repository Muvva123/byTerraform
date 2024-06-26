terraform {
    required_providers {
        genesyscloud = {
            source = "mypurecloud/genesyscloud"
        }
    }
}

module "check_queue_data_action" {
    source                        = "../data-actions"
    data_actions_integration_name = "Genesys Cloud Data Actions"
}

module "primary_queue" {
    source           = "../queues"
    name             = "Primary Queue4"
    description      = "The primary queue called from 'Queue Members Check' inbound call flow."
    queue_member_ids = var.primary_queue_member_ids
}

module "secondary_queue" {
    source           = "../queues"
    name             = "Secondary Queue4"
    description      = "The secondary queue called from 'Queue Members Check' inbound call flow."
    queue_member_ids = var.secondary_queue_member_ids
}

module "call_ivr" {
    source            = "../ivr"
    architect_flow_id = data.genesyscloud_flow.my_flow.id
    did_numbers       = var.did_numbers
}

resource "null_resource" "deploy_archy_flow" {
    depends_on = [
        module.primary_queue,
        module.secondary_queue,
        module.check_queue_data_action
    ]
    provisioner "local-exec" {
        working_dir = "/home/runner/work/byTerraform/byTerraform/archy"

        command = "./archy publish --forceUnlock --file /home/runner/work/byTerraform/byTerraform/archy_flow.yaml --clientId $GENESYSCLOUD_OAUTHCLIENT_ID --clientSecret $GENESYSCLOUD_OAUTHCLIENT_SECRET --location mypurecloud.com"
    }
}

data "genesyscloud_flow" "my_flow" {
    depends_on = [null_resource.deploy_archy_flow]
    name       = "Queue Members Check"
} 
