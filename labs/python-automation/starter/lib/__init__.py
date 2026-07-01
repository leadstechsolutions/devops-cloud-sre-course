"""Shared helpers for the python-automation lab.

The only module here that touches AWS is :mod:`lib.awsclient`. Everything else in
the lab is pure-Python business logic that operates on already-fetched data, so it
can be unit-tested with no network and no boto3 installed.
"""
