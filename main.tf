# Robert Jordan's Pearson video lecture Terraform code
# Optional configuration for the Terraform Engine.
terraform {
  required_version = ">=1.0.0"
}

# Provider
# Implement cloud specific API and Terraform API.
# Provider configuration is specific to each provider.
# Providers expose Data Sources and Resources to Terraform
provider "aws" {
  version = "~> 2.0"
  region = "us-east-1"
  # access_key = "my-access-key"
  # secret_key = "my-secret-key"

  # Many providers also accept configuration via environment variables
  # or config files. The AWS provider will read the standard AWS CLI
  # settings if they are present
}

# Resources
# Objects managed by Terraform such as VMS OR S3 BUCKETS.
# Declaring a Resource tells Terraform that it should CREATE
# and manage the Resource described. If the Resource already exists
# its must be imported into Terraform's state.
resource "aws_s3_bucket" "bucket1" {
bucket = "bucket1"
}

# Data Sources
# Objects NOT managed by Terraform.

data "aws_caller_identity" "current" {

}

data "aws_availability_zones" "available" {

}

output "bucket_info" {
  value = aws_s3_bucket.bucket1.bucket
}

output "aws_caller_info" {
  value = data.aws_caller_identity.current
}

output "aws_availability_zones" {
  value = data.aws_availability_zones.available
}

# Interpolation
# Substitute values in strings.
resource "aws_s3_bucket" "bucket2" {
  bucket = "${data.aws_caller_identity.current.account_id}-bucket2"
}

# Dependency
# Resources can depend on one another. Terraform will ensure that all 
# dependencies are met before creating the resource. Dependency can
# be implicit or explicit.
resource "aws_s3_bucket" "bucket3" {
  bucket = "${data.aws_caller_identity.current.account_id}-bucket3"
  tags = {
    # Implicity dependency
    dependency = aws_s3_bucket.bucket3.arn
  }
}

resource "aws_s3_bucket" "bucket4" {
  bucket = "${data.aws_caller_identity.current.account_id}-bucket34"
  # Explicit
  depends_on = [
    aws_s3_bucket.bucket3
  ]
}

# Variables
# Can be specified on the command line with -var bucket_name=my-bucket
# or in files: terraform.tfvars or *.auto.tfvars
# or in evnironment variables: TF_VAR_bucket_name
variable "bucket_name" {
  # `type` is an optional data type specification
  type = "string"
  # `default` is the optional default value. If `default` is omitted
  # then a value must be specified.
  # default = "my-bucket"
}

resource "aws_s3_bucket" "bucket5" {
  bucket = var.bucket_name
}

# Local Values
# Local values allow you to assign a name to an expression. Locals
# can make your code more readable.
locals {
  aws_account = "${data.aws_caller_identity.current.account_id}-${lower(data.aws_caller_identity.current.user_id)}"
}

resourcer "aws_s3_bucket" "bucket6" {
  bucket = "${local.aws_account}-bucket6"
}


/*
# Count
# All resources have a `count` parameter. The default is 1.
# If count is set then a list of resources is returned (even if there is only 1)
# If `count` is set then a `count.index` value is available. THis value contains
# the current iteration number.
# TIP: setting `count = 0` is a handy way to remove a resource but keep the config.
*/
resource "aws_s3_bucket" "bucketX" {
  count = 2
  bucket = "${local.aws_account}-bucket${count.index+7}"
}

# for_each
# Resources may have a `for_each` parameter.
# If for_each is set then a resource is created for each item in the set and a
# special `each` object is available. The `each` object has `key` and `value`
# attributes that can be referenced.

locals {
  buckets = {
    bucket101 = "mybucket101"
    bucket102 = "mybucket102"
  }
}

resource "aws_s3_bucket" "bucketE" {
  for_each = local.buckets
  bucket = "${local.aws_account}-${each.value}"
}

output "bucketE" {
  value = aws_s3_bucket.bucketX
}

# Data types
# Terraform supports simple and complex data types
locals {
  a_string = "This is a string."
  a_numner = 3.1414
  a_boolean = true
  a_list = [
    "element1",
    2,
    "three"
  ]
  a_map = {
    key = "value"
  }

  # Complex
  person = {
    name   = "Robert Larson",
    phone_numbers = {
      home   = "415-444-1212",
      mobile = "415-555-1313"
    },
    active = false,
    age    = 32
  }
}

output "home_phone" {
  value = local.person.phone_numbers.home
}

# Operators
# Terraform suppprts arithmetic and logical operations in expressioons too
locals {
  // Arithmetic
  three = 1 + 2 // addition
  two   = 3 - 1 // subtraction
  one   = 2 / 2 // division
  zero  = 1 * 0 // multiplication

  // Logical
  t = true || false  // OR true if either value is true
  f = true && false // AND true if both values are true

  // Comparision
  gt = 2 > 1 // true if right value is greater
  gte = 2 >= 1 // true if right value is greater or equal
  lt = 1 < 2 // true if left value is greater
  lte = 1 <= 2 // true if left value is greater or equal
  eq = 1 == 1 // true if left and right are equal
  neq = 1 != 2 // true if left and right are not equal
}

output "arithmetic" {
  value = "${local.zero} ${local.one} ${local.two} ${local.three}"
}

output "logical" {
  value = "${local.t} ${local.f}"
}

output "comparision" {
  value = "${local.gt} ${local.gte} ${local.lt} ${local.lte} ${local.eq} ${local.neq}"
}

# Conditionals
variable "bucket_count" {
  type = number
}

locals {
  minumum_numnber_of_buckets = 5
  number_of_buckets = var.bucket_count > 0 ? var.bucket_count : local.minimum_number_of_buckets  // BUG ?
}

resource "aws_s3_bucket" "buckets" {
  count = local.number_of_buckets
  bucket = "${local.aws_account}-bucket${count.index+7}"
}

# Functions
# Terraform has 100+ built-in functions (but no ability to define custom functions)
# https://www.terraform.io/docs/configuration/functions.html
# The syntax for a function call is <function_name>(<arg1>, <arg2>).
locals {
  // Date and Time
  ts = timestamp() // Returns the current date and time
  current_months = formatdate("MMMM", local.ts)
  tomorrow = formatdate("DD", timeadd(local.ts, "24h"))
}

output "date_time" {
  value = "${local.current_month} ${local.tomorrow}"
}

locals {
  // Numberic
  number_of_buckets_2 = min(local.minimum_number_of_buckets, var.bucke_count)
}

locals {
  // String
  lcase = "${lower("A mixed case String")}"
  ucase = "${upper("a lower case string")}"
  trimmed = "${trimspace(" A string with leading and trailing space   ")}"
  formatted = "${format("Hello %s.", "world")}"
  formatted_list = "${formatlist("Hello %s", ["John", "Paul", "George". "Ringo"])}"
}

output "string_functions" {
  value = local.formatted_list
}

# Iteration
# HCL has a `for` syntax for iterating over list values.
locals {
  l = ["one", "two", "three"]
  upper_list = [for item in local.l: upper(item)]
  upper_map = {for item in local.l: item => upper(item)}
}

output "iterations" {
  value = local.upper_list
}

# Filtering
# The `for` syntax can also take an `if` clause.
locals {
  n = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
  evens = [for i in local.n: i if i % 2 == 0]
}

output "filtered" {
  value = local.evens
}


# Directies and HereDocs
# HCL supports more complex string templating that can be used to generate
# full descriptive paragraphs too.
output "heredoc" {
  value = <<-EOT
    This is called a `heredoc`. It's a string literal
    that can span multiple lines.
  EOT
}

output "directive" {
  value = <<-EOT
    This is a `heredoc` with directives.
    %{ if local.person.name == "" }
    Sorry, I don't know your name.
    %{ else }
    Hi, ${ local.person.name }
    %{ endif }
  EOT
}

output "iterated" {
  value = <<-EOT
    Directives can also iterate...
    %{ for number in local.evens }
    ${ number } is even.
    %{ endfor }
  EOT
}


# CLEANUP
/*
> terraform state list
> terraform state show aws_s3_bucket.bucketE
# end of session run tf destroy
> terraform destroy
> terraform state list # should output nothing
*/

# MODULE
/*
All terraform is in a module. The top level module is called the Root module
Modules are just regular Terraform code ... in a folder
Modules can be nested

When to use Module

Boilerplate code
  Code that is frequently re-used
    AWS Accounts etc
    Enforce standards
    You find yourself cutting and pasting
Add abstraction
  DNS providers
  Kubernetes Providers
  Things that are separete resources in TF, but that are logically one thing (e.g. VM + Disk + NIC)
Missing resources
  Providers are not always up to date with cloud features

Creating a module

Create a directory
Put some Terraform in it

Module Naming
  terraform-<PROVIDER>-<NAME>
  <NAME> can contain hyphens
  This format is required to publish to the Terraform registry, otherwise it's just conventional


Module Layout

terraform-<PROVIDER>-<NAME>
|- README.md
|- LICENSE
|- main.tf
|- variables.tf
|- outputs.tf
|- modules/
  |- README.md
  |- LIECENSE
  |- main.tf
  |- _
|- examples/
  |- example_1/
    |- main.tf
|- scripts/
  |- datasource.py
  |- resource.py

Modules:
Like the root module:
  variable to pass parameters
  output to return values
Unlike the root module
  variables without default values are required. TF will not prompt
  outputs are not printed to the console or persisted in the state


Using a module

Local filesystem

module "local-module" {
  source = "/path/to/module"
}

Terraform registry

module "published-module" {
  source = "rojopolis/lambda-python-archive"
}

SCM repo

module "scm-module" {
  source = "github.com/rojopolis/terraform-aws-lambda-python-archive"
}

Example of module in action

module.tf
variable "string_param" {
  type        = "string"
  description = "A string"
  default     = "biz"
}
output "string_output" {
  description = "The value of string_param"
  value       = var.string_param
}

main.tf
module "local-module" {
  source       = "/path/to/module"
  string_param = "foo"
}

output "module_output" {
  derscription = "The output from a module"
  value        = module.local-module.string_output
}
*/

