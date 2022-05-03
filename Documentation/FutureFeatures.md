# Potential Future Features

An array allowing custom DNS entries.

Certificates are generated during deployment but there is no total list or keys exported. This will cause issues as they expire.

There is no certificate architecture. This could be handled by Vault, Kubernetes, pfSense, Proxmox or an offline server.

Self signed certificates are generated as part of the deployment. Signed certificates from Let's Encrypt may be preferable.

Backup task. Proxmox does provide a VM backup service. pfSense can export it's config file. Vault secrets may need to be backed up also. Depending on how you build the environment, in theory you can export custom git projects and place them in gitlabcustomprojects folder where the build script is located. Run the build script and these projects will be imported during deployment of the new iso.

Fully offline GitOps deployment. Currently the deployment of Proxmox and pfSense can be done offline. However anything running on kubernetes requires internet to deploy. The following issues would need to be solved to allow a full offline build :

Expect package install on proxmox.
Suricata and pfblocker-devel packages installed on pfSense.
K3S install.
Docker images for gitlab, vault and code-server either in an offline registry or cached(with kubelet configured to retain images).
Kubernetes deployments configured to not have any always pull images.
Package installs on ubuntu minimal.
Helm functioning offline.

Blue/Green Test/Production layout for gitlab CI/CD projects.

Ability to deploy GitOpsBox within cloud environments leveraging cloud services.

Allowing cluster formation and joining(Products were chosen to be clusterable)

Single NIC/Dual NIC/No Management network option.

Currently the proxmox installer wizard is automated with user settings during bash script. Instead the wizard could be modified to add additional GitOpsBox options such as the 3 NIC assignments and the build script would not prompt for options.
This would require significant rewrite and packages to be installed in the proxmox installer such as SED and curl. In theory if curl was available during the vanilla proxmox installer, the GitOpsBox script could be retrieved and executed.
