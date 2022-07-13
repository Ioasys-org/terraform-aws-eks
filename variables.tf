variable "environment_name" {
  description = "Environment name"
  type        = string
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "ami_name" {
  description = "AMI name"
  type        = string
  default     = "ami-000c09458bbe0fa2a"
}

variable "key_pair_name" {
  description = "Key Pairs name"
  type        = string
}

variable "instance_type" {
  description = "Node instance type"
  type        = string
  default     = "t2.medium"
}

variable "cluster-node-autoscaling-max_size" {
  description = "Max nodes"
  type        = number
  default     = 2
}

variable "cluster-node-autoscaling-min_size" {
  description = "Min nodes"
  type        = number
  default     = 1
}

variable "cluster-node-autoscaling-desired" {
  description = "Desired nodes"
  type        = number
  default     = 2
}

variable "services_accounts" {
  description = "Service accounts namespaces and access"
  type = map(object({
    namespace = string
    statements = list(object({
      Effect   = string,
      Action   = list(string),
      Resource = list(string)
    }))
  }))
  default = {}
}
