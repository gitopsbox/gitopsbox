# GitOpsBox

GitOpsBox is a shell script that creates a bootable ISO that deploys via script a ready-to-use CICD environment. It provides Virtual Machines, Kubernetes, Firewall, Network Intrusion Prevention Service, CICD and Secure Password Store. Including Proxmox, pfSense, K3S, Gitlab, Hashicorp Vault and VSCode Server. Optionally you can deploy with just Proxmox with pfSense.

![GitOpsBox Diagram](/Documentation/gitopsboxdiagram.png)

Get started with the [guide](https://github.com/gitopsbox/gitopsbox/edit/main/README.md#guide) or build the iso immediately with this one liner :

```wget https://raw.githubusercontent.com/gitopsbox/gitopsbox/main/gitopsbox.sh && bash gitopsbox.sh```

## Documentation

[Known Issues](https://github.com/gitopsbox/gitopsbox/issues)

[Potential Future Features](Documentation/FutureFeatures.md)

[Architecture & Design](Documentation/Architecture.md)

[Script Options](Documentation/Options.md)

## Guide

You need a server to install GitOpsBox and a second PC with a web browser to connect to it. Install ubuntu desktop on the server temporarily, download and execute the script so you can build the ISO/USB and assign the 3 network interfaces. Boot the same server with the created USB. Use the web browser on the second PC to open the Proxmox web interface.

### Requirements

#### Server(Physical or Virtual)

- x86-64 4 core(4 cores needed for Gitlab Kubernetes deployment)
- 3 Network Interfaces
- 32GB RAM

#### ISO build environment

Note that building the ISO from a live environment does not work.

- x86-64
- Ubuntu Desktop 20.04LTS or 22.04LTS
- USB flash drive or DVDRW

**Internet access**

*OR*

*ubuntu .deb packages :*

- *xorriso*
- *curl*

*ISO files in script directory :*

- *Proxmox Virtual Environment(PVE)*
- *pfSense (iso.gz format)*
- *Ubuntu Minimal cloud .img (If GitOps enabled)*

*You can opt to download the above files using the build script's download only mode and then build the ISO offline.*

### Directions

Acquiring the logical network names for the 3 interfaces is required for the ISO to build. It is preferable to build the ISO on the same machine you want to install GitOpsBox to as the script will identify the NIC's for you.

The script defaults network settings to mgmt.example.com, 172.16.1.1/20 lan.example.com, 10.1.1.1/20. [Refer to Script Options](Documentation/Options.md) for details on how to change these.

Install ubuntu to the build PC, ensure it has internet access or you have the iso/package files in the script directory. Create a new directory and open a terminal.

One liner :

```wget https://raw.githubusercontent.com/gitopsbox/gitopsbox/main/gitopsbox.sh && bash gitopsbox.sh```

Or download the script(save link as) :

[https://raw.githubusercontent.com/gitopsbox/gitopsbox/main/gitopsbox.sh](https://raw.githubusercontent.com/gitopsbox/gitopsbox/main/gitopsbox.sh)

OR zip of repository:
[https://github.com/gitopsbox/gitopsbox/archive/refs/heads/main.zip](https://github.com/gitopsbox/gitopsbox/archive/refs/heads/main.zip)

to the new directory, verify the script is safe, open the terminal and run :

```bash gitopsbox.sh```

The script will ask for sudo credentials and prompt questions about :

- Download only or build iso.
- Identify WAN, LAN and Management interfaces.
- Auto-format hard drive during install.
- Pause deployment for manual WAN configuration.
- Timezone.
- Downloading ISO files.
- File checksums.
- Format USB with created iso.

Log files are created during the ISO build process in the same directory as the script. Download and create ISO in ~15 mins.

Insert the USB on the server and boot as per normal. From USB deployment to pfSense providing a DHCP lease the time is ~20 mins.

Connect your second device to the management network. The proxmox web interface will be available on the management network at **https://172.16.2.1:8006**

**The default login credentials are username: root password: r00tme**

There will be a temporary Virtual Machine(VM) indicating progress of the build. Descriptions of the virtual machines provide the web interface addresses for the applications.

#### Management Network
- Proxmox Virtual Environment
- pfSense
- Hashicorp Vault
- Gitlab

#### LAN Network
- VS Code server
- Gitlab
- Hashicorp Vault

There is a build log found on Proxmox under /var/log/

Gitlab job history also provides logs of the LAN Kubernetes deployment and code server.

Once the build progress VM has deleted, 2 Gitlab jobs are complete and Code Server is deployed, GitOpsBox has finished installing. The total deployment time is roughly 1-1.5 hrs.

Deployment times will depend on hardware performance and internet speed.

**You can now change passwords for Proxmox, pfSense.** Randomized passwords for gitlab, vault and kubeconfigs are available in the home directory of root on PVE. These should be backed up and removed from this directory. Vault unseal keys are designed to be split up and secured.

The next steps are up to you but creating new maintainer/developer accounts in gitlab with rights for the LAN group and provisioning applications through new projects using CICD is typical. The CreateNewProjectWithAgent project can programmatically create new projects with kubernetes agent deployed.

A web browser on the LAN Network can reach **code.lan.example.com** and **gitlab.mgmt.example.com** and **vault.mgmt.example.com**. LAN network is intended only for accessing the LAN group in gitlab and vault but this is only currently enforced by account permissions. Gitlab projects will provide links for git clone HTTPS or SSH that can be used in VS Code.

Management network is intended only for provisioning new Virtual Machines, Proxmox, pfSense, Gitlab and Vault administration.

## Novel Features

- Script that builds from latest versions that postdate script creation.

- pfSense scripted install.
- pfSense management network, preconfigured IPS and adblocking.
- pfSense/unbound split DNS.

- Install and configure Virtual Machines in Proxmox without network connection via used of sendkey or serial terminal/expect.

- Unattended Proxmox install.

- Proxmox uses self-hosted pfSense VM as it's own gateway.

- Ubuntu minimal cloud images as VM's running K3S as kubernetes hosts.

- Gitlab deployed via helm with traefik and working SSH.

- Scripted gitlab kagent install.

- Vault deployed via helm with e2e TLS with self-signed certificate.

- Code-Server deployed with root permission removed and Microsoft extensions store.

=======================================

*This script is intended for educational purposes and not to be sold as a product. It is provided under open source MIT license. It is provided as-is and without any warranty. Trademarks are owned by their respective owners. This script is not associated, affiliated or endorsed by/with any other software project. Please support the developers of the products through their respective websites.*
