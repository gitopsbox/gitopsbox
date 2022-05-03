# Architecture

The ISO build script is designed to download the latest versions without requiring the script to be updated. However the script may encounter unforeseen issues as new releases are available or websites change. The latest product versions may have bugs so the script allows you to use existing files for older versions.

Overall the strategy is to deploy latest iso's and kubernetes images with automatic updates. This increases security, reduces manual maintenance but may cost stability.

All products are chosen to be open-source and production-ready. This means they are popular within their respective field, clusterable and offer professional support.

Tested on

- pfSense 2.5-2.6
- Proxmox 6-7
- Gitlab 14
- Ubuntu Minimal 20.04LTS 22.04LTS

## Gitlab

Gitlab is segregated into LAN and Management by groups.

Intention is for developers to create projects under LAN. Management is more controlled to protect Proxmox and pfSense. Management projects could deploy new VM's via existing proxmox server.

Gitlab currently has a limit of one runner per kubernetes instance.

Runners are divided by groups. There is one runner for LAN and one for Management.

Agents are per project and can be deployed also, they are more limited in function and typically provide GitOps Pull via kubernetes configured via helm. Multiple agents can be deployed per kubernetes instance.

The existing projects retrieve the kubeconfig from vault. Alternatively you could use a CICD variable or use the Kubernetes agent.

Gitlab recommends older builds of kubernetes. K3S and Gitlab may mismatch versions at some point.

## Time

The authoritive NTP server is pfSense. This is based on simplicity, single source of authority and the network gateway model.

Physical GPS devices are better at time sync and pfSense allows this to be connected via serial port.

QEMU provides RTC time determined by pfSense for virtual machines both networked and not. QEMU guest agent may help the time sync.

Physical machines on DHCP leases may get time from pfSense NTP. However NTP does not work out of the box on ubuntu clients as it is trying to reach internet based NTP servers. Firewall rules allowing internet NTP servers or NTP configuration on the client will resolve this.

Some organisations prefer server Timezones to be set to UTC mainly due to reducing discrepencies between regions. It is up to organsations how they set their timezones but time synchronisation is more important than timezones.

## DNS

pfSense is intended to be the DNS server for clients. It is configured to use Quad9 to perform SSL query forwarding. Forwarded DNS servers can be changed in the variable options. Although not all DNS security options are enforced this configuration has been tested to be more reliable.

MGMT and LAN allow different host entries similar to split DNS. Although Gitlab, Vault and kas management addresses are reachable from LAN to allow the Gitlab web interface and LAN runner to function.

DNS is filtered for advertising and malicious websites via pfBlocker.

## Network subnets

| Name          | IP            | Subnet Mask Bits |
| ------------- |:-------------:|:----------------:|
|LAN            |10.1.1.1       | /20              |
|Network devices|10.1.1.1       | /24              |
|Hypervisors    |10.1.2.1       | /24              |
|Kubernetes hosts|10.1.3.1      | /24              |
|Generic servers|10.1.4.1       | /23              |
|Kubernetes services|10.1.6.1   | /23              |
|Kubernetes pods|10.1.8.1       | /22              |
|DHCP issued clients|10.1.12.1  | /22              |

- pfSense LAN interface 10.1.1.1
- code.lan.example.com 10.1.3.1

| Name          | IP            | Subnet Mask Bits |
| ------------- |:-------------:|:----------------:|
|Management     |172.16.1.1     | /20              |
|Network devices|172.16.1.1     | /24              |
|Hypervisors    |172.16.2.1     | /24              |
|Kubernetes hosts|172.16.3.1    | /24              |
|Generic servers|172.16.4.1     | /23              |
|Kubernetes services|172.16.6.1 | /23              |
|Kubernetes pods|172.16.8.1     | /22              |
|DHCP issued clients|172.16.12.1| /22              |

- pfSense Management interface pfsense1.mgmt.example.com 172.16.1.1
- Proxmox Virtual Environment pve1.mgmt.example.com 172.16.2.1
- gitlab.mgmt.example.com 172.16.3.1
- kas.mgmt.example.com 172.16.3.1
- minio.mgmt.example.com 172.16.3.1
- vault.mgmt.example.com 172.16.3.1

Applications hosted on kubernetes are reachable on their FQDN which point to the kubernetes host IP acting as a loadbalancer provided by K3S Klipper.

These are the default IP and domain name settings and can be changed in the options variables.

## Firewall Rules

Rules process in first rule to match wins.

pfSense's default LAN to any rule is disabled.

Prevent Private Network Egress (disabled by default)

### LAN

- LAN Network to Management Kubernetes Host 443, SSH (Vault and Gitlab web interface/Git SSH usable from LAN)
- LAN Network to Management Blocked.
- LAN Network to pfSense NTP.
- LAN Network to pfSense DNS.
- LAN Network to any HTTPS.
- LAN Network to any HTTP.
- LAN Network to any. (Disabled)

### MGMT

- MGMT Network to pfSense Web interface.
- MGMT Network to any email. (Disabled)
- MGMT Network to LAN Network Blocked.
- MGMT Network to pfSense DNS.
- MGMT Network to any HTTPS. (Disabled)
- MGMT Network to any HTTP. (Disabled)
- MGMT PVE to debian/proxmox repositories.
- MGMT Network to pfSense NTP.
- MGMT Kubernetes Host to any HTTPS.
- MGMT Kubernetes Host to any HTTP.
- MGMT Network to WAN Blocked.
- MGMT Network to any. (Disabled)

## Intrusion Prevention System

By default Suricata IPS is enabled on WAN. This will increase RAM and CPU usage. You can monitor it for blocked hosts and disable within the pfSense interface. It is precustomised with blacklisted SID's based on typical web browsing false positives.

## Security

The entire system could be compromised at several points. In a rough order of severity :

- Hypervisor/Proxmox. If Proxmox could be compromised then all VM's are vulnerable.

- Gateway/pfSense. If the network gateway was compromised then traffic could be intercepted or remote access granted.

- Kubernetes hosts. If the VM running kubernetes is compromised all kubernetes workloads are vulnerable. Potentially the hypervisor is vulnerable to hypervisor escape.

- Vault. Contains passwords to other services.

- Gitlab. Compromis may allow access to vault via JWT, deploy malicious code through CICD, compromise it's own kubernetes host.

- Gitlab runner. Potentially could compromise kubernetes host. Gitlab recommends runner has it's own infrastructure.

Segregated management network is intended to secure this somewhat. Although LAN is able to access Gitlab and Vault. Currently segregation is achievable through account permissions, both products support IP segregation but this requires the paid version of gitlab.

Ideally segregation requires services to be isolated by network and virtual machines. Multiple instances of Gitlab and Vault would require many new VM's which would far exceed 32GB RAM requirements and increase complexity.
