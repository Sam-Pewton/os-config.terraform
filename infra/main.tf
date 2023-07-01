terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  profile = lookup(var.base-configs, "profile")
  region  = lookup(var.base-configs, "region")
}


// POLICIES
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


// ROLES
resource "aws_iam_role" "os-config-lambda" {
  name               = "os-config-lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


// DATA
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "../test_lambda/initial_lambda.py"
  output_path = "../test_lambda/lambda_function_payload.zip"
}


// VPC
resource "aws_vpc" "os-config-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "os-config-vpc"
  }
}


// SUBNETS
resource "aws_subnet" "os-config-public_subnets" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.os-config-vpc.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = var.azs[0]

  tags = {
    Name = "os-config-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "os-config-private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.os-config-vpc.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = var.azs[0]

  tags = {
    Name = "os-config-private-subnet-${count.index + 1}"
  }
}


// IGW
resource "aws_internet_gateway" "os-config-gw" {
  vpc_id = aws_vpc.os-config-vpc.id

  tags = {
    Name = "os-config-vpc-ig"
  }
}


// ROUTE TABLES
resource "aws_route_table" "os-config-rt-1" {
  vpc_id = aws_vpc.os-config-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.os-config-gw.id
  }

  tags = {
    Name = "os-config-route-table-1"
  }
}


// ROUTE TABLE ASSOCIATIONS
resource "aws_route_table_association" "os-config-public-subnet-asso" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.os-config-public_subnets[*].id, count.index)
  route_table_id = aws_route_table.os-config-rt-1.id
}


// LAMBDA FUNCTIONS
resource "aws_lambda_function" "os-config-lamba-1" {
  function_name = "os_config_initialise"
  runtime       = "python3.10"
  role          = aws_iam_role.os-config-lambda.arn
  filename = "../test_lambda/lambda_function_payload.zip"
  handler = "test.handler"
}
