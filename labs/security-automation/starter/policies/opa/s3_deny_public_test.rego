package s3.deny_public

import future.keywords.if

# --- FAILING fixtures: these MUST produce a deny ---------------------------

test_deny_principal_star if {
	deny with input as {"Statement": [{
		"Sid": "PublicGet",
		"Effect": "Allow",
		"Principal": "*",
		"Action": "s3:GetObject",
		"Resource": "arn:aws:s3:::acme-public/*",
	}]}
}

test_deny_principal_aws_star if {
	deny with input as {"Statement": [{
		"Sid": "PublicAll",
		"Effect": "Allow",
		"Principal": {"AWS": "*"},
		"Action": "s3:*",
		"Resource": "arn:aws:s3:::acme-public/*",
	}]}
}

test_deny_principal_aws_list_with_star if {
	deny with input as {"Statement": [{
		"Sid": "PublicList",
		"Effect": "Allow",
		"Principal": {"AWS": ["arn:aws:iam::111122223333:root", "*"]},
		"Action": "s3:GetObject",
		"Resource": "arn:aws:s3:::acme-public/*",
	}]}
}

# --- PASSING fixtures: these MUST NOT produce any deny ----------------------

test_allow_scoped_principal if {
	count(deny) == 0 with input as {"Statement": [{
		"Sid": "OneAccount",
		"Effect": "Allow",
		"Principal": {"AWS": "arn:aws:iam::111122223333:root"},
		"Action": "s3:GetObject",
		"Resource": "arn:aws:s3:::acme-private/*",
	}]}
}

test_allow_public_principal_but_deny_effect if {
	# Principal '*' under a Deny is a guardrail, not a public grant.
	count(deny) == 0 with input as {"Statement": [{
		"Sid": "DenyInsecureTransport",
		"Effect": "Deny",
		"Principal": "*",
		"Action": "s3:*",
		"Resource": "arn:aws:s3:::acme-private/*",
		"Condition": {"Bool": {"aws:SecureTransport": "false"}},
	}]}
}
