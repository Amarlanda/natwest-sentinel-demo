

# AWS WAF Web ACL
resource "aws_wafv2_web_acl" "main" {
  name        = var.waf_name
  description = "Web ACL for protection against common web threats"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # # Block AWS managed rule sets
  # rule {
  #   name     = "AWSManagedRulesCommonRuleSet"
  #   priority = 1

  #   override_action {
  #     none {}
  #   }

  #   statement {
  #     managed_rule_group_statement {
  #       name        = "AWSManagedRulesCommonRuleSet"
  #       vendor_name = "AWS"
  #     }
  #   }

  #   visibility_config {
  #     cloudwatch_metrics_enabled = true
  #     metric_name                = "AWSManagedRulesCommonRuleSetMetric"
  #     sampled_requests_enabled   = true
  #   }
  # }

  # # SQL Injection Protection Rule
  # rule {
  #   name     = "AWSManagedRulesSQLiRuleSet"
  #   priority = 2

  #   override_action {
  #     none {}
  #   }

  #   statement {
  #     managed_rule_group_statement {
  #       name        = "AWSManagedRulesSQLiRuleSet"
  #       vendor_name = "AWS"
  #     }
  #   }

  #   visibility_config {
  #     cloudwatch_metrics_enabled = true
  #     metric_name                = "AWSManagedRulesSQLiRuleSetMetric"
  #     sampled_requests_enabled   = true
  #   }
  # }

  # Rate-based rule to prevent DDoS attacks
  rule {
    name     = "RateLimitRule"
    priority = 3

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRuleMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "WebACLMetric"
    sampled_requests_enabled   = true
  }

  tags = {
    Name = var.waf_name
  }
}

# Create an Application Load Balancer to associate with the WAF
resource "aws_lb" "main" {
  name               = "${var.waf_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.waf_name}-alb"
  }
}

# Security group for the ALB
resource "aws_security_group" "alb" {
  name        = "${var.waf_name}-alb-sg"
  description = "Security group for the ALB with WAF protection"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



# Associate WAF WebACL with the ALB
resource "aws_wafv2_web_acl_association" "main" {
  resource_arn = aws_lb.main.arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}

