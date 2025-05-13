# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

mock "tfplan/v2" {
  module {
    source = "./mocks/waf-is-attached/mock-tfplan-v2.sentinel"
  }
}

test {
  rules = {
    main = true
  }
}

# generate report
