# Operator Guide

## TODO:

* [ ] Write a design doc / operator guide
* [ ] Write bundle code
  * [ ] Defing params & connections JSON schema
  * [ ] Write 2-3 Guided Configs
  * [ ] Define artifact schema, design new artifact definitions if necessary
  * [ ] Test each guided config
  * [ ] View params schema in storybook, [write UI schema](https://react-jsonschema-form.readthedocs.io/en/latest/usage/widgets/) for sorting fields, etc
* [ ] Write user guide
* [ ] Remove this TODO block

_Brief description of bundle from an operator's point of view_

## Use Cases

_Common use cases for this bundle_

### Guided Configs

Guided config user descriptions:
Dev/test: Best for experimenting with AKS or deploying a test app.
Cost-optimized: Best for reducing costs on production workloads that can tolerate interruptions.
Standard: Best if you're not sure what to choose and works well with most applications.
Batch processing: Best for machine learning, compute-intensive, and graphics-intensive workloads. Suited for apps requiring fast scale-up and scale-out.
Hardened access: Best for large enterprises that need full control of security and stability.

## Design

### How It Works

_Describe how it works_

#### Best Practices

#### Security 

#### Auditing

#### Compliance

#### Observability

### Trade-offs

Problems to solve:
1. Each region offers a different range of VM sizes (US supported sizes: Dv5, Ev5)
- EastUS
  - Dv5
  - Dv4
  - B
  - Ev5
  - Ev4
  - Fv2
  - H
  - Dv3
  - Ev3
  - Dv2
- EastUS2
  - Dv5
  - Dv4
  - B
  - Ev5
  - Ev4
  - Fv2
  - Dv3
  - Ev3
  - Dv2
- NorthCentralUS
  - Dv5
  - Dv4
  - B
  - Ev5
  - Ev4
  - Fv2
  - Dv3
  - Ev3
  - Dv2
- CentralUS
  - Dv5
  - Ev5
  - L
- WestCentralUS
  - Dv5
  - Ev5
- SouthCentralUS
  - Dv5
  - Dv4
  - B
  - Ev5
  - Ev4
  - Fv2
  - H
  - N
  - Dv3
  - Ev3
  - Dv2
- WestUS
  - Dv5
  - Dv4
  - B
  - Ev5
  - Ev4
  - Fv2
  - Dv3
  - Ev3
  - Dv2
- WestUS2
  - Dv5
  - Ev5
  - H
- WestUS3
  - Dv5
  - Dv4
  - B
  - Ev5
  - Ev4
  - Fv2
  - Dv3
  - Ev3
  - Dv2

### Permissions

_list IAM permissions required on this bundle._
