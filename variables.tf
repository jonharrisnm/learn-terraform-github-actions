variable "instance_name" {
    description = "EC2 instance name"
    type    = string
    default = "demo-jharris"
    
}

variable "instance_count" {
    description = "Number of EC2 instances"
    default     = "2"

}

variable "instance_type" {
    description = "AWS Instance Type"
    default = "t3.micro"
    
}

variable "alb_name" {
    description = "Name of Load Balancer"
    default     = "albdemo"
}

variable "owner" {
    description = "Owner of Resource"
    default     = "jharris@hashicorp.com"

}

variable "se-region" {
    description = "Region SE covers"
    default     = "AMER - Central E2"

}

variable "purpose" {
    description = "Purpose of resource"
    default     = "demo"

}

variable "ttl" {
    description = "Time to live for resource"
    default     = "8"

}

variable "terraform" {
    description = "Resource provisioned via TF"
    default     = "true"
    
}
