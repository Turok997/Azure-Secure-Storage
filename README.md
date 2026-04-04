Azure Secure Storage Enclave
Overview

This project implements a Zero-Trust Network Architecture to secure an Azure Storage Account. The primary objective is to ensure that sensitive data is completely isolated from the public internet and accessible only via verified, internal network paths.

Using Terraform, this repository automates the deployment of a Hub-and-Spoke topology, Private Link integration, and a private DNS strategy.

```mermaid
graph LR
    subgraph Internet
        User((External User))
    end

    subgraph "Azure Region (West Europe)"
        subgraph "Hub VNet (10.0.0.0/16)"
            HubGate[Management Gateway]
        end

        subgraph "Spoke VNet (10.1.0.0/16)"
            direction TB
            subgraph "Endpoint Subnet (10.1.1.0/24)"
                PE[Private Endpoint]
                DNS[Private DNS Record]
            end
            
            subgraph "Storage Service"
                ST[(Secure Storage)]
            end
        end
    end

    User -- "Blocked (403)" --> ST
    HubGate -- "Peering" --> PE
    PE -- "Private Link" --> ST
    DNS -. "Resolves to 10.1.1.x" .-> PE
```

Architecture Highlights

The infrastructure is built on the following core components:

    Hub-and-Spoke VNet Topology: Logical separation between the management network (Hub) and the resource-hosting network (Spoke).

    Virtual Network Peering: Enables low-latency, private routing between the two networks without traversing the public internet.

    Private Endpoint: Assigns a dedicated private IP address from the Spoke subnet to the Storage Account.

    Private DNS Zone: Implements internal name resolution so that blob.core.windows.net requests stay within the Azure backbone.

    Network Firewall (Stateless): The Storage Account is configured with default_action = "Deny", effectively "blackholing" all unauthorized external traffic.

Technical Specifications

    Infrastructure as Code: Terraform (AzureRM Provider ~> 3.0)

    Storage Configuration: Standard Tier with LRS (Locally Redundant Storage) for cost-efficiency.

    Security Posture: Public Network Access Disabled; Shared Key Access Enabled (supporting SAS token delegation).

    DNS Resolution: Private DNS Zone for privatelink.blob.core.windows.net.

    Address Space: Hub Network (10.0.0.0/16) and Spoke Network (10.1.0.0/16).

Getting Started
Prerequisites

    An active Azure Subscription.

    Terraform CLI installed.

    Authenticated session via Azure CLI (az login).

Deployment Steps

    Clone the repository:
    Bash

    git clone https://github.com/Turok997/azure-secure-storage.git
    cd azure-secure-storage

    Initialize the working directory:
    Bash

    terraform init

    Review the execution plan:
    Bash

    terraform plan
    

    Deploy the infrastructure:
    Bash

    terraform apply:
    Due to Azure Storage Firewall propagation latency, a subsequent terraform apply might be required to finalize container creation after whitelisting the deployment runner's IP

Verification and Security

    Isolation Test: Attempts to access the storage blob URL from a local machine will result in a 403 Forbidden error.

    Internal Access: Name resolution within the Spoke VNet will point to a private IP (e.g., 10.1.1.X).

    Split-Horizon DNS: This setup prevents DNS leaking and ensures that service endpoints are only discoverable internally.

Cleanup

To avoid ongoing costs (estimated < 1€ for a short deployment), ensure you destroy the resources after testing:

    terraform destroy