# AWS-MRTG-Mesh (Multi-Region Transit Gateway Mesh)

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-purple.svg)](https://www.terraform.io/)
[![Python](https://img.shields.io/badge/Python-3.8%2B-brightgreen.svg)](https://www.python.org/)

**AWS-MRTG-Mesh** is an Infrastructure as Code (IaC) project designed to automate the deployment and validation of a Multi-Region Transit Gateway (TGW) Mesh architecture on AWS. It provides scalable, cross-region VPC connectivity alongside automated route validation scripts.

---

## Architecture Overview

The project creates a full-mesh topology across multiple AWS regions using Transit Gateways and VPC attachments:

* **Modular VPC Setup:** Deploys configurable VPCs across multiple regions with isolated subnet topologies.
* **TGW Mesh Networking:** Connects AWS Transit Gateways via intra-region attachments and cross-region peering.
* **Automated Validation:** Includes Python tooling to audit Transit Gateway route tables, ensuring active connectivity and detecting blackhole or missing routes.

---

## 📁 Repository Structure

```text
AWS-MRTG-Mesh/
├── terraform/
│   ├── modules/
│   │   ├── vpc/          # Reusable VPC infrastructure module
│   │   └── tgw/          # Reusable Transit Gateway module
│   ├── main.tf           # Main entry point combining modules
│   ├── providers.tf      # Multi-region AWS provider setup
│   ├── variables.tf      # Global input variables
│   ├── outputs.tf        # Core infrastructure outputs
│   └── terraform.tfvars.example
└── scripts/
    ├── validate_routes.py # Route validation tool (boto3)
    └── requirements.txt   # Python dependencies
