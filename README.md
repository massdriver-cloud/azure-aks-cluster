




[![Massdriver][logo]][website]

# azure-aks-cluster

[![Release][release_shield]][release_url]
[![Contributors][contributors_shield]][contributors_url]
[![Forks][forks_shield]][forks_url]
[![Stargazers][stars_shield]][stars_url]
[![Issues][issues_shield]][issues_url]
[![MIT License][license_shield]][license_url]

<!--
##### STILL NEED TO GET SLACK WORKING ###
[!["Slack Community"](%s)][slack]
-->


Azure Kubernetes Service (AKS) is a fully managed container orchestration service. AKS offers serverless Kubernetes, an integrated continuous integration and continuous delivery (CI/CD) experience, and enterprise-grade security and governance.


---

## Design

For detailed information, check out our [Operator Guide](operator.mdx) for this bundle.

## Usage

Our bundles aren't intended to be used locally, outside of testing. Instead, our bundles are designed to be configured, connected, deployed and monitored in the [Massdriver][website] platform.

### What are Bundles?

Bundles are the basic building blocks of infrastructure, applications, and architectures in [Massdriver][website]. Read more [here](https://docs.massdriver.cloud/concepts/bundles).

## Bundle

### Params

Form input parameters for configuring a bundle for deployment.

<details>
<summary>View</summary>

<!-- PARAMS:START -->
## Properties

- **`cluster`** *(object)*: Configure the Kubernetes cluster.
  - **`enable_log_analytics`** *(boolean)*: Enable Log Analytics for this cluster. Default: `False`.
  - **`kubernetes_version`** *(string)*: The version of Kubernetes that should be used for this cluster. You will be able to upgrade this version after creating the cluster, but you cannot downgrade the version. Must be one of: `['1.24', '1.23', '1.22']`. Default: `1.24`.
- **`core_services`** *(object)*: Configure core services in Kubernetes for Massdriver to manage.
  - **`azure_dns_zones`** *(object)*: List any Azure DNS Zones associated with this cluster to allow the Kubernetes to automatically manage DNS records and SSL certificates.
    - **`dns_zones`** *(array)*: The name of the Azure DNS zone for the AKS Cluster.
      - **Items** *(string)*
    - **`resource_group`** *(string)*: The name of the Resource Group the Azure DNS zones are in (all zones must share the same Resource Group).
  - **`enable_ingress`** *(boolean)*: Enabling this will create an NGINX Ingress Controller in the cluster, allowing internet traffic to flow into web accessible services within the cluster. Default: `False`.
- **`node_groups`** *(object)*: The node groups that should be used for this cluster.
  - **`additional_node_groups`** *(array)*: Default: `[]`.
    - **Items** *(object)*
      - **`max_size`** *(number)*: Maximum number of instances in the node group. Minimum: `1`. Maximum: `1000`. Default: `10`.
      - **`min_size`** *(number)*: Minimum number of instances in the node group. Minimum: `1`. Maximum: `1000`. Default: `1`.
      - **`name`** *(string)*
      - **`node_size`** *(string)*: Compute size to use in the node group (D = General Purpose, E = Memory Optimized, F = Compute Optimized). Changing this forces a deletion and re-creation of the node group.
        - **One of**
          - D2s (2 vCores, 8 GiB memory)
          - D4s (4 vCores, 16 GiB memory)
          - D8s (8 vCores, 32 GiB memory)
          - D16s (16 vCores, 64 GiB memory)
          - D32s (32 vCores, 64 GiB memory)
          - D64s (64 vCores, 256 GiB memory)
          - E2s (2 vCores, 16 GiB memory)
          - E4s (4 vCores, 32 GiB memory)
          - E8s (8 vCores, 64 GiB memory)
          - E16s (8 vCores, 128 GiB memory)
          - E32s (32 vCores, 256 GiB memory)
          - E64s (64 vCores, 432 GiB memory)
          - F2s (2 vCores, 4 GiB memory)
          - F4s (4 vCores, 8 GiB memory)
          - F8s (8 vCores, 16 GiB memory)
          - F16s (16 vCores, 32 GiB memory)
          - F32s (32 vCores, 64 GiB memory)
          - F64s (64 vCores, 128 GiB memory)
  - **`default_node_group`** *(object)*: Configuration of the node group.
    - **`max_size`** *(number)*: Maximum number of instances in the node group. Minimum: `1`. Maximum: `1000`. Default: `10`.
    - **`min_size`** *(number)*: Minimum number of instances in the node group. Minimum: `1`. Maximum: `1000`. Default: `1`.
    - **`name`** *(string)*: The name of the node group.
    - **`node_size`** *(string)*: Compute size to use in the node group (D = General Purpose, E = Memory Optimized, F = Compute Optimized). Changing this forces a deletion and re-creation of the node group.
      - **One of**
        - D2s (2 vCores, 8 GiB memory)
        - D4s (4 vCores, 16 GiB memory)
        - D8s (8 vCores, 32 GiB memory)
        - D16s (16 vCores, 64 GiB memory)
        - D32s (32 vCores, 64 GiB memory)
        - D64s (64 vCores, 256 GiB memory)
        - E2s (2 vCores, 16 GiB memory)
        - E4s (4 vCores, 32 GiB memory)
        - E8s (8 vCores, 64 GiB memory)
        - E16s (8 vCores, 128 GiB memory)
        - E32s (32 vCores, 256 GiB memory)
        - E64s (64 vCores, 432 GiB memory)
        - F2s (2 vCores, 4 GiB memory)
        - F4s (4 vCores, 8 GiB memory)
        - F8s (8 vCores, 16 GiB memory)
        - F16s (16 vCores, 32 GiB memory)
        - F32s (32 vCores, 64 GiB memory)
        - F64s (64 vCores, 128 GiB memory)
- **`observability`** *(object)*: Configure logging and metrics collection and delivery for your entire cluster.
  - **`logging`** *(object)*: Configure logging for your cluster.
    - **`destination`** *(string)*: Where to send logs. Default: `disabled`.
      - **One of**
        - OpenSearch (in cluster)
        - Disabled
## Examples

  ```json
  {
      "__name": "Development",
      "node_groups": {
          "default_node_group": {
              "max_size": 10,
              "min_size": 1,
              "name": "default",
              "node_size": "Standard_D2s_v3"
          }
      }
  }
  ```

  ```json
  {
      "__name": "Production",
      "node_groups": {
          "additional_node_groups": [
              {
                  "max_size": 10,
                  "min_size": 1,
                  "name": "shared",
                  "node_size": "Standard_D8s_v3"
              }
          ],
          "default_node_group": {
              "max_size": 10,
              "min_size": 1,
              "name": "default",
              "node_size": "Standard_D8s_v3"
          }
      }
  }
  ```

<!-- PARAMS:END -->

</details>

### Connections

Connections from other bundles that this bundle depends on.

<details>
<summary>View</summary>

<!-- CONNECTIONS:START -->
## Properties

- **`azure_service_principal`** *(object)*: . Cannot contain additional properties.
  - **`data`** *(object)*
    - **`client_id`** *(string)*: A valid UUID field.

      Examples:
      ```json
      "123xyz99-ab34-56cd-e7f8-456abc1q2w3e"
      ```

    - **`client_secret`** *(string)*
    - **`subscription_id`** *(string)*: A valid UUID field.

      Examples:
      ```json
      "123xyz99-ab34-56cd-e7f8-456abc1q2w3e"
      ```

    - **`tenant_id`** *(string)*: A valid UUID field.

      Examples:
      ```json
      "123xyz99-ab34-56cd-e7f8-456abc1q2w3e"
      ```

  - **`specs`** *(object)*
- **`vnet`** *(object)*: . Cannot contain additional properties.
  - **`data`** *(object)*
    - **`infrastructure`** *(object)*
      - **`cidr`** *(string)*

        Examples:
        ```json
        "10.100.0.0/16"
        ```

        ```json
        "192.24.12.0/22"
        ```

      - **`default_subnet_id`** *(string)*: Azure Resource ID.

        Examples:
        ```json
        "/subscriptions/12345678-1234-1234-abcd-1234567890ab/resourceGroups/resource-group-name/providers/Microsoft.Network/virtualNetworks/network-name"
        ```

      - **`id`** *(string)*: Azure Resource ID.

        Examples:
        ```json
        "/subscriptions/12345678-1234-1234-abcd-1234567890ab/resourceGroups/resource-group-name/providers/Microsoft.Network/virtualNetworks/network-name"
        ```

  - **`specs`** *(object)*
    - **`azure`** *(object)*: .
      - **`region`** *(string)*: Select the Azure region you'd like to provision your resources in.
        - **One of**
          - East US
          - North Central US
          - South Central US
          - West US
<!-- CONNECTIONS:END -->

</details>

### Artifacts

Resources created by this bundle that can be connected to other bundles.

<details>
<summary>View</summary>

<!-- ARTIFACTS:START -->
## Properties

- **`kubernetes_cluster`** *(object)*: Kubernetes cluster authentication and cloud-specific configuration. Cannot contain additional properties.
  - **`data`** *(object)*
    - **`authentication`** *(object)*
      - **`cluster`** *(object)*
        - **`certificate-authority-data`** *(string)*
        - **`server`** *(string)*
      - **`user`** *(object)*
        - **`token`** *(string)*
    - **`infrastructure`** *(object)*: Cloud specific Kubernetes configuration data.
      - **One of**
        - AWS EKS infrastructure config*object*: . Cannot contain additional properties.
          - **`arn`** *(string)*: Amazon Resource Name.

            Examples:
            ```json
            "arn:aws:rds::ACCOUNT_NUMBER:db/prod"
            ```

            ```json
            "arn:aws:ec2::ACCOUNT_NUMBER:vpc/vpc-foo"
            ```

          - **`oidc_issuer_url`** *(string)*: An HTTPS endpoint URL.

            Examples:
            ```json
            "https://example.com/some/path"
            ```

            ```json
            "https://massdriver.cloud"
            ```

        - Azure Infrastructure Resource ID*object*: Minimal Azure Infrastructure Config. Cannot contain additional properties.
          - **`ari`** *(string)*: Azure Resource ID.

            Examples:
            ```json
            "/subscriptions/12345678-1234-1234-abcd-1234567890ab/resourceGroups/resource-group-name/providers/Microsoft.Network/virtualNetworks/network-name"
            ```

        - GCP Infrastructure GRN*object*: Minimal GCP Infrastructure Config. Cannot contain additional properties.
          - **`grn`** *(string)*: GCP Resource Name (GRN).

            Examples:
            ```json
            "projects/my-project/global/networks/my-global-network"
            ```

            ```json
            "projects/my-project/regions/us-west2/subnetworks/my-subnetwork"
            ```

            ```json
            "projects/my-project/topics/my-pubsub-topic"
            ```

            ```json
            "projects/my-project/subscriptions/my-pubsub-subscription"
            ```

            ```json
            "projects/my-project/locations/us-west2/instances/my-redis-instance"
            ```

            ```json
            "projects/my-project/locations/us-west2/clusters/my-gke-cluster"
            ```

  - **`specs`** *(object)*
    - **`kubernetes`** *(object)*: Kubernetes distribution and version specifications.
      - **`cloud`** *(string)*: Must be one of: `['aws', 'gcp', 'azure']`.
      - **`distribution`** *(string)*: Must be one of: `['eks', 'gke', 'aks']`.
      - **`platform_version`** *(string)*
      - **`version`** *(string)*
<!-- ARTIFACTS:END -->

</details>

## Contributing

<!-- CONTRIBUTING:START -->

### Bug Reports & Feature Requests

Did we miss something? Please [submit an issue](https://github.com/massdriver-cloud/azure-aks-cluster/issues) to report any bugs or request additional features.

### Developing

**Note**: Massdriver bundles are intended to be tightly use-case scoped, intention-based, reusable pieces of IaC for use in the [Massdriver][website] platform. For this reason, major feature additions that broaden the scope of an existing bundle are likely to be rejected by the community.

Still want to get involved? First check out our [contribution guidelines](https://docs.massdriver.cloud/bundles/contributing).

### Fix or Fork

If your use-case isn't covered by this bundle, you can still get involved! Massdriver is designed to be an extensible platform. Fork this bundle, or [create your own bundle from scratch](https://docs.massdriver.cloud/bundles/development)!

<!-- CONTRIBUTING:END -->

## Connect

<!-- CONNECT:START -->

Questions? Concerns? Adulations? We'd love to hear from you!

Please connect with us!

[![Email][email_shield]][email_url]
[![GitHub][github_shield]][github_url]
[![LinkedIn][linkedin_shield]][linkedin_url]
[![Twitter][twitter_shield]][twitter_url]
[![YouTube][youtube_shield]][youtube_url]
[![Reddit][reddit_shield]][reddit_url]

<!-- markdownlint-disable -->

[logo]: https://raw.githubusercontent.com/massdriver-cloud/docs/main/static/img/logo-with-logotype-horizontal-400x110.svg
[docs]: https://docs.massdriver.cloud/?utm_source=github&utm_medium=readme&utm_campaign=azure-aks-cluster&utm_content=docs
[website]: https://www.massdriver.cloud/?utm_source=github&utm_medium=readme&utm_campaign=azure-aks-cluster&utm_content=website
[github]: https://github.com/massdriver-cloud?utm_source=github&utm_medium=readme&utm_campaign=azure-aks-cluster&utm_content=github
[slack]: https://massdriverworkspace.slack.com/?utm_source=github&utm_medium=readme&utm_campaign=azure-aks-cluster&utm_content=slack
[linkedin]: https://www.linkedin.com/company/massdriver/?utm_source=github&utm_medium=readme&utm_campaign=azure-aks-cluster&utm_content=linkedin



[contributors_shield]: https://img.shields.io/github/contributors/massdriver-cloud/azure-aks-cluster.svg?style=for-the-badge
[contributors_url]: https://github.com/massdriver-cloud/azure-aks-cluster/graphs/contributors
[forks_shield]: https://img.shields.io/github/forks/massdriver-cloud/azure-aks-cluster.svg?style=for-the-badge
[forks_url]: https://github.com/massdriver-cloud/azure-aks-cluster/network/members
[stars_shield]: https://img.shields.io/github/stars/massdriver-cloud/azure-aks-cluster.svg?style=for-the-badge
[stars_url]: https://github.com/massdriver-cloud/azure-aks-cluster/stargazers
[issues_shield]: https://img.shields.io/github/issues/massdriver-cloud/azure-aks-cluster.svg?style=for-the-badge
[issues_url]: https://github.com/massdriver-cloud/azure-aks-cluster/issues
[release_url]: https://github.com/massdriver-cloud/azure-aks-cluster/releases/latest
[release_shield]: https://img.shields.io/github/release/massdriver-cloud/azure-aks-cluster.svg?style=for-the-badge
[license_shield]: https://img.shields.io/github/license/massdriver-cloud/azure-aks-cluster.svg?style=for-the-badge
[license_url]: https://github.com/massdriver-cloud/azure-aks-cluster/blob/main/LICENSE


[email_url]: mailto:support@massdriver.cloud
[email_shield]: https://img.shields.io/badge/email-Massdriver-black.svg?style=for-the-badge&logo=mail.ru&color=000000
[github_url]: mailto:support@massdriver.cloud
[github_shield]: https://img.shields.io/badge/follow-Github-black.svg?style=for-the-badge&logo=github&color=181717
[linkedin_url]: https://linkedin.com/in/massdriver-cloud
[linkedin_shield]: https://img.shields.io/badge/follow-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&color=0A66C2
[twitter_url]: https://twitter.com/massdriver?utm_source=github&utm_medium=readme&utm_campaign=azure-aks-cluster&utm_content=twitter
[twitter_shield]: https://img.shields.io/badge/follow-Twitter-black.svg?style=for-the-badge&logo=twitter&color=1DA1F2
[discourse_url]: https://community.massdriver.cloud?utm_source=github&utm_medium=readme&utm_campaign=azure-aks-cluster&utm_content=discourse
[discourse_shield]: https://img.shields.io/badge/join-Discourse-black.svg?style=for-the-badge&logo=discourse&color=000000
[youtube_url]: https://www.youtube.com/channel/UCfj8P7MJcdlem2DJpvymtaQ
[youtube_shield]: https://img.shields.io/badge/subscribe-Youtube-black.svg?style=for-the-badge&logo=youtube&color=FF0000
[reddit_url]: https://www.reddit.com/r/massdriver
[reddit_shield]: https://img.shields.io/badge/subscribe-Reddit-black.svg?style=for-the-badge&logo=reddit&color=FF4500

<!-- markdownlint-restore -->

<!-- CONNECT:END -->
