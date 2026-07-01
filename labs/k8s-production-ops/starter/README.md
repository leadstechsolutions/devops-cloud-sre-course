# k8s-production-ops — starter

This is your working copy. The supporting manifests are provided; you complete the
**two TODO stubs** and then run the drills (in `../solution/drills/`) against your
answers.

## What you must write

1. `manifests/pdb.yaml` — a `PodDisruptionBudget` guaranteeing at least 2 of the 3
   `cpu-burner` replicas survive a voluntary disruption.
2. `manifests/netpol/default-deny.yaml` — deny **all** ingress in the namespace.
3. `manifests/netpol/allow-client-to-server.yaml` — allow **only** `app=client`
   pods to reach `app=server` pods on TCP/8000.

Each stub file contains the requirements, hints, and the acceptance check.

## How to check your work

The drills live in the solution tree but read manifests relative to the **solution**
directory, so to test YOUR answers, copy them over the solution manifests in a scratch
checkout, or point the drills at this directory. The quickest check:

```bash
# from the lab root:
cd ..
# PDB: apply your stub and inspect ALLOWED DISRUPTIONS
kubectl --context kind-course create ns prodops-check
kubectl --context kind-course -n prodops-check apply -f starter/manifests/deployment.yaml
kubectl --context kind-course -n prodops-check apply -f starter/manifests/pdb.yaml
kubectl --context kind-course -n prodops-check rollout status deploy/cpu-burner
kubectl --context kind-course -n prodops-check get pdb cpu-burner    # expect ALLOWED DISRUPTIONS = 1
kubectl --context kind-course delete ns prodops-check

# NetworkPolicies: the full enforcement proof needs a Calico cluster — run the
# reference drill and compare your manifests to solution/manifests/netpol/*:
RUN_LIVE=1 ./solution/drills/networkpolicy.sh
```

When in doubt, diff against `../solution/manifests/`. See the top-level
[`../README.md`](../README.md) for the full task list and answer key.
