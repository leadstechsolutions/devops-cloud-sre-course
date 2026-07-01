package s3.deny_public

# Deny any S3 bucket policy statement that makes the bucket public.
#
# Input shape (a Terraform plan resource, an aws_s3_bucket_policy "policy"
# decoded to JSON, or a raw bucket policy document):
#
#   {
#     "Statement": [
#       {"Effect": "Allow", "Principal": "*",            "Action": "s3:GetObject", ...},
#       {"Effect": "Allow", "Principal": {"AWS": "*"},   "Action": "s3:*",         ...}
#     ]
#   }
#
# `deny` is a set of human-readable strings. A non-empty `deny` set means the
# input violates policy -- this is the conftest / `opa test` convention.

import future.keywords.contains
import future.keywords.if
import future.keywords.in

# Principal == "*"
principal_is_public(p) if {
	p == "*"
}

# Principal == {"AWS": "*"}
principal_is_public(p) if {
	p.AWS == "*"
}

# Principal == {"AWS": ["*", ...]}
principal_is_public(p) if {
	some v in p.AWS
	v == "*"
}

deny contains msg if {
	some stmt in input.Statement
	stmt.Effect == "Allow"
	principal_is_public(stmt.Principal)
	msg := sprintf(
		"S3 statement Sid=%v allows public access (Principal '*')",
		[object.get(stmt, "Sid", "<no-sid>")],
	)
}
