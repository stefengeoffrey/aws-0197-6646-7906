terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

data "terraform_remote_state" "vpc" {
    backend = "s3"
    config  = {
        bucket = "hibu-nonprod-terraform-state"
        key    = "non-prod/use1/network/vpc/terraform.tfstate"
        region = "us-east-1"
    }
}


locals {
  zone_name = sort(keys(module.zones.route53_zone_zone_id))[0]
  #  zone_id = module.zones.route53_zone_zone_id["terraform-aws-modules-example.com"]
}

module "zones" {
source  = "git@github.com:stefengeoffrey/devops-terraform-modules.git//route53/zones?ref=6a1facd2ddeec47e2af3bd9ca0909a6b3e0665b1"

  zones = {
    "terraform-aws-modules-example.com" = {
      comment = "terraform-aws-modules-example.com (production)"
      tags = {
        Name = "terraform-aws-modules-example.com"
      }
    }

    "app.terraform-aws-modules-example.com" = {
      comment           = "app.terraform-aws-modules-example.com"
      delegation_set_id = module.delegation_sets.route53_delegation_set_id.main
      tags = {
        Name = "app.terraform-aws-modules-example.com"
      }
    }

    "private-vpc.terraform-aws-modules-example.com" = {
      # in case than private and public zones with the same domain name
      domain_name = "terraform-aws-modules-example.com"
      comment     = "private-vpc.terraform-aws-modules-example.com"
      vpc = [
        {
          vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
        },
       ]
      tags = {
        Name = "private-vpc.terraform-aws-modules-example.com"
      }
    }
  }

  tags = {
    ManagedBy = "Terraform"
  }
}

module "records" {
source  = "git@github.com:stefengeoffrey/devops-terraform-modules.git//route53/records?ref=6a1facd2ddeec47e2af3bd9ca0909a6b3e0665b1"

  zone_name = local.zone_name
  #  zone_id = local.zone_id

  records = [
    {
      name = ""
      type = "A"
      ttl  = 3600
      records = [
        "10.10.10.10",
      ]
    },

    {
      name           = "geo"
      type           = "CNAME"
      ttl            = 5
      records        = ["europe.test.example.com."]
      set_identifier = "europe"
      geolocation_routing_policy = {
        continent = "EU"
      }
    },

    {
      name           = "test"
      type           = "CNAME"
      ttl            = 5
      records        = ["test.example.com."]
      set_identifier = "test-primary"
      weighted_routing_policy = {
        weight = 90
      }
    },
    {
      name           = "test"
      type           = "CNAME"
      ttl            = 5
      records        = ["test2.example.com."]
      set_identifier = "test-secondary"
      weighted_routing_policy = {
        weight = 10
      }
    },


  ]

  depends_on = [module.zones]
}

module "terragrunt" {
source  = "git@github.com:stefengeoffrey/devops-terraform-modules.git//route53/records?ref=6a1facd2ddeec47e2af3bd9ca0909a6b3e0665b1"

  zone_name = local.zone_name

  # Terragrunt has a bug (https://github.com/gruntwork-io/terragrunt/issues/1211) that requires `records` to be wrapped with `jsonencode()`
  records_jsonencoded = jsonencode([
    {
      key  = "new A"
      name = "new"
      type = "A"
      ttl  = 3600
      records = [
        "10.10.10.10",
      ]
    },
    {
      name = "new2"
      type = "A"
      ttl  = 3600
      records = [
        "10.10.10.11",
        "10.10.10.12",
      ]
    },
    {
      name = "s3-bucket-terragrunt"
      type = "A"
      alias = {
        # In Terragrunt code the values may depend on the outputs of modules:
        # name    = dependency.s3_bucket.outputs.s3_bucket_website_domain
        # zone_id = dependency.s3_bucket.outputs.s3_bucket_hosted_zone_id
        # Terragrunt passes known values to the module:
        name    = "s3-website-eu-west-1.amazonaws.com"
        zone_id = "Z1BKCTXD74EZPE"
      }
    }
  ])

  depends_on = [module.zones]
}

module "records_with_full_names" {
source  = "git@github.com:stefengeoffrey/devops-terraform-modules.git//route53/records?ref=6a1facd2ddeec47e2af3bd9ca0909a6b3e0665b1"

  zone_name = local.zone_name

  records = [
    {
      name               = "with-full-name-override.${local.zone_name}"
      full_name_override = true
      type               = "A"
      ttl                = 3600
      records = [
        "10.10.10.10",
      ]
    },
    {
      name = "web"
      type = "A"
      ttl  = 3600
      records = [
        "10.10.10.11",
        "10.10.10.12",
      ]
    },
  ]

  depends_on = [module.zones]
}

module "delegation_sets" {
source  = "git@github.com:stefengeoffrey/devops-terraform-modules.git//route53/delegation-sets?ref=6a1facd2ddeec47e2af3bd9ca0909a6b3e0665b1"

  delegation_sets = {
    main = {}
  }
}

/*
module "resolver_rule_associations" {
source  = "git@github.com:stefengeoffrey/devops-terraform-modules.git//route53/resolver-rule-associations?ref=6a1facd2ddeec47e2af3bd9ca0909a6b3e0665b1"

  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  resolver_rule_associations = {
    example = {
      resolver_rule_id = aws_route53_resolver_rule.sys.id
    },

  }
}
*/

module "disabled_records" {
source  = "git@github.com:stefengeoffrey/devops-terraform-modules.git//route53/records?ref=6a1facd2ddeec47e2af3bd9ca0909a6b3e0665b1"

  create = false
}

