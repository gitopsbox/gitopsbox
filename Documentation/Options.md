# Script Options

In addition to the script's prompts there are more options available as variables within the script.

- waninterfacecard=
- laninterfacecard=
- mgmtinterfacecard=
  
Allows you to set NIC logical names so you are not prompted for them. For example if you create 3 virtual NIC's in Proxmox and host GitOpsBox as a VM the logical names are ens18, ens19, ens20.

- mgmtdomain=mgmt.example.com
- landomain=lan.example.com
  
Allows you to set domain names. Example.com is ICANN reserved for documentation purposes.

IP's, Hostnames and subnets can be changed within options also. Refer to Architecture document for more details.

External forwarded DNS server can be changed also, alternatively use the pfSense web interface.

pfSense/Suricata IDS/IPS can be enabled/disabled in options. Disabling will reduce CPU/RAM usage and prevent hosts from being blocked. Alternatively use the pfSense web interface.

- deploygitops=no

If you only want an environment with Proxmox and pfSense. This will remove the 32GB RAM and 4 CPU core requirements.

- enablepausedeployformanualwanconfig=yes

Pauses the GitOpsBox deployment so that you can manually configure the WAN for internet access as this is needed for kubernetes portion of GitOpsBox.

![Shared Network Screenshot](/Documentation/sharednetwork.png)

If you have a network that requires a login page(such as public wifi) then you can create a VM with 2 interfaces, one to the internet and one WAN nic. Connect to the login page and then select "Shared to other computers" under IPv4 options under wired settings for the WAN nic(ubuntu desktop). This creates a DHCP server on the VM that pfSense will lease an address from and receive internet access.

- enablenestedvirtualizationintel=no
- enablenestedvirtualizationamd=no

Set to yes to enable VM's to be able to host their own VM's.

- proxmoxrepoaccess=no

Blocks all internet traffic for Proxmox. This breaks GitOps as it needs expect installed.

- managementwebaccess=yes 

Allows outgoing 80,443 for the management network.

- deletebaseiso=yes 

Will delete the downloaded iso's after a build.

- managementemailaccess=yes

Allows outgoing firewall rules for email.

- managementaccessany=yes

Allows outgoing firewall rules for all traffic on MGMT.

- lanaccessany=yes

Allows outgoing firewall rules for all traffic on LAN.

vlans and ipv6 can be used on LAN and Management.

- pveinstallerdisabledhcp=yes
- pveinstallerdisablegrub=yes

Helps automates the Proxmox installer.
