# AWS-MRTG-Mesh: Multi-Region Transit Gateway Mesh Architecture

![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![License-MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)

A production-grade, highly available Infrastructure-as-Code (IaC) baseline implementing an enterprise multi-region network mesh on AWS using **AWS Transit Gateway (TGW) Peering**, isolated routing domains, and dynamic route inspection tooling.

---

## Architecture Overview

The architecture interconnects multi-AZ VPC workloads across two separate AWS regions (`us-east-1` and `eu-west-1`) over the encrypted AWS regional backbone. Custom Transit Gateway Route Tables ensure isolated traffic domains between workload tiers and cross-region transit paths.

graph TD
    subgraph Region_Primary ["AWS Region: us-east-1 (Primary)"]
        subgraph VPC_A ["Primary Workload VPC (10.1.0.0/16)"]
            Subnet_A1["Private Subnet AZ1"]
            Subnet_A2["Private Subnet AZ2"]
            Subnet_TGW_A["TGW Dedicated Subnets"]
        end

        TGW_A["Primary Transit Gateway<br/>(ASN: 64512)"]
        RT_Workload_A["Workload TGW Route Table"]
        
        Subnet_TGW_A -->|VPC Attachment| TGW_A
        TGW_A --- RT_Workload_A
    end

    subgraph Region_Secondary ["AWS Region: eu-west-1 (Secondary)"]
        subgraph VPC_B ["Secondary Workload VPC (10.101.0.0/16)"]
            Subnet_B1["Private Subnet AZ1"]
            Subnet_B2["Private Subnet AZ2"]
            Subnet_TGW_B["TGW Dedicated Subnets"]
        end

        TGW_B["Secondary Transit Gateway<br/>(ASN: 64513)"]
        RT_Workload_B["Workload TGW Route Table"]

        Subnet_TGW_B -->|VPC Attachment| TGW_B
        TGW_B --- RT_Workload_B
    end

    TGW_A <==>|TGW Inter-Region Peering Attachment| TGW_B
