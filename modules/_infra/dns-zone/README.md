# Azure DNS Zone Module

This module creates an Azure DNS Zone for custom domains, with optional random suffix generation for unique DNS names. It also supports creating domain verification records, CNAME records, and hostname bindings for App Services.

## Usage

```hcl
module "dns_zone" {
  source = "../modules/dns-zone"
  
  name                = var.dns_zone_name
  resource_group_name = module.resource_group.name
  
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
```

### With Random Suffix

```hcl
module "dns_zone" {
  source = "../modules/dns-zone"
  
  name                 = "example.com"
  resource_group_name  = module.resource_group.name
  generate_random_suffix = true
  name_prefix          = "dev-"
  random_suffix_length = 5
  
  # This will create a DNS zone like: dev-ab12c.example.com
}
```

### With Custom Domain for App Services

```hcl
module "dns_zone" {
  source = "../modules/dns-zone"
  
  name                = var.dns_zone_name
  resource_group_name = module.resource_group.name
  
  # Domain verification records for App Services
  domain_verification_records = {
    "app1" = {
      verification_id = module.app_service1.app_service_custom_domain_verification_id
    },
    "app2" = {
      verification_id = module.app_service2.app_service_custom_domain_verification_id
    }
  }
  
  # CNAME records for App Services
  cname_records = {
    "app1" = {
      record = module.app_service1.app_service_default_hostname
    },
    "app2" = {
      record = module.app_service2.app_service_default_hostname
    }
  }
  
  # Hostname bindings for App Services
  hostname_bindings = {
    "app1" = {
      app_service_name = module.app_service1.app_name
    },
    "app2" = {
      app_service_name = module.app_service2.app_name
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the DNS Zone | `string` | n/a | yes |
| resource_group_name | The name of the resource group in which to create the DNS Zone | `string` | n/a | yes |
| tags | A mapping of tags to assign to the DNS Zone | `map(string)` | `{}` | no |
| generate_random_suffix | Whether to generate a random suffix for the DNS zone name | `bool` | `false` | no |
| random_suffix_length | The length of the random suffix to generate | `number` | `5` | no |
| name_prefix | The prefix to use for the DNS zone name when using random suffix | `string` | `""` | no |
| record_ttl | The Time To Live (TTL) of the DNS records in seconds | `number` | `300` | no |
| domain_verification_records | Map of domain verification TXT records to create | `map(object({ verification_id = string }))` | `{}` | no |
| cname_records | Map of CNAME records to create | `map(object({ record = string }))` | `{}` | no |
| hostname_bindings | Map of hostname bindings to create for app services | `map(object({ app_service_name = string }))` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the DNS Zone |
| name | The name of the DNS Zone |
| name_servers | The nameservers of the DNS Zone |
| effective_name | The effective name of the DNS Zone (with random suffix if enabled) |
| txt_record_ids | Map of TXT record IDs |
| cname_record_ids | Map of CNAME record IDs |
| hostname_binding_ids | Map of hostname binding IDs |
| certificate_ids | Map of certificate IDs |
