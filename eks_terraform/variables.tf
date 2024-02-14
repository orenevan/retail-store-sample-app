variable "region" {
  type    = string
  default = "us-east-1"
}


variable "cluster_name" {
  type    = string
  default = "eks-workshop"
}

variable "cluster_version" {
  description = "EKS cluster version."
  type        = string
  default     = "1.27"
}

variable "ami_release_version" {
  description = "Default EKS AMI release version for node groups"
  type        = string
  default     = "1.27.3-20230816"
}

variable "vpc_cidr" {
  description = "Defines the CIDR block used on Amazon VPC created for Amazon EKS."
  type        = string
  default     = "10.42.0.0/16"
}

variable "eks_instance_type" {
  description = "Defines the CIDR block used on Amazon VPC created for Amazon EKS."
  type        = string
  default     = "m5.large"       
}
#m5.large	$0.096
#t2.large	$0.0928


#-------------------  On Demand -----------------------------------

# t2.nano	$0.0058	1	0.5 GiB	EBS Only	Low
# t2.micro	$0.0116	1	1 GiB	EBS Only	Low to Moderate
# t2.small	$0.023	1	2 GiB	EBS Only	Low to Moderate
# t2.medium	$0.0464	2	4 GiB	EBS Only	Low to Moderate
# t2.large	$0.0928	2	8 GiB	EBS Only	Low to Moderate
# t2.xlarge	$0.1856	4	16 GiB	EBS Only	Moderate


# m5.large	$0.096	2	8 GiB	EBS Only	Up to 10 Gigabit
# m5.xlarge	$0.192	4	16 GiB	EBS Only	Up to 10 Gigabit
# m5.2xlarge	$0.384	8	32 GiB	EBS Only	Up to 10 Gigabit
# m5.4xlarge	$0.768	16	64 GiB	EBS Only	Up to 10 Gigabit
# m5.8xlarge	$1.536	32	128 GiB	EBS Only	10 Gigabit
# m5.12xlarge	$2.304	48	192 GiB	EBS Only	10 Gigabit
# m5.16xlarge	$3.072	64	256 GiB	EBS Only	20 Gigabit
# m5.24xlarge	$4.608	96	384 GiB	EBS Only	25 Gigabit
# m5.metal	$4.608	96	384 GiB	EBS Only	25 Gigabit

#------------------- Spot  -----------------------------------
# Instance Type Linux/UNIX Usage Windows Usage Instance Family
# m5.12xlarge	$0.9536	$3.1209	General Purpose - Current Generation
# m5.16xlarge	$1.2264	$4.1703	General Purpose - Current Generation
# m5.24xlarge	$1.8549	$6.232	General Purpose - Current Generation
# m5.2xlarge	$0.1518	$0.5151	General Purpose - Current Generation
# m5.4xlarge	$0.3122	$1.0333	General Purpose - Current Generation
# m5.8xlarge	$0.6545	$2.0686	General Purpose - Current Generation
# m5.large	$0.0401	$0.1282	General Purpose - Current Generation
# m5.metal	$1.8028	$6.2551	Memory Optimized - Current Generation
# m5.xlarge	$0.0754	$0.2534	General Purpose - Current Generation


variable "node_groups_min_size" {
  description = "node group min size  "
  type = number
}

variable "node_groups_max_size" {
  description = "node group max size  "
  type = number
}



variable "node_groups_desired_size" {
  description = "node group desired_size "
  type = number
}
      