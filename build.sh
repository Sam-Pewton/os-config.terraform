#!/usr/bin/bash

terraform -chdir=infra init
terraform -chdir=infra apply
