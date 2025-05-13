# Sentinel Policies for NatWest WAF Configuration

This document provides a detailed explanation of the Sentinel policies used in this project to enforce security and compliance standards for AWS Web Application Firewall (WAF) configurations. Each policy's purpose, logic, the rationale behind its design, and an advisory statement are outlined below.

## Policies

### 1. `waf-rule-attached.sentinel`

*   **High-Level Purpose:**
    To guarantee that a critical security measure, specifically a rule named "RateLimitRule", is actively configured and present within the primary Web Application Firewall (WAF) Access Control List (ACL) (`aws_wafv2_web_acl.main`).

*   **Detailed Logic Breakdown:**
    1.  **WAF ACL Existence Check:** The policy first confirms that the `aws_wafv2_web_acl.main` resource is part of the Terraform deployment plan.
    2.  **Target Rule Identification:** It explicitly looks for a rule named `"RateLimitRule"`.
    3.  **Rule Presence Verification:**
        *   A helper function (`rule_exists_with_name`) scans the list of rules associated with the `aws_wafv2_web_acl.main`.
        *   It includes a type check (`types.type_of(resource.change.after.rule) != "list"`) to handle cases gracefully where the WAF ACL might not have any rules defined.
        *   The function confirms if any of the WAF ACL's rules has its `name` attribute set to `"RateLimitRule"`.
    4.  **Policy Outcome:** The policy passes only if `aws_wafv2_web_acl.main` exists AND "RateLimitRule" is found.

*   **Rationale for Design and Chosen Values:**
    *   **Focus on `aws_wafv2_web_acl.main`:** Assumed to be the primary WAF ACL protecting your application(s).
    *   **Mandating "RateLimitRule":** Rate limiting is a vital defense against DoS/DDoS, brute-force attacks, web scraping, and API abuse. Standardized naming ensures the *intended* rule is present.
    *   **Robustness through Pre-checks:** Ensures the policy doesn't fail unnecessarily if the WAF ACL isn't deployed or if its rule structure is unexpected.

*   **Benefits of this Policy:**
    *   Enhanced application availability and resilience.
    *   Improved security against automated threats.
    *   Operational consistency in WAF configuration.
    *   Proactive mitigation of missing security controls.

*   **Potential Impact if Violated (i.e., "RateLimitRule" is missing):**
    *   Increased vulnerability to DoS/DDoS and brute-force attacks.
    *   Application performance degradation.
    *   Potential for higher operational costs due to unmitigated attacks.

*   **Recommended Enforcement Level & Rationale:**
    *   **Level:** `soft-mandatory`
    *   **Rationale:** This policy checks for a critical security component. A `soft-mandatory` level ensures that configurations lacking this rule are blocked by default, preventing accidental deployment of less secure infrastructure, while allowing administrative overrides in exceptional, documented cases.

*   **Advisory Statement:**
    > It is strongly advised to maintain the `waf-rule-attached.sentinel` policy with at least a `soft-mandatory` enforcement level. The presence of a "RateLimitRule" in your primary WAF ACL is a fundamental security measure against denial-of-service, brute-force, and other automated attacks. Ensuring this rule is always configured significantly enhances application availability, protects against credential compromise, and maintains a consistent security posture. Deviating from this policy should only occur under exceptional, well-documented circumstances with appropriate risk assessment.

---

### 2. `waf-attached-loadbalancer.sentinel`

*   **High-Level Purpose:**
    To verify that every AWS WAFv2 Web ACL association resource (`aws_wafv2_web_acl_association`) defined in the Terraform plan has a valid Web ACL ARN (`web_acl_arn`) assigned. This policy ensures that resources intended to be protected by a WAF are correctly linked to one.

*   **Detailed Logic Breakdown:**
    1.  **Resource Identification:** The policy searches through `tfplan.planned_values` to find all instances of `aws_wafv2_web_acl_association`.
    2.  **ARN Presence and Validity Check:** For each identified association resource, it inspects the `web_acl_arn` attribute within its `applied` state.
    3.  **Violation Criteria:** A violation is flagged if the `web_acl_arn` is `null`, an empty string, or (in the current policy version reflecting specific test conditions) not the literal string `"has_value"`.
    4.  **Violation Tracking:** If an association fails these checks, its details are recorded.
    5.  **Policy Outcome:** The overall policy passes only if no violations are found.

*   **Rationale for Design and Chosen Values:**
    *   **Ensuring Intended WAF Protection:** `aws_wafv2_web_acl_association` links WAF ACLs to resources like ALBs or API Gateways. A missing or invalid `web_acl_arn` means no WAF protection is applied.
    *   **Catching Configuration Errors Early:** Identifies misconfigurations at the Terraform plan stage.
    *   **The `"has_value"` String Check:** While specific to current test mocks, the underlying principle is to ensure the `web_acl_arn` is present and valid. In production, this might be an ARN format check.

*   **Benefits of this Policy:**
    *   Guaranteed WAF linkage for associated resources.
    *   Prevention of unprotected deployments of critical infrastructure.
    *   Proactive error correction before `terraform apply`.
    *   Maintains security standards for WAF application.

*   **Potential Impact if Violated:**
    *   Exposed resources (ALBs, API Gateways) become vulnerable to web attacks (SQLi, XSS, DoS).
    *   Higher likelihood of security incidents and service disruptions.
    *   Potential compliance breaches if WAF usage is mandated.

*   **Recommended Enforcement Level & Rationale:**
    *   **Level:** `hard-mandatory`
    *   **Rationale:** The purpose of an `aws_wafv2_web_acl_association` is to link a WAF. If the `web_acl_arn` is invalid, the resource fails its primary objective. A `hard-mandatory` level is justified to prevent deployment of such non-functional and insecure configurations.

*   **Advisory Statement:**
    > The `waf-attached-loadbalancer.sentinel` policy is crucial for ensuring that your WAF defenses are correctly applied to all intended resources. It is strongly advised to maintain this policy with `hard-mandatory` enforcement. An `aws_wafv2_web_acl_association` lacking a valid `web_acl_arn` means the target resource (e.g., an ALB or API Gateway) is NOT protected by the WAF. This policy prevents such critical misconfigurations, safeguarding your applications from being inadvertently exposed to web-based threats. Disabling or weakening this policy significantly increases security risks.

---

### 3. `waf-attached-loadbalancer-full-plan.sentinel`

*   **Note on Similarity:** This policy is functionally identical to `waf-attached-loadbalancer.sentinel`. The analysis, rationale, and advisory statements provided for `waf-attached-loadbalancer.sentinel` apply directly to this policy as well. The suffix "-full-plan" may indicate its intended use or testing against complete Terraform plan outputs, but the core Sentinel logic for validation remains the same.

*   **High-Level Purpose:**
    To verify that every AWS WAFv2 Web ACL association resource (`aws_wafv2_web_acl_association`) defined in the Terraform plan has a valid Web ACL ARN (`web_acl_arn`) assigned.

*   **Detailed Logic Breakdown:** (Same as `waf-attached-loadbalancer.sentinel`)
    1.  Resource Identification.
    2.  ARN Presence and Validity Check.
    3.  Violation Criteria (including the `"has_value"` check specific to current test mocks).
    4.  Violation Tracking.
    5.  Policy Outcome: Passes if no violations.

*   **Rationale for Design and Chosen Values:** (Same as `waf-attached-loadbalancer.sentinel`)
    *   Ensuring intended WAF protection.
    *   Catching configuration errors early.

*   **Benefits of this Policy:** (Same as `waf-attached-loadbalancer.sentinel`)
    *   Guaranteed WAF linkage.
    *   Prevention of unprotected deployments.
    *   Proactive error correction.
    *   Maintains security standards.

*   **Potential Impact if Violated:** (Same as `waf-attached-loadbalancer.sentinel`)
    *   Exposed resources.
    *   Increased security incidents.
    *   Compliance breaches.

*   **Recommended Enforcement Level & Rationale:** (Same as `waf-attached-loadbalancer.sentinel`)
    *   **Level:** `hard-mandatory`
    *   **Rationale:** Essential for ensuring WAF association resources are functional.

*   **Advisory Statement:**
    > The `waf-attached-loadbalancer-full-plan.sentinel` policy, like its counterpart `waf-attached-loadbalancer.sentinel`, is critical for ensuring your WAF defenses are correctly applied. It is strongly advised to maintain this policy with `hard-mandatory` enforcement. An `aws_wafv2_web_acl_association` lacking a valid `web_acl_arn` means the target resource is NOT protected by the WAF. This policy prevents such critical misconfigurations. Disabling or weakening this policy significantly increases security risks.

---
## General Testing

To test these policies locally, you can use the Sentinel CLI. Ensure you have mock data or actual Terraform plan JSON files representing scenarios that both pass and fail each policy.

Example commands:
```bash
# Validate policy syntax
sentinel validate <policy_name.sentinel>

# Format a policy
sentinel fmt <policy_name.sentinel>

# Test a policy with mock data (tfplan.json)
# Assuming sentinel.hcl or similar defines the mock for tfplan
sentinel test <policy_name.sentinel>

# Apply a policy against a specific Terraform plan JSON
terraform plan -out=tfplan.binary
terraform show -json tfplan.binary > plan.json
sentinel apply -config=sentinel.hcl <policy_name.sentinel>
```
Refer to the `test/` directory within this repository for specific test configurations and mock data used for these policies.