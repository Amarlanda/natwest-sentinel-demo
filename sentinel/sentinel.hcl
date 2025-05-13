policy "enforce-waf-rate-limit-rule" {
  source           = "./waf-rule-attached.sentinel"
}

policy "enforce-waf-association-arn" {
  source           = "./waf-attached-loadbalancer.sentinel"
}

policy "enforce-waf-association-arn-full-plan" {
  source           = "./waf-attached-loadbalancer-full-plan.sentinel"
}
