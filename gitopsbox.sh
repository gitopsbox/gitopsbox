#! /bin/bash
echo '  ______  __   __      ______                    _______'
echo ' /      \|  \ |  \    /      \                  |       \'
echo '|  ▓▓▓▓▓▓\\▓▓_| ▓▓_  |  ▓▓▓▓▓▓\ ______   _______| ▓▓▓▓▓▓▓\ ______  __    __'
echo '| ▓▓ __\▓▓  \   ▓▓ \ | ▓▓  | ▓▓/      \ /       \ ▓▓__/ ▓▓/      \|  \  /  \'
echo '| ▓▓|    \ ▓▓\▓▓▓▓▓▓ | ▓▓  | ▓▓  ▓▓▓▓▓▓\  ▓▓▓▓▓▓▓ ▓▓    ▓▓  ▓▓▓▓▓▓\\▓▓\/  ▓▓'
echo '| ▓▓ \▓▓▓▓ ▓▓ | ▓▓ __| ▓▓  | ▓▓ ▓▓  | ▓▓\▓▓    \| ▓▓▓▓▓▓▓\ ▓▓  | ▓▓ >▓▓  ▓▓'
echo '| ▓▓__| ▓▓ ▓▓ | ▓▓|  \ ▓▓__/ ▓▓ ▓▓__/ ▓▓_\▓▓▓▓▓▓\ ▓▓__/ ▓▓ ▓▓__/ ▓▓/  ▓▓▓▓\'
echo ' \▓▓    ▓▓ ▓▓  \▓▓  ▓▓\▓▓    ▓▓ ▓▓    ▓▓       ▓▓ ▓▓    ▓▓\▓▓    ▓▓  ▓▓ \▓▓\'
echo '  \▓▓▓▓▓▓ \▓▓   \▓▓▓▓  \▓▓▓▓▓▓| ▓▓▓▓▓▓▓ \▓▓▓▓▓▓▓ \▓▓▓▓▓▓▓  \▓▓▓▓▓▓ \▓▓   \▓▓'
echo 'v1.0 3 May 2022               | ▓▓'
echo '                               \▓▓ https://github.com/gitopsbox/gitopsbox'

setvariables() {
  #Network interface
  waninterfacecard=
  laninterfacecard=
  mgmtinterfacecard=
  #Options
  deploygitops=yes
  enablenestedvirtualizationintel=no
  enablenestedvirtualizationamd=no
  proxmoxrepoaccess=yes
  managementwebaccess=no
  #Domain Names
  mgmtdomain=mgmt.example.com
  landomain=lan.example.com
  #pfSense management
  pfsensehostname=pfsense1
  pfsensemgmtipaddress=172.16.1.1
  mgmtsubnet=20
  pfsensemgmtport=8006
  #Proxmox Virtual Environment/PVE
  pvehostname=pve1
  pvemgmtipaddress=172.16.2.1
  #MGMT k8s networking
  mgmtk3siprangestart=172.16.3.1
  mgmtk3sserviceiprangestart=172.16.6.0
  mgmtk3sservicesubnetmaskbits=23
  mgmtk3spodiprangestart=172.16.8.0
  mgmtk3spodsubnetmaskbits=22
  mgmtdhcpstart=172.16.12.1
  mgmtdhcpend=172.16.15.254
  #LAN
  pfsenselanipaddress=10.1.1.1
  lansubnet=20
  #LAN k8s networking
  lank3siprangestart=10.1.3.1
  lank3sserviceiprangestart=10.1.6.0
  lank3sservicesubnetmaskbits=23
  lank3spodiprangestart=10.1.8.0
  lank3spodsubnetmaskbits=22
  landhcpstart=10.1.12.1
  landhcpend=10.1.15.254
  #WAN
  #For DHCP leave subnet blank and use "dhcp" for wanipaddress and "dhcp6" for wanip6address without quotations
  wanipaddress=dhcp
  wanip6address=dhcp6
  wansubnet=
  externaldnsserver1=9.9.9.9
  externaldnsserver2=149.112.112.112
  externaldnsserverhttps1=dns.quad9.net
  externaldnsserverhttps2=dns.quad9.net
  #Please support Proxmox project at proxmox.com
  disablepvesubscriptionprompt=no
  enablepvenosubscriptionrepo=no
  #pfSense Suricata Intrusion detection/prevention. IDS must be enabled for IPS to work on the same interface.
  #Enabling WAN IDS may make pfSense prone to DDOS
  #Enabling IDS/IPS will consume CPU
  enablewanids=yes
  enablelanids=no
  enablemgmtids=no
  enablewanips=yes
  enablelanips=no
  enablemgmtips=no
  #Rarely modified
  pvemailaddress=mail2@example.invalid
  deletebaseiso=no
  managementemailaccess=no
  managementaccessany=no
  lanaccessany=no
  mgmtvlan=
  lanvlan=
  lanip6address=
  mgmtip6address=
  pvetimezone=
  pveinstallerdisabledhcp=yes
  pveinstallerdisablegrub=yes
}

main() {
  createlogfile
  setvariables
  setmagicvariables
  forcesetvariables
  sudocheck
  onlinecheck
  promptunattend
  assignnetworkinterfaces
  printhashline
  downloaddependencies "${packages[@]}"
  settimezone
  downloadpveiso
  confirmpvechecksum
  downloadpfsenseiso
  confirmpfsensechecksum
  downloadubuntuminimaliso
  confirmubuntuminimalchecksum
  exitdownloadonlymode
  extractpveiso
  extractpfsenseiso
  createpfsenseconfigtemplate
  createpfsenseconfigscript
  createencodedpfsenseconfigentries
  modifypfsenseconfig
  copygitopsfiles
  modifypveinstaller
  createpvestartupscript
  createmgmtk3svmshellscript
  createconfigmgmtk3sshellscript
  createpveinterfaces
  modifyinterfacesvlan
  remasterpveiso
  promptusbcreation
 }

setmagicvariables() {
  #default network interface names within pfSense
  waninterfacename=vtnet0
  laninterfacename=vtnet1
  mgmtinterfacename=vtnet2
  #country variable to prefill proxinstall, only used for keyboard layout
  pvecountry="United States"
  #Download details
  pveisourl=http://download.proxmox.com/iso/
  pfsisourl=https://atxfiles.netgate.com/mirror/downloads/
  pvesumfile=SHA256SUMS
  pfssumfile=.sha256
  #meta-release-lts-development used instead of meta-release-lts until 22.04.1 is released
  ubuntureleaseurl=https://changelogs.ubuntu.com/meta-release-lts-development
  ubuntuminimalurlprefix=http://cloud-images.ubuntu.com/minimal/releases/
  ubuntuminimalurlsuffix=/release/
  ubuntuminimalsumfile=SHA256SUMS
  #Dependencies needed for this script to run
  packages=("xorriso" "curl")
  #number of lines to indicate range of sections in proxisntall to be used for sed replacements
  password_length=90
  hdsel_length=100
  ip_length=200
  invalidfqdn_length=10
  country_length=175
  ack_length=52
  #VM Configuration
  pfsensememory=4096
  pfsensecores=2
  pfsensehddsize=64
  #gitlabk8srequires 4CPU to deploy
  mgmtk3shostcpucores=4
  mgmtk3shostmemory=18432
  lank3shostmemory=8192
  lank3shostcpucores=4
  #G indicates gigabytes
  lank3sdisksize=30G
  mgmtk3sdisksize=30G
  #gitops
  vaulturl=vault."$mgmtdomain"
  kasaddress=kas.$mgmtdomain
  minioaddress=minio.$mgmtdomain
  fullgitlaburl=gitlab.$mgmtdomain
  pemname="gitlab.$mgmtdomain.ca.pem"
  gitlabsshport=32022
}

forcesetvariables() {
  if [ "$deploygitops" = "yes" ] && [ "$proxmoxrepoaccess" = "no" ]; then
    proxmoxrepoaccess=yes
    echo "Force enabling Proxmox Repository access variable as deploygitops is enabled" >&3
  fi
}

createlogfile() {
  exec 3>&1 4>&2
  trap 'exec 2>&4 1>&3' 0 1 2 3
  startdate=$(date +"%Y_%m_%d_%H%M%S")
  exec 1>"$startdate"_GitOpsBox_iso.log 2>&1
  set -xv
  #To direct output to console use >&3
  printhashline
  echo "Log file "$startdate"_GitOpsBox_iso.log created" >&3
}

sudocheck() {
  echo "################################################################################" >&3
  echo "GitOpsBox is a shell script that creates a bootable iso that deploys a" >&3
  echo "ready to build CICD environment. It provides Virtual Machines, Kubernetes," >&3
  echo "Firewall, Network Intrusion Prevention Service, CICD and Secure Password Store." >&3
  echo "It will download Proxmox, pfSense, K3S, Gitlab, Vault and VSCode Server." >&3
  echo "Script will prompt for neccesary options but more options are available" >&3
  echo "within the script itself as variables." >&3
  echo "By continuing you agree to the respective licensing of the above software." >&3
  
  #Check if root
  if [[ $EUID > 0 ]]; then
    echo "Administrative rights are required for installing packages, iso manipulation" >&3
    echo "and USB creation during the iso build process." >&3
  else
    echo "User is root. This script is intended to be initally run without sudo and"
    echo "will then ask for credentials. Please run from terminal with :"
    echo "bash gitopsbox.sh" >&3
    echo "1. Run with root anyway." >&3
    echo "Any other key will exit." >&3
    read -s -n1 doit1
    case $doit1 in
      1) ;;
      *) exit ;;
    esac
  fi

  #Prompt for credentials
  sudo -v

  if [ $? -eq 0 ]; then
    echo "Sudo success"
  else
      echo "Sudo failed, exiting script" >&3
      exit 1
  fi

  #Keep-alive for sudo incase non-sudo commands exceed timeout and sudo prompts for password mid-script
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}

onlinecheck() {
  #Check Network Status
  echo "Testing internet access to ubuntu.com..." >&3

  wget --timeout 10 -q --spider https://ubuntu.com

  if [ $? -eq 0 ]; then
      echo "Network status is online." >&3
      networkstatus=1
  else
      echo "Network status is offline, building iso..." >&3
      networkstatus=0
  fi

  if [ $networkstatus -eq 1 ]; then
    echo "1. Build iso now." >&3
    echo "2. Only download prerequisite files for a future offline build." >&3
    echo "Any other key will exit." >&3
    read -s -n1 doit2
    case $doit2 in
      1) downloadonly=no;;
      2) downloadonly=yes;;
      *) exit ;;
    esac
  else
    downloadonly=no
  fi
}

promptunattend() {
  if [ "$downloadonly" = "no" ]; then
    echo "################################################################################" >&3
    echo "The GitOpsBox installer can be configured to run unattended." >&3
    echo "This requires the Proxmox installer to auto-format the hard drive without prompt" >&3
    echo "It will autoformat the dev/sda hard drives or similar first SSD even if it is" >&3
    echo "already formatted." >&3
    echo "When booting from the USB drive only plugin hard drives you are willing to wipe." >&3
    echo "Secondary data drives can be formatted later within the Proxmox web interface." >&3
    echo "1. Enable hard drive auto-format for the bootable USB unattended installer." >&3
    echo "2. Prompt during install to manually format hard drive." >&3
    echo "Any other key will exit." >&3
      read -s -n1 doit18
    case $doit18 in
      1) pveautoformatharddrive=yes;;
      2) pveautoformatharddrive=no;;
      *) exit ;;
    esac
  fi

  if [ "$downloadonly" = "no" ]; then
    echo "################################################################################" >&3
    echo "Unattended install requires the Proxmox password to be set to a temporary value." >&3
    echo "This should be changed within Proxmox web interface after installation." >&3
    echo "Proxmox web interface username is root. The default debian password is 'r00tme'" >&3
    pvepassword=r00tme
    # Below is commented out due to gitlab jobs requiring proxmox password entered into vault.
    #echo "1. Use temporary password 'r00tme' for root for an unattended installer." >&3
    #echo "2. Prompt to set password during install." >&3
    #echo "Any other key will exit." >&3
      #read -s -n1 doit19
    #case $doit19 in
      #1) pvepassword=r00tme;;
      #2) pvepassword=;;
      #*) exit ;;
    #esac
  fi

  if [ "$downloadonly" = "no" ]; then
    echo "################################################################################" >&3
    echo "Fully unattended install requires the WAN network interface to receive a DHCP" >&3 
    echo "assigned IP with internet available without manual configuration." >&3
    echo "If manual configuration is required, the deployment can be paused to wait for" >&3
    echo "internet to be available as it is required for Kubernetes and GitOps to deploy" >&3
    echo "1. Disable pause for manual WAN config." >&3
    echo "2. Enable pause for manual WAN config." >&3
    echo "Any other key will exit." >&3
    read -s -n1 doit17
    case $doit17 in
      1) enablepausedeployformanualwanconfig=no;;
      2) enablepausedeployformanualwanconfig=yes;;
      *) exit ;;
    esac
  fi
}

assignnetworkinterfaces() {
  if [ -z "$waninterfacecard" ] || [ -z "$laninterfacecard" ] || [ -z "$mgmtinterfacecard" ] && [ "$downloadonly" = "no" ]; then
    echo "################################################################################" >&3
    echo "GitOpsBox requires 3 network interfaces:" >&3
    echo "WAN for internet exposure." >&3
    echo "LAN for local devices." >&3
    echo "Management for access to Proxmox/pfSense." >&3
    echo "################################################################################" >&3
    echo "If you are not running this script on the intended Proxmox host then you will" >&3
    echo "need to exit and find the interface logical names on the target machine." >&3
    echo "1. Identify and assign network interfaces now." >&3
    echo "Any other key will exit." >&3
    read -s -n1 doit3
    case $doit3 in
      1) ;;
      *) exit ;;
    esac

    echo "Retrieving network interface information..." >&3
    
    waninterfacecard=refresh
    until [ "$waninterfacecard" != "refresh" ]; do
      sudo lshw -class network >&3
      echo "################################################################################" >&3
      echo "Type "refresh" to retrieve device information again." >&3
      echo "Removing/Disabling the device or using the ip and link status can help identify" >&3
      echo "which logical name corresponds to the physical device." >&3
      echo "Please enter the logical name of the network device to be used for WAN:" >&3
      read waninterfacecard
    done
    
    laninterfacecard=refresh
    until [ "$laninterfacecard" != "refresh" ]; do
      sudo lshw -class network >&3
      echo "################################################################################" >&3
      echo "Type "refresh" to retrieve device information again." >&3
      echo "Removing/Disabling the device or using the ip and link status can help identify" >&3
      echo "which logical name corresponds to the physical device." >&3
      echo "Please enter the logical name of the network device to be used for LAN:" >&3
      read laninterfacecard
    done
    
    mgmtinterfacecard=refresh
    until [ "$mgmtinterfacecard" != "refresh" ]; do
      sudo lshw -class network >&3
      echo "################################################################################" >&3
      echo "Type "refresh" to retrieve device information again." >&3
      echo "Removing/Disabling the device or using the ip and link status can help identify" >&3
      echo "which logical name corresponds to the physical device." >&3
      echo "The following network interface is used to connect to Proxmox/pfSense consoles" >&3
      echo "after installation. Please enter the logical name of the network device to be" >&3
      echo "used for Management." >&3
      read mgmtinterfacecard
    done
  fi
}

printhashline() {
  echo "################################################################################" >&3
}

downloaddependencies() {
  arr=("$@")
  for i in "${arr[@]}"; do
    if command -v $i &> /dev/null; then
      echo "$i is installed." >&3
      if [ ! -d "./$i" ] && [ "$downloadonly" = "yes" ]; then
        echo "$i folder does not exist, downloading for offline use" >&3
        sudo apt-get -o DPkg::Lock::Timeout=600 update
        mkdir $i
        cd $i
        apt-get -o DPkg::Lock::Timeout=600 download $(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances --no-pre-depends ${i} | grep "^\w")
        cd ..
      fi
    else
      if [ -d "./$i" ]; then
        echo "$i is not installed but packages are found locally, installing packages..." >&3
        while ! command -v $i &> /dev/null; do
          echo "Installing $i..." >&3
          sudo dpkg -i -R ./$i
          sleep 5
        done
      else
        if [ $networkstatus -eq 0 ]; then
          echo "Network appears offline and $i packages are not found locally, please run script again online to download packages." >&3
          exit 1
        else
          echo "Downloading $i and dependencies..." >&3
          sudo apt-get -o DPkg::Lock::Timeout=600 update
          mkdir "./working/"
          mkdir "./$i/"
          sudo apt-get -o DPkg::Lock::Timeout=600 --download-only -o Dir::Cache="./working/" -o Dir::Cache::archives="./working/" install $i -y
          sudo find "./working/" -name '*.deb' | xargs cp -t "./$i/"
          sudo rm -r "./working/"
          while ! command -v $i &> /dev/null; do
            echo "Installing $i..." >&3
            sudo dpkg -i -R ./$i
            sleep 5
          done
        fi
      fi
    fi
  done
}

settimezone() {
  if [ -z  "$pvetimezone" ] && [ "$downloadonly" = "no" ]; then
    foundtimezone=$(cat /etc/timezone)
    echo "################################################################################" >&3
    echo "pvetimezone variable is empty." >&3
    echo "1. Use system timezone of $foundtimezone" >&3
    echo "2. Enter timezone manually." >&3
    echo "3. Use ubuntu.com to geo-locate my internet IP address." >&3
    echo "Any other key will exit." >&3
    read -s -n1 doit4
    case $doit4 in
      1)
        pvetimezone="$foundtimezone"
        ;;
      2)
        gnome-terminal -- timedatectl list-timezones
        echo "A list of valid timezones has been opened in a new window." >&3
        echo "Enter timezone manually :" >&3
        read pvetimezone
        ;;
      3)
        echo "Attempting to reach ubuntu.com..." >&3
        pvetimezone=$(curl --retry 5 --connect-timeout 3 --retry-delay 2 -s http://geoip.ubuntu.com/lookup | grep -oP '(?<=<TimeZone>)(.*)(?=</TimeZone>)')
        ;;
      *) exit ;;
    esac
  fi

  if [ -z "$pvetimezone" ] && [ "$downloadonly" = "no" ]; then
    echo "Timezone is still undefined. Exiting script." >&3
    exit
  else
    if [ "$downloadonly" = "no" ]; then 
    echo "Timezone is set to $pvetimezone" >&3
    fi
  fi	
}

downloadpveiso() {
  echo "################################################################################" >&3
  echo "Getting latest iso from $pveisourl..." >&3
  pvesumurl=$pveisourl$pvesumfile
  if curl --retry 5 --connect-timeout 3 --retry-delay 2 --output /dev/null --silent --head --fail "$pveisourl"; then
    curl --retry 5 --connect-timeout 3 --retry-delay 2 "$pveisourl" | grep '<a href="proxmox-ve_*' >tempurllist.txt
    latestpveiso=$(cat tempurllist.txt | sort -r | grep -m1 -oP '(?<=<a href=").*' | grep -oP '.*(?=.iso")' | sed 's/$/.iso/')
    if [ -f "$latestpveiso" ]; then
      echo "$latestpveiso already exists. Skipping download." >&3
      if [ -f "$pvesumfile" ]; then
        echo "Proxmox $pvesumfile exists. Update to latest available?" >&3
        echo "1. Update checksum file" >&3
        echo "2. Do not update and use local checksum file" >&3
        read -s -n1 doit5
        case $doit5 in
          1) curl --retry 5 --connect-timeout 3 --retry-delay 2 -O "$pvesumurl";;
          2) ;;
        esac
      else
        echo "Downloading Proxmox Checksum file." >&3
        curl --retry 5 --connect-timeout 3 --retry-delay 2 -O "$pvesumurl"
      fi
    else
      currentpveiso=$(ls proxmox-ve_[0-9].*.iso)
      if [ -z "$currentpveiso" ]; then
        echo "Downloading $latestpveiso. Progress in log file" >&3
        curl --retry 5 --connect-timeout 3 --retry-delay 2 -O "$pveisourl""$latestpveiso"
      else
        echo "$currentpveiso already exists, the newer $latestpveiso is available" >&3
        echo "1. Download $latestpveiso" >&3
        echo "2. Do not download and use $currentpveiso" >&3
        read -s -n1 doit6
        case $doit6 in
          1)
            echo "Downloading $latestpveiso. Progress in log file" >&3 
            curl --retry 5 --connect-timeout 3 --retry-delay 2 -O "$pveisourl""$latestpveiso"
            ;;
          2) 
            latestpveiso=$(ls proxmox-ve_[0-9].*.iso)
            ;;
        esac
      fi
      if [ -f "$pvesumfile" ]; then
        echo "Proxmox $pvesumfile already exists. Update to latest available?" >&3
        echo "1. Update checksum file" >&3
        echo "2. Do not update and use local checksum file" >&3
        read -s -n1 doit7
        case $doit7 in
          1) curl --retry 5 --connect-timeout 3 --retry-delay 2 -O "$pvesumurl";;
          2) ;;
        esac
      else
        echo "Downloading Proxmox Checksum file." >&3
        curl --retry 5 --connect-timeout 3 --retry-delay 2 -O "$pvesumurl"
      fi
    fi
  else
    if ls proxmox-ve_* 1> /dev/null 2>&1 ; then
      echo "Cannot reach $pveisourl. Using Proxmox iso found in working directory." >&3
      latestpveiso=$(ls proxmox-ve_[0-9].*.iso)
    else
      echo "Cannot reach $pveisourl and no iso in working directory found. Exiting script." >&3
      exit 1
    fi
  fi
}

confirmpvechecksum() {
  if [ -f "$pvesumfile" ]; then
    pvehash1=$(grep -F "${latestpveiso}" "$pvesumfile")
    pvehash2=${pvehash1:0:65}
    echo "Verifying checksum of $latestpveiso..." >&3
    echo "$pvehash2 $latestpveiso" | sha256sum --check >&3
    if [ $? -eq 1 ]; then
      echo "Proxmox iso checksum failed." >&3
      echo "1. Continue" >&3
      echo "Any other key will exit." >&3
    read -s -n1 doit8
    case $doit8 in
      1) ;;
      *) exit ;;
    esac
    fi
  else
    echo "No Proxmox checksum file available." >&3
    echo "1. Continue" >&3
    echo "Any other key will exit." >&3
    read -s -n1 doit9
    case $doit9 in
      1) ;;
      *) exit ;;
    esac
  fi
}

downloadpfsenseiso() {
  printhashline
  echo "Getting latest iso from $pfsisourl..." >&3
  if curl --retry 5 --connect-timeout 3 --retry-delay 2 --output /dev/null --silent --head --fail "$pfsisourl"; then
    curl --retry 5 --connect-timeout 3 --retry-delay 2 "$pfsisourl" | grep -E '<a href="pfSense-CE-[0-9].*.iso.gz">' >tempurllist2.txt
    latestpfsisogz=$(cat tempurllist2.txt | sort -r | grep -m1 -oP '(?<=<a href=").*' | grep -oP '.*(?=.iso.gz")' | sed 's/$/.iso.gz/')
    pfssumurl="$pfsisourl""$latestpfsisogz""$pfssumfile"
    pfssumfilename="$latestpfsisogz""$pfssumfile"
    if [ -f "$latestpfsisogz" ]; then
      echo "$latestpfsisogz already exists. Skipping download." >&3
      if [ -f "$pfssumfilename" ]; then
        echo "pfSense checksum file already exists. Update to latest available?" >&3
        echo "1. Update checksum file" >&3
        echo "2. Do not update and use local checksum file" >&3
        read -s -n1 doit10
        case $doit10 in
          1) curl --retry 5 --connect-timeout 3 --retry-delay 2 -O "$pfssumurl";;
          2) ;;
        esac
      else
        echo "Downloading pfSense Checksum file." >&3
        curl --retry 5 --connect-timeout 3 --retry-delay 2 -O "$pfssumurl"
      fi
    else
      currentpfsisogz=$(ls pfSense-CE*.gz)
      if [ -z "$currentpfsisogz" ]; then
        echo "Downloading $latestpfsisogz. Progress in log file" >&3
        curl --retry 5 --connect-timeout 3 --retry-delay 2 -O "$pfsisourl""$latestpfsisogz"
      else
        echo "$currentpfsisogz already exists, the newer $latestpfsisogz is available." >&3
        echo "1. Download $latestpfsisogz" >&3
        echo "2. Do not download and use $currentpfsisogz" >&3
        read -s -n1 doit11
        case $doit11 in
          1) 
            echo "Downloading $latestpfsisogz. Progress in log file" >&3
            curl --retry 5 --connect-timeout 3 --retry-delay 2 -O "$pfsisourl""$latestpfsisogz"
            ;;
          2)
            latestpfsisogz=$(ls pfSense-CE*.gz)
            ;;
        esac
      fi
      pfssumurl="$pfsisourl""$latestpfsisogz""$pfssumfile"
      pfssumfilename="$latestpfsisogz""$pfssumfile"
      if [ -f "$pfssumfilename" ]; then
        echo "pfSense checksum file already exists. Update to latest available?" >&3
        echo "1. Update checksum file" >&3
        echo "2. Do not update and use local checksum file" >&3
        read -s -n1 doit12
        case $doit12 in
          1) curl --retry 5 --connect-timeout 3 --retry-delay 2 -O "$pfssumurl";;
          2) ;;
        esac
      else
        echo "Downloading pfSense Checksum file." >&3
        curl --retry 5 --connect-timeout 3 --retry-delay 2 -O "$pfssumurl"
      fi
    fi
  else
    if ls pfSense-CE*.gz 1> /dev/null 2>&1; then
      echo "Cannot reach $pfsisourl. Using pfSense iso found in working directory." >&3
      latestpfsisogz=$(ls pfSense-CE*.gz)
      pfssumfilename="$latestpfsisogz""$pfssumfile"
    else
      echo "Cannot reach $pfsisourl and no iso in working directory found. Exiting script." >&3
      exit 1
    fi
  fi
}

confirmpfsensechecksum() {
  if [ -f "$pfssumfilename" ]; then
    pfshash1=$(cat "$pfssumfilename")
    pfshash2=${pfshash1: -65}
    echo "Verifying checksum of $latestpfsisogz..." >&3  
    echo "$pfshash2 $latestpfsisogz" | sha256sum --check >&3
    if [ $? -eq 1 ]; then
      echo "pfSense iso checksum failed." >&3
      echo "1. Continue" >&3
      echo "Any other key will exit." >&3
    read -s -n1 doit13
    case $doit13 in
      1) ;;
      *) exit ;;
    esac
    fi
  else
    echo "No pfSense checksum file available." >&3
    echo "1. Continue" >&3
    echo "Any other key will exit." >&3
    read -s -n1 doit14
    case $doit14 in
      1) ;;
      *) exit ;;
    esac
  fi
}

downloadubuntuminimaliso() {
  if [ "$deploygitops" = "yes" ]; then
    echo "################################################################################" >&3
    echo "Getting latest iso from $ubuntureleaseurl..." >&3
    ubuntultsreleasename=$(curl --retry 5 --connect-timeout 3 --retry-delay 2 -s $ubuntureleaseurl | grep -E Dist: | tail -n1 | awk '{print $2}')
    ubuntuminimalurl="$ubuntuminimalurlprefix""$ubuntultsreleasename""$ubuntuminimalurlsuffix"
    ubuntuminimalsumurl="$ubuntuminimalurl""$ubuntuminimalsumfile"
    if curl --retry 5 --connect-timeout 3 --retry-delay 2 --output /dev/null --silent --head --fail "$ubuntuminimalurl"; then
      curl --retry 5 --connect-timeout 3 --retry-delay 2 "$ubuntuminimalurl" | grep -E '<a href="ubuntu-[0-9].*-minimal-cloudimg-amd64.img">' >tempurllist5.txt
      latestubuntuminimal=$(cat tempurllist5.txt | sort -r | grep -m1 -oP '(?<=<a href=").*' | grep -oP '.*(?=">ubuntu-)' )
      if [ -f "$latestubuntuminimal" ]; then
        echo "$latestubuntuminimal already exists. Skipping download." >&3
        if [ -f "ubuntu""$ubuntuminimalsumfile" ]; then
          echo "Checksumfile "ubuntu""$ubuntuminimalsumfile" already exists. Update to latest available?" >&3
          echo "1. Update checksum file" >&3
          echo "2. Do not update and use local checksum file" >&3
          read -s -n1 doit21
          case $doit21 in
            1) curl --retry 5 --connect-timeout 3 --retry-delay 2 -o "ubuntu""$ubuntuminimalsumfile" "$ubuntuminimalsumurl";;
            2) ;;
          esac
        else
          echo "Downloading Ubuntu Minimal Checksum file." >&3
          curl --retry 5 --connect-timeout 3 --retry-delay 2 -o "ubuntu""$ubuntuminimalsumfile" "$ubuntuminimalsumurl"
        fi
      else
        currentubuntuminimaliso=$(ls ubuntu-[0-9]*-minimal-cloudimg-amd64.img)
        if [ -z "$currentubuntuminimaliso" ]; then
          echo "Downloading $latestubuntuminimal. Progress in log file" >&3
          curl --retry 5 --connect-timeout 3 --retry-delay 2 -O "$ubuntuminimalurl""$latestubuntuminimal"
        else
          echo "$currentubuntuminimaliso already exists, the newer $latestubuntuminimal is available" >&3
          echo "1. Download $latestubuntuminimal" >&3
          echo "2. Do not download and use $currentubuntuminimaliso" >&3
          read -s -n1 doit23
          case $doit23 in
            1)
              echo "Downloading $latestubuntuminimal. Progress in log file" >&3 
              curl --retry 5 --connect-timeout 3 --retry-delay 2 -O "$ubuntuminimalurl""$latestubuntuminimal"
              ;;
            2) 
              latestubuntuminimal=$(ls ubuntu-[0-9]*-minimal-cloudimg-amd64.img)
              ;;
          esac
        fi
        if [ -f "ubuntu""$ubuntuminimalsumfile" ]; then
          echo "Checksumfile "ubuntu""$ubuntuminimalsumfile" already exists. Update to latest available?" >&3
          echo "1. Update checksum file" >&3
          echo "2. Do not update and use local checksum file" >&3
          read -s -n1 doit24
          case $doit24 in
            1) curl --retry 5 --connect-timeout 3 --retry-delay 2 -o "ubuntu""$ubuntuminimalsumfile" "$ubuntuminimalsumurl";;
            2) ;;
          esac
        else
          echo "Downloading ubuntu Checksum file." >&3
          curl --retry 5 --connect-timeout 3 --retry-delay 2 -o "ubuntu""$ubuntuminimalsumfile" "$ubuntuminimalsumurl"
        fi
      fi
    else
      if ls ubuntu-*-minimal-cloudimg-amd64.img 1> /dev/null 2>&1 ; then
        echo "Cannot reach $ubuntureleaseurl. Using ubuntu minimal img found in working directory." >&3
        latestubuntuminimal=$(ls ubuntu-[0-9]*-minimal-cloudimg-amd64.img)
      else
        echo "Cannot reach $ubuntureleaseurl and no img in working directory found. Exiting script." >&3
        exit 1
      fi
    fi
  fi
}

confirmubuntuminimalchecksum() {
  if [ "$deploygitops" = "yes" ]; then
    if [ -f "ubuntu""$ubuntuminimalsumfile" ]; then
      ubuhash1=$(grep -F "${latestubuntuminimal}" "ubuntu""$ubuntuminimalsumfile")
      ubuhash2=${ubuhash1:0:65}
      echo "Verifying checksum of $latestubuntuminimal..." >&3
      echo "$ubuhash2 $latestubuntuminimal" | sha256sum --check >&3
      if [ $? -eq 1 ]; then
        echo "Ubuntu minimal img checksum failed." >&3
        echo "1. Continue" >&3
        echo "Any other key will exit." >&3
      read -s -n1 doit25
      case $doit25 in
        1) ;;
        *) exit ;;
      esac
      fi
    else
      echo "No ubuntu minimal checksum file available." >&3
      echo "1. Continue" >&3
      echo "Any other key will exit." >&3
      read -s -n1 doit26
      case $doit26 in
        1) ;;
        *) exit ;;
      esac
    fi
  fi
  printhashline
}

exitdownloadonlymode() {
  if [ "$downloadonly" = "yes" ]; then
    echo "Downloads finished, exiting script due to download only mode." >&3
    sudo rm tempurllist*.txt
    exit 0
  fi
}

extractpveiso() {
  echo "Extracting Proxmox iso..." >&3
  xorriso -osirrox on -boot_image any keep -indev "$latestpveiso" -report_about NOTE -extract / tempiso
  #Extract squashfs
  sudo unsquashfs -q -f -d temppveinstall tempiso/pve-installer.squashfs >&3
  #extract pve base to add iso's and cron job
  sudo unsquashfs -q -f -d temppvebase tempiso/pve-base.squashfs >&3
  #Copy proxinstall
  cp temppveinstall/usr/bin/proxinstall .
}

extractpfsenseiso() {
  echo "Extracting pfSense iso..." >&3

  if [ "$deletebaseiso" = "yes" ]; then
    gzip -d "$latestpfsisogz"
  else
    if [ "$deletebaseiso" = "no" ]; then
      gzip -k -d "$latestpfsisogz"
    fi
  fi

  latestpfsiso=$(ls pfSense-CE-[0-9].*.iso)
}

createpfsenseconfigtemplate() {
#xml template uses tabbed indentation and bash heredoc is sensitive to indentation so this function uses tabbed indentation while remainder of script uses 2 spaces
cat > config.xml <<ENDOFFILE
<?xml version="1.0"?>
<pfsense>
	<version>22.2</version>
	<lastchange></lastchange>
	<system>
		<optimization>normal</optimization>
		<hostname>pfsensehostname</hostname>
		<domain>mgmtdomain</domain>
		<dns1host>externaldnsserverhttps1</dns1host>
		<dns2host>externaldnsserverhttps2</dns2host>
		<dnsserver>dnsserver1</dnsserver>
		<dnsserver>dnsserver2</dnsserver>
		
		<group>
			<name>all</name>
			<description><![CDATA[All Users]]></description>
			<scope>system</scope>
			<gid>1998</gid>
			<member>0</member>
		</group>
		<group>
			<name>admins</name>
			<description><![CDATA[System Administrators]]></description>
			<scope>system</scope>
			<gid>1999</gid>
			<member>0</member>
			<priv>page-all</priv>
		</group> 
		<user>
			<name>admin</name>
			<descr><![CDATA[System Administrator]]></descr>
			<scope>system</scope>
			<groupname>admins</groupname>
			<bcrypt-hash>$2y$10$g8xRATS4vVqdjQfuLoaAoO3yUYvrRdy63/zmOgiAXxgHiSCMtncDu</bcrypt-hash>
			<uid>0</uid>
			<priv>user-shell-access</priv>
		</user>
		<nextuid>2000</nextuid>
		<nextgid>2000</nextgid>
		<timeservers>0.pool.ntp.org</timeservers>
		<webgui>
			<protocol>https</protocol>
			<loginautocomplete></loginautocomplete>
			<dashboardcolumns>2</dashboardcolumns>
			<port>mgmtport</port>
			<max_procs>2</max_procs>
			<disablehttpredirect></disablehttpredirect>
			<noantilockout></noantilockout>
		</webgui>
		<disablenatreflection>yes</disablenatreflection>
		<disablesegmentationoffloading></disablesegmentationoffloading>
		<disablelargereceiveoffloading></disablelargereceiveoffloading>
		<ipv6allow></ipv6allow>
		<maximumtableentries>400000</maximumtableentries>
		<powerd_ac_mode>hadp</powerd_ac_mode>
		<powerd_battery_mode>hadp</powerd_battery_mode>
		<powerd_normal_mode>hadp</powerd_normal_mode>
		<bogons>
			<interval>monthly</interval>
		</bogons>
		<already_run_config_upgrade></already_run_config_upgrade>
		<timezone>undefinedtimezone</timezone>
		<ssh></ssh>
		<serialspeed>115200</serialspeed>
		<primaryconsole>serial</primaryconsole>
		<sshguard_threshold></sshguard_threshold>
		<sshguard_blocktime></sshguard_blocktime>
		<sshguard_detection_time></sshguard_detection_time>
		<sshguard_whitelist></sshguard_whitelist>
		<disablechecksumoffloading></disablechecksumoffloading>
		<do_not_send_uniqueid></do_not_send_uniqueid>
		<mds_disable>0</mds_disable>
		<use_mfs_tmp_size></use_mfs_tmp_size>
		<use_mfs_var_size></use_mfs_var_size>
	</system>
	<interfaces>
		<wan>
			<enable></enable>
			<if>waninterfacename</if>
			<ipaddr>wanipaddr</ipaddr>
			<ipaddrv6>wan6ip</ipaddrv6>
			<subnet>wansubnet</subnet>
			<gateway></gateway>
			<blockpriv>on</blockpriv>
			<blockbogons>on</blockbogons>
			<media></media>
			<mediaopt></mediaopt>
			<dhcp6-duid></dhcp6-duid>
			<dhcp6-ia-pd-len>0</dhcp6-ia-pd-len>
		</wan>
		<lan>
			<enable></enable>
			<if>laninterfacename</if>
			<ipaddr>lanipaddr</ipaddr>
			<subnet>lansubnet</subnet>
			<ipaddrv6>lan6ip</ipaddrv6>
			<subnetv6></subnetv6>
			<media></media>
			<mediaopt></mediaopt>
			<track6-interface>wan</track6-interface>
			<track6-prefix-id>0</track6-prefix-id>
			<gateway></gateway>
			<gatewayv6></gatewayv6>
		</lan>
		<opt1>
			<if>opt1interfacename</if>
			<descr><![CDATA[OPT1]]></descr>
			<ipaddr>opt1ipaddr</ipaddr>
			<subnet>opt1subnet</subnet>
			<gateway></gateway>
			<ipaddrv6>opt16ip</ipaddrv6>
			<subnetv6></subnetv6>
			<gatewayv6></gatewayv6>
			<enable></enable>
		</opt1>
	</interfaces>
	<staticroutes></staticroutes>
	<dhcpd>
		<lan>
			<enable></enable>
			<range>
				<from>landhcpstart</from>
				<to>landhcpend</to>
			</range>
		</lan>
		<opt1>
			<range>
				<from>opt1dhcpstart</from>
				<to>opt1dhcpend</to>
			</range>
			<enable></enable>
		</opt1>
	</dhcpd>
	<dhcpdv6>
		<lan>
			<range>
				<from>::1000</from>
				<to>::2000</to>
			</range>
			<ramode>assist</ramode>
			<rapriority>medium</rapriority>
		</lan>
	</dhcpdv6>
	<snmpd>
		<syslocation></syslocation>
		<syscontact></syscontact>
		<rocommunity>public</rocommunity>
	</snmpd>
	<diag>
		<ipv6nat></ipv6nat>
	</diag>
	<syslog>
		<filterdescriptions>1</filterdescriptions>
	</syslog>
	<nat>
		<outbound>
			<mode>automatic</mode>
		</outbound>
	</nat>
	<filter>
		<rule>
			<id></id>
			<tracker>0100000101</tracker>
			<type>pass</type>
			<interface>lan</interface>
			<ipprotocol>inet</ipprotocol>
			<tag></tag>
			<tagged></tagged>
			<max></max>
			<max-src-nodes></max-src-nodes>
			<max-src-conn></max-src-conn>
			<max-src-states></max-src-states>
			<statetimeout></statetimeout>
			<statetype><![CDATA[keep state]]></statetype>
			<os></os>
			<protocol>tcp/udp</protocol>
			<source>
				<network>lan</network>
			</source>
			<destination>
				<address>mgmtk3sip</address>
				<port>443</port>
			</destination>
			<descr>Created by GitOpsBox</descr>
		</rule>
		<rule>
			<id></id>
			<tracker>0100000102</tracker>
			<type>pass</type>
			<interface>lan</interface>
			<ipprotocol>inet</ipprotocol>
			<tag></tag>
			<tagged></tagged>
			<max></max>
			<max-src-nodes></max-src-nodes>
			<max-src-conn></max-src-conn>
			<max-src-states></max-src-states>
			<statetimeout></statetimeout>
			<statetype><![CDATA[keep state]]></statetype>
			<os></os>
			<protocol>tcp/udp</protocol>
			<source>
				<network>lan</network>
			</source>
			<destination>
				<address>mgmtk3sip</address>
				<port>gitlabsshport</port>
			</destination>
			<descr>Created by GitOpsBox</descr>
		</rule>
		<rule>
			<id></id>
			<tracker>0100000103</tracker>
			<type>block</type>
			<interface>lan</interface>
			<ipprotocol>inet46</ipprotocol>
			<tag></tag>
			<tagged></tagged>
			<max></max>
			<max-src-nodes></max-src-nodes>
			<max-src-conn></max-src-conn>
			<max-src-states></max-src-states>
			<statetimeout></statetimeout>
			<statetype><![CDATA[keep state]]></statetype>
			<os></os>
			<source>
				<network>lan</network>
			</source>
			<destination>
				<network>opt1</network>
			</destination>
			<descr>Created by GitOpsBox</descr>
		</rule>
		<rule>
			<id></id>
			<tracker>0100000104</tracker>
			<type>pass</type>
			<interface>lan</interface>
			<ipprotocol>inet46</ipprotocol>
			<tag></tag>
			<tagged></tagged>
			<max></max>
			<max-src-nodes></max-src-nodes>
			<max-src-conn></max-src-conn>
			<max-src-states></max-src-states>
			<statetimeout></statetimeout>
			<statetype><![CDATA[keep state]]></statetype>
			<protocol>udp</protocol>
			<os></os>
			<source>
				<network>lan</network>
			</source>
			<destination>
				<network>lanip</network>
				<port>123</port>
			</destination>
			<descr>Created by GitOpsBox</descr>
		</rule>
		<rule>
			<id></id>
			<tracker>0100000105</tracker>
			<type>pass</type>
			<interface>lan</interface>
			<ipprotocol>inet46</ipprotocol>
			<tag></tag>
			<tagged></tagged>
			<max></max>
			<max-src-nodes></max-src-nodes>
			<max-src-conn></max-src-conn>
			<max-src-states></max-src-states>
			<statetimeout></statetimeout>
			<statetype><![CDATA[keep state]]></statetype>
			<os></os>
			<protocol>tcp/udp</protocol>
			<source>
				<network>lan</network>
			</source>
			<destination>
				<network>lanip</network>
				<port>53</port>
			</destination>
			<descr>Created by GitOpsBox</descr>
		</rule>
		<rule>
			<id></id>
			<tracker>0100000106</tracker>
			<type>pass</type>
			<interface>lan</interface>
			<ipprotocol>inet46</ipprotocol>
			<tag></tag>
			<tagged></tagged>
			<max></max>
			<max-src-nodes></max-src-nodes>
			<max-src-conn></max-src-conn>
			<max-src-states></max-src-states>
			<statetimeout></statetimeout>
			<statetype><![CDATA[keep state]]></statetype>
			<os></os>
			<protocol>tcp/udp</protocol>
			<source>
				<network>lan</network>
			</source>
			<destination>
				<network>lanip</network>
				<port>853</port>
			</destination>
			<descr>Created by GitOpsBox</descr>
		</rule>
		<rule>
			<id></id>
			<tracker>0100000107</tracker>
			<type>pass</type>
			<interface>lan</interface>
			<ipprotocol>inet46</ipprotocol>
			<tag></tag>
			<tagged></tagged>
			<max></max>
			<max-src-nodes></max-src-nodes>
			<max-src-conn></max-src-conn>
			<max-src-states></max-src-states>
			<statetimeout></statetimeout>
			<statetype><![CDATA[keep state]]></statetype>
			<os></os>
			<protocol>tcp/udp</protocol>
			<source>
				<network>lan</network>
			</source>
			<destination>
				<any></any>
				<port>443</port>
			</destination>
			<descr>Created by GitOpsBox</descr>
		</rule>
		<rule>
			<id></id>
			<tracker>0100000108</tracker>
			<type>pass</type>
			<interface>lan</interface>
			<ipprotocol>inet46</ipprotocol>
			<tag></tag>
			<tagged></tagged>
			<max></max>
			<max-src-nodes></max-src-nodes>
			<max-src-conn></max-src-conn>
			<max-src-states></max-src-states>
			<statetimeout></statetimeout>
			<statetype><![CDATA[keep state]]></statetype>
			<os></os>
			<protocol>tcp/udp</protocol>
			<source>
				<network>lan</network>
			</source>
			<destination>
				<any></any>
				<port>80</port>
			</destination>
			<descr>Created by GitOpsBox</descr>
		</rule>
		<rule>
			<type>pass</type>
			<ipprotocol>inet</ipprotocol>
			<descr><![CDATA[Default allow LAN to any rule]]></descr>
			<interface>lan</interface>
			<tracker>0100000109</tracker>
			<source>
				<network>lan</network>
			</source>
			<destination>
				<any></any>
			</destination>
			<disabled></disabled>
		</rule>
		<rule>
			<type>pass</type>
			<ipprotocol>inet6</ipprotocol>
			<descr><![CDATA[Default allow LAN IPv6 to any rule]]></descr>
			<interface>lan</interface>
			<tracker>0100000110</tracker>
			<source>
				<network>lan</network>
			</source>
			<destination>
				<any></any>
			</destination>
			<disabled></disabled>
		</rule>
		<rule>
			<id></id>
			<tracker>0100000111</tracker>
			<type>pass</type>
			<interface>opt1</interface>
			<ipprotocol>inet46</ipprotocol>
			<tag></tag>
			<tagged></tagged>
			<max></max>
			<max-src-nodes></max-src-nodes>
			<max-src-conn></max-src-conn>
			<max-src-states></max-src-states>
			<statetimeout></statetimeout>
			<statetype><![CDATA[keep state]]></statetype>
			<os></os>
			<protocol>tcp/udp</protocol>
			<source>
				<network>opt1</network>
			</source>
			<destination>
				<network>opt1ip</network>
				<port>mgmtport</port>
			</destination>
			<descr>Created by GitOpsBox</descr>
		</rule>
		<rule>
			<id></id>
			<tracker>0100000112</tracker>
			<type>pass</type>
			<interface>opt1</interface>
			<ipprotocol>inet46</ipprotocol>
			<tag></tag>
			<tagged></tagged>
			<max></max>
			<max-src-nodes></max-src-nodes>
			<max-src-conn></max-src-conn>
			<max-src-states></max-src-states>
			<statetimeout></statetimeout>
			<statetype><![CDATA[keep state]]></statetype>
			<os></os>
			<protocol>tcp/udp</protocol>
			<source>
				<network>opt1</network>
			</source>
			<destination>
				<any></any>
				<port>587</port>
			</destination>
			<descr>Created by GitOpsBox</descr>
			<disabled></disabled>
		</rule>
		<rule>
			<id></id>
			<tracker>0100000113</tracker>
			<type>pass</type>
			<interface>opt1</interface>
			<ipprotocol>inet46</ipprotocol>
			<tag></tag>
			<tagged></tagged>
			<max></max>
			<max-src-nodes></max-src-nodes>
			<max-src-conn></max-src-conn>
			<max-src-states></max-src-states>
			<statetimeout></statetimeout>
			<statetype><![CDATA[keep state]]></statetype>
			<os></os>
			<protocol>tcp/udp</protocol>
			<source>
				<network>opt1</network>
			</source>
			<destination>
				<any></any>
				<port>25</port>
			</destination>
			<descr>Created by GitOpsBox</descr>
			<disabled></disabled>
		</rule>
		<rule>
			<id></id>
			<tracker>0100000114</tracker>
			<type>block</type>
			<interface>opt1</interface>
			<ipprotocol>inet46</ipprotocol>
			<tag></tag>
			<tagged></tagged>
			<max></max>
			<max-src-nodes></max-src-nodes>
			<max-src-conn></max-src-conn>
			<max-src-states></max-src-states>
			<statetimeout></statetimeout>
			<statetype><![CDATA[keep state]]></statetype>
			<os></os>
			<source>
				<network>opt1</network>
			</source>
			<destination>
				<network>lan</network>
			</destination>
			<descr>Created by GitOpsBox</descr>
		</rule>
		<rule>
			<id></id>
			<tracker>0100000115</tracker>
			<type>pass</type>
			<interface>opt1</interface>
			<ipprotocol>inet46</ipprotocol>
			<tag></tag>
			<tagged></tagged>
			<max></max>
			<max-src-nodes></max-src-nodes>
			<max-src-conn></max-src-conn>
			<max-src-states></max-src-states>
			<statetimeout></statetimeout>
			<statetype><![CDATA[keep state]]></statetype>
			<os></os>
			<protocol>tcp/udp</protocol>
			<source>
				<network>opt1</network>
			</source>
			<destination>
				<network>opt1ip</network>
				<port>853</port>
			</destination>
			<descr>Created by GitOpsBox</descr>
		</rule>
		<rule>
			<id></id>
			<tracker>0100000116</tracker>
			<type>pass</type>
			<interface>opt1</interface>
			<ipprotocol>inet46</ipprotocol>
			<tag></tag>
			<tagged></tagged>
			<max></max>
			<max-src-nodes></max-src-nodes>
			<max-src-conn></max-src-conn>
			<max-src-states></max-src-states>
			<statetimeout></statetimeout>
			<statetype><![CDATA[keep state]]></statetype>
			<os></os>
			<protocol>tcp/udp</protocol>
			<source>
				<network>opt1</network>
			</source>
			<destination>
				<network>opt1ip</network>
				<port>53</port>
			</destination>
			<descr>Created by GitOpsBox</descr>
		</rule>
		<rule>
			<id></id>
			<tracker>0100000117</tracker>
			<type>pass</type>
			<interface>opt1</interface>
			<ipprotocol>inet46</ipprotocol>
			<tag></tag>
			<tagged></tagged>
			<max></max>
			<max-src-nodes></max-src-nodes>
			<max-src-conn></max-src-conn>
			<max-src-states></max-src-states>
			<statetimeout></statetimeout>
			<statetype><![CDATA[keep state]]></statetype>
			<os></os>
			<protocol>tcp/udp</protocol>
			<source>
				<network>opt1</network>
			</source>
			<destination>
				<any></any>
				<port>80</port>
			</destination>
			<descr>Created by GitOpsBox</descr>
			<disabled></disabled>
		</rule>
		<rule>
			<id></id>
			<tracker>0100000118</tracker>
			<type>pass</type>
			<interface>opt1</interface>
			<ipprotocol>inet46</ipprotocol>
			<tag></tag>
			<tagged></tagged>
			<max></max>
			<max-src-nodes></max-src-nodes>
			<max-src-conn></max-src-conn>
			<max-src-states></max-src-states>
			<statetimeout></statetimeout>
			<statetype><![CDATA[keep state]]></statetype>
			<os></os>
			<protocol>tcp/udp</protocol>
			<source>
				<network>opt1</network>
			</source>
			<destination>
				<any></any>
				<port>443</port>
			</destination>
			<descr>Created by GitOpsBox</descr>
			<disabled></disabled>
		</rule>
		<rule>
			<id></id>
			<tracker>0100000119</tracker>
			<type>pass</type>
			<interface>opt1</interface>
			<ipprotocol>inet</ipprotocol>
			<tag></tag>
			<tagged></tagged>
			<max></max>
			<max-src-nodes></max-src-nodes>
			<max-src-conn></max-src-conn>
			<max-src-states></max-src-states>
			<statetimeout></statetimeout>
			<statetype><![CDATA[keep state]]></statetype>
			<os></os>
			<protocol>tcp/udp</protocol>
			<source>
				<address>pvemgmtipaddress</address>
			</source>
			<destination>
				<address>debian_proxmox_repositories</address>
				<port>80</port>
			</destination>
			<descr>Created by GitOpsBox</descr>
			<disabled></disabled>
		</rule>
		<rule>
			<id></id>
			<tracker>0100000120</tracker>
			<type>pass</type>
			<interface>opt1</interface>
			<ipprotocol>inet</ipprotocol>
			<tag></tag>
			<tagged></tagged>
			<max></max>
			<max-src-nodes></max-src-nodes>
			<max-src-conn></max-src-conn>
			<max-src-states></max-src-states>
			<statetimeout></statetimeout>
			<statetype><![CDATA[keep state]]></statetype>
			<os></os>
			<protocol>tcp/udp</protocol>
			<source>
				<address>pvemgmtipaddress</address>
			</source>
			<destination>
				<address>debian_proxmox_repositories</address>
				<port>443</port>
			</destination>
			<descr>Created by GitOpsBox</descr>
			<disabled></disabled>
		</rule>															
		<rule>
			<id></id>
			<tracker>0100000121</tracker>
			<type>pass</type>
			<interface>opt1</interface>
			<ipprotocol>inet46</ipprotocol>
			<tag></tag>
			<tagged></tagged>
			<max></max>
			<max-src-nodes></max-src-nodes>
			<max-src-conn></max-src-conn>
			<max-src-states></max-src-states>
			<statetimeout></statetimeout>
			<statetype><![CDATA[keep state]]></statetype>
			<protocol>udp</protocol>
			<os></os>
			<source>
				<network>opt1</network>
			</source>
			<destination>
				<network>opt1ip</network>
				<port>123</port>
			</destination>
			<descr>Created by GitOpsBox</descr>
		</rule>
		<rule>
			<id></id>
			<tracker>0100000122</tracker>
			<type>pass</type>
			<interface>opt1</interface>
			<ipprotocol>inet</ipprotocol>
			<tag></tag>
			<tagged></tagged>
			<max></max>
			<max-src-nodes></max-src-nodes>
			<max-src-conn></max-src-conn>
			<max-src-states></max-src-states>
			<statetimeout></statetimeout>
			<statetype><![CDATA[keep state]]></statetype>
			<os></os>
			<protocol>tcp/udp</protocol>
			<source>
				<address>mgmtk3sip</address>
			</source>
			<destination>
				<any></any>
				<port>80</port>
			</destination>
			<descr>Created by GitOpsBox</descr>
			<disabled></disabled>
		</rule>		
		<rule>
			<id></id>
			<tracker>0100000123</tracker>
			<type>pass</type>
			<interface>opt1</interface>
			<ipprotocol>inet</ipprotocol>
			<tag></tag>
			<tagged></tagged>
			<max></max>
			<max-src-nodes></max-src-nodes>
			<max-src-conn></max-src-conn>
			<max-src-states></max-src-states>
			<statetimeout></statetimeout>
			<statetype><![CDATA[keep state]]></statetype>
			<os></os>
			<protocol>tcp/udp</protocol>
			<source>
				<address>mgmtk3sip</address>
			</source>
			<destination>
				<any></any>
				<port>443</port>
			</destination>
			<descr>Created by GitOpsBox</descr>
			<disabled></disabled>
		</rule>		
		<rule>
			<id></id>
			<tracker>0100000124</tracker>
			<type>block</type>
			<interface>opt1</interface>
			<ipprotocol>inet46</ipprotocol>
			<tag></tag>
			<tagged></tagged>
			<max></max>
			<max-src-nodes></max-src-nodes>
			<max-src-conn></max-src-conn>
			<max-src-states></max-src-states>
			<statetimeout></statetimeout>
			<statetype><![CDATA[keep state]]></statetype>
			<os></os>
			<source>
				<network>opt1</network>
			</source>
			<destination>
				<network>wan</network>
			</destination>
			<descr>Created by GitOpsBox</descr>
		</rule>
		<rule>
			<id></id>
			<tracker>0100000125</tracker>
			<type>pass</type>
			<interface>opt1</interface>
			<ipprotocol>inet46</ipprotocol>
			<tag></tag>
			<tagged></tagged>
			<max></max>
			<max-src-nodes></max-src-nodes>
			<max-src-conn></max-src-conn>
			<max-src-states></max-src-states>
			<statetimeout></statetimeout>
			<statetype><![CDATA[keep state]]></statetype>
			<os></os>
			<source>
				<network>opt1</network>
			</source>
			<destination>
				<any></any>
			</destination>
			<descr>Created by GitOpsBox</descr>
			<disabled></disabled>
		</rule>
		<rule>
			<id></id>
			<tracker>0100000126</tracker>
			<type>reject</type>
			<interface>wan</interface>
			<ipprotocol>inet</ipprotocol>
			<tag></tag>
			<tagged></tagged>
			<direction>out</direction>
			<quick>yes</quick>
			<floating>yes</floating>
			<max></max>
			<max-src-nodes></max-src-nodes>
			<max-src-conn></max-src-conn>
			<max-src-states></max-src-states>
			<statetimeout></statetimeout>
			<statetype><![CDATA[keep state]]></statetype>
			<os></os>
			<source>
				<any></any>
			</source>
			<destination>
				<address>private_networks</address>
			</destination>
			<descr>Prevent RFC1918 Egress</descr>
			<disabled></disabled>
		</rule>
		<separator>
			<opt1></opt1>
			<lan></lan>
		</separator>
	</filter>
	<shaper></shaper>
	<ipsec></ipsec>
	<aliases>
		<alias>
			<name>private_networks</name>
			<type>network</type>
			<address>10.0.0.0/8 172.16.0.0/12 192.168.0.0/16</address>
			<descr><![CDATA[RFC 1918 Private Networks]]></descr>
		</alias>
		<alias>
			<name>debian_proxmox_repositories</name>
			<type>host</type>
			<address>debian.org security.debian.org ftp.debian.org proxmox.com enterprise.proxmox.com download.proxmox.com fastlydns.net</address>
			<descr><![CDATA[allow proxmox updates]]></descr>
		</alias>		
	</aliases>
	<proxyarp></proxyarp>
	<cron>
		<item>
			<minute>1,31</minute>
			<hour>0-5</hour>
			<mday>*</mday>
			<month>*</month>
			<wday>*</wday>
			<who>root</who>
			<command>/usr/bin/nice -n20 adjkerntz -a</command>
		</item>
		<item>
			<minute>1</minute>
			<hour>3</hour>
			<mday>1</mday>
			<month>*</month>
			<wday>*</wday>
			<who>root</who>
			<command>/usr/bin/nice -n20 /etc/rc.update_bogons.sh</command>
		</item>
		<item>
			<minute>1</minute>
			<hour>1</hour>
			<mday>*</mday>
			<month>*</month>
			<wday>*</wday>
			<who>root</who>
			<command>/usr/bin/nice -n20 /etc/rc.dyndns.update</command>
		</item>
		<item>
			<minute>*/60</minute>
			<hour>*</hour>
			<mday>*</mday>
			<month>*</month>
			<wday>*</wday>
			<who>root</who>
			<command>/usr/bin/nice -n20 /usr/local/sbin/expiretable -v -t 3600 virusprot</command>
		</item>
		<item>
			<minute>30</minute>
			<hour>12</hour>
			<mday>*</mday>
			<month>*</month>
			<wday>*</wday>
			<who>root</who>
			<command>/usr/bin/nice -n20 /etc/rc.update_urltables</command>
		</item>
		<item>
			<minute>1</minute>
			<hour>0</hour>
			<mday>*</mday>
			<month>*</month>
			<wday>*</wday>
			<who>root</who>
			<command>/usr/bin/nice -n20 /etc/rc.update_pkg_metadata</command>
		</item>
		<item>
			<minute>0</minute>
			<hour>0</hour>
			<mday>8</mday>
			<month>*</month>
			<wday>*</wday>
			<who>root</who>
			<command>/usr/bin/nice -n20 /usr/local/bin/php-cgi -f /usr/local/pkg/suricata/suricata_geoipupdate.php</command>
		</item>
		<item>
			<minute>*/5</minute>
			<hour>*</hour>
			<mday>*</mday>
			<month>*</month>
			<wday>*</wday>
			<who>root</who>
			<command>/usr/bin/nice -n20 /usr/local/bin/php-cgi -f /usr/local/pkg/suricata/suricata_check_cron_misc.inc</command>
		</item>
		<item>
			<minute>15</minute>
			<hour>0,6,12,18</hour>
			<mday>*</mday>
			<month>*</month>
			<wday>*</wday>
			<who>root</who>
			<command>/usr/bin/nice -n20 /usr/local/bin/php-cgi -f /usr/local/pkg/suricata/suricata_check_for_rule_updates.php</command>
		</item>
	</cron>
	<wol></wol>
	<rrd>
		<enable></enable>
	</rrd>
	<load_balancer>
		<monitor_type>
			<name>ICMP</name>
			<type>icmp</type>
			<descr><![CDATA[ICMP]]></descr>
			<options></options>
		</monitor_type>
		<monitor_type>
			<name>TCP</name>
			<type>tcp</type>
			<descr><![CDATA[Generic TCP]]></descr>
			<options></options>
		</monitor_type>
		<monitor_type>
			<name>HTTP</name>
			<type>http</type>
			<descr><![CDATA[Generic HTTP]]></descr>
			<options>
				<path>/</path>
				<host></host>
				<code>200</code>
			</options>
		</monitor_type>
		<monitor_type>
			<name>HTTPS</name>
			<type>https</type>
			<descr><![CDATA[Generic HTTPS]]></descr>
			<options>
				<path>/</path>
				<host></host>
				<code>200</code>
			</options>
		</monitor_type>
		<monitor_type>
			<name>SMTP</name>
			<type>send</type>
			<descr><![CDATA[Generic SMTP]]></descr>
			<options>
				<send></send>
				<expect>220 *</expect>
			</options>
		</monitor_type>
	</load_balancer>
	<widgets>
		<sequence>system_information:col1:show,netgate_services_and_support:col2:show,interfaces:col2:show,pfblockerng:col2:show</sequence>
		<period>10</period>
	</widgets>
	<openvpn></openvpn>
	<dnshaper></dnshaper>
	<unbound>
		<enable></enable>
		<dnssec></dnssec>
		<active_interface></active_interface>
		<outgoing_interface></outgoing_interface>
		<custom_options>unboundcustomoptions</custom_options>
		<hideidentity></hideidentity>
		<hideversion></hideversion>
		<dnssecstripped></dnssecstripped>
		<hosts>
			<host>gitlab</host>
			<domain>mgmtdomain</domain>
			<ip>mgmtk3sip</ip>
			<descr></descr>
			<aliases></aliases>
		</hosts>
		<hosts>
			<host>vault</host>
			<domain>mgmtdomain</domain>
			<ip>mgmtk3sip</ip>
			<descr></descr>
			<aliases></aliases>
		</hosts>
		<hosts>
			<host>kas</host>
			<domain>mgmtdomain</domain>
			<ip>mgmtk3sip</ip>
			<descr></descr>
			<aliases></aliases>
		</hosts>
		<hosts>
			<host>code</host>
			<domain>landomain</domain>
			<ip>lank3siprangestart</ip>
			<descr></descr>
			<aliases></aliases>
		</hosts>
		<forwarding></forwarding>
		<forward_tls_upstream></forward_tls_upstream>
		<disable_auto_added_host_entries></disable_auto_added_host_entries>
	</unbound>
	<vlans>
		<vlan>
			<if>vtnet2</if>
			<tag>mgmtvlan</tag>
			<vlanif>vtnet2.mgmtvlan</vlanif>
		</vlan>
		<vlan>
			<if>vtnet1</if>
			<tag>lanvlan</tag>
			<vlanif>vtnet1.lanvlan</vlanif>
		</vlan>
	</vlans>
	<ppps></ppps>
	<installedpackages>
		<package>
			<name>pfBlockerNG-devel</name>
			<descr><![CDATA[pfBlockerNG-devel is the Next Generation of pfBlockerNG.&lt;br /&gt;
			Manage IPv4/v6 List Sources into 'Deny, Permit or Match' formats.&lt;br /&gt;
			GeoIP database by MaxMind Inc. (GeoLite2 Free version).&lt;br /&gt;
			De-Duplication, Suppression, and Reputation enhancements.&lt;br /&gt;
			Provision to download from diverse List formats.&lt;br /&gt;
			Advanced Integration for Proofpoint ET IQRisk IP Reputation Threat Sources.&lt;br /&gt;
			Domain Name (DNSBL) blocking via Unbound DNS Resolver.]]></descr>
			<pkginfolink>https://forum.netgate.com/topic/158592/pfblockerng-devel-v3-0-0-no-longer-bound-by-unbound/43</pkginfolink>
			<version>3.1.0_4</version>
			<configurationfile>pfblockerng.xml</configurationfile>
		</package>
		<package>
			<name>suricata</name>
			<website>http://suricata-ids.org/</website>
			<descr><![CDATA[High Performance Network IDS, IPS and Security Monitoring engine by OISF.]]></descr>
			<version>6.0.4_1</version>
			<configurationfile>suricata.xml</configurationfile>
			<include_file>/usr/local/pkg/suricata/suricata.inc</include_file>
		</package>
		<suricata>
			<config>
				<forcekeepsettings>on</forcekeepsettings>
				<sid_list_migration>1</sid_list_migration>
				<suricata_config_ver>6.0.4_1</suricata_config_ver>
				<enable_vrt_rules>off</enable_vrt_rules>
				<snortcommunityrules>on</snortcommunityrules>
				<enable_etopen_rules>on</enable_etopen_rules>
				<enable_etpro_rules>off</enable_etpro_rules>
				<autogeoipupdate>on</autogeoipupdate>
				<hide_deprecated_rules>on</hide_deprecated_rules>
				<enable_etopen_custom_url>off</enable_etopen_custom_url>
				<enable_etpro_custom_url>off</enable_etpro_custom_url>
				<enable_snort_custom_url>off</enable_snort_custom_url>
				<enable_gplv2_custom_url>off</enable_gplv2_custom_url>
				<snort_rules_file></snort_rules_file>
				<oinkcode></oinkcode>
				<etprocode></etprocode>
				<rm_blocked>never_b</rm_blocked>
				<autoruleupdate>6h_up</autoruleupdate>
				<auto_manage_sids>on</auto_manage_sids>
				<etopen_custom_rule_url></etopen_custom_rule_url>
				<etpro_custom_rule_url></etpro_custom_rule_url>
				<snort_custom_url></snort_custom_url>
				<gplv2_custom_url></gplv2_custom_url>
				<maxmind_geoipdb_key></maxmind_geoipdb_key>
				<log_to_systemlog>off</log_to_systemlog>
				<log_to_systemlog_facility>local1</log_to_systemlog_facility>
				<live_swap_updates>off</live_swap_updates>
				<autoruleupdatetime>00:15</autoruleupdatetime>
			</config>
			<sid_mgmt_lists>
				<item>
					<name>disablewan.conf</name>
					<modtime>1604937812</modtime>
					<content>suricatadisablesidwan</content>
				</item>
				<item>
					<name>disablesid-sample.conf</name>
					<modtime>1604937812</modtime>
					<content>IyBleGFtcGxlIGRpc2FibGVzaWQuY29uZgoKIyBFeGFtcGxlIG9mIG1vZGlmeWluZyBzdGF0ZSBmb3IgaW5kaXZpZHVhbCBydWxlcwojIDE6MTAzNCwxOjk4MzcsMToxMjcwLDE6MzM5MCwxOjcxMCwxOjEyNDksMzoxMzAxMAoKIyBFeGFtcGxlIG9mIG1vZGlmeWluZyBzdGF0ZSBmb3IgcnVsZSByYW5nZXMKIyAxOjIyMC0xOjMyNjQsMzoxMzAxMC0zOjEzMDEzCgojIENvbW1lbnRzIGFyZSBhbGxvd2VkIGluIHRoaXMgZmlsZSwgYW5kIGNhbiBhbHNvIGJlIG9uIHRoZSBzYW1lIGxpbmUKIyBBcyB0aGUgbW9kaWZ5IHN0YXRlIHN5bnRheCwgYXMgbG9uZyBhcyBpdCBpcyBhIHRyYWlsaW5nIGNvbW1lbnQKIyAxOjEwMTEgIyBJIERpc2FibGVkIHRoaXMgcnVsZSBiZWNhdXNlIEkgY291bGQhCgojIEV4YW1wbGUgb2YgbW9kaWZ5aW5nIHN0YXRlIGZvciBNUyBhbmQgY3ZlIHJ1bGVzLCBub3RlIHRoZSB1c2Ugb2YgdGhlIDogCiMgaW4gY3ZlLiBUaGlzIHdpbGwgbW9kaWZ5IE1TMDktMDA4LCBjdmUgMjAwOS0wMjMzLCBidWd0cmFxIDIxMzAxLAojIGFuZCBhbGwgTVMwMCBhbmQgYWxsIGN2ZSAyMDAwIHJlbGF0ZWQgc2lkcyEgIFRoZXNlIHN1cHBvcnQgcmVndWxhciBleHByZXNzaW9uCiMgbWF0Y2hpbmcgb25seSBhZnRlciB5b3UgaGF2ZSBzcGVjaWZpZWQgd2hhdCB5b3UgYXJlIGxvb2tpbmcgZm9yLCBpLmUuIAojIE1TMDAtPHJlZ2V4PiBvciBjdmU6PHJlZ2V4PiwgdGhlIGZpcnN0IHNlY3Rpb24gQ0FOTk9UIGNvbnRhaW4gYSByZWd1bGFyCiMgZXhwcmVzc2lvbiAoTVNcZHsyfS1cZCspIHdpbGwgTk9UIHdvcmssIHVzZSB0aGUgcGNyZToga2V5d29yZCAoYmVsb3cpCiMgZm9yIHRoaXMuCiMgTVMwOS0wMDgsY3ZlOjIwMDktMDIzMyxidWd0cmFxOjIxMzAxLE1TMDAtXGQrLGN2ZToyMDAwLVxkKwoKIyBFeGFtcGxlIG9mIHVzaW5nIHRoZSBwY3JlOiBrZXl3b3JkIHRvIG1vZGlmeSBydWxlc3RhdGUuICB0aGUgcGNyZSBrZXl3b3JkIAojIGFsbG93cyBmb3IgZnVsbCB1c2Ugb2YgcmVndWxhciBleHByZXNzaW9uIHN5bnRheCwgeW91IGRvIG5vdCBuZWVkIHRvIGRlc2lnbmF0ZQojIHdpdGggLyBhbmQgYWxsIHBjcmUgc2VhcmNoZXMgYXJlIHRyZWF0ZWQgYXMgY2FzZSBpbnNlbnNpdGl2ZS4gRm9yIG1vcmUgaW5mb3JtYXRpb24gCiMgYWJvdXQgcmVndWxhciBleHByZXNzaW9uIHN5bnRheDogaHR0cDovL3d3dy5yZWd1bGFyLWV4cHJlc3Npb25zLmluZm8vCiMgVGhlIGZvbGxvd2luZyBleGFtcGxlIG1vZGlmaWVzIHN0YXRlIGZvciBhbGwgTVMwNyB0aHJvdWdoIE1TMTAgCiMgcGNyZTpNUygwWzctOV18MTApLVxkKwojIHBjcmU6Ikpvb21sYSIKCiMgRXhhbXBsZSBvZiBtb2RpZnlpbmcgc3RhdGUgZm9yIHNwZWNpZmljIGNhdGVnb3JpZXMgZW50aXJlbHkuCiMgInNub3J0XyIgbGltaXRzIHRvIFNub3J0IFZSVCBydWxlcywgImVtZXJnaW5nLSIgbGltaXRzIHRvIAojIEVtZXJnaW5nIFRocmVhdHMgT3BlbiBydWxlcywgImV0cHJvLSIgbGltaXRzIHRvIEVULVBSTyBydWxlcy4KIyAic2hlbGxjb2RlIiB3aXRoIG5vIHByZWZpeCB3b3VsZCBtYXRjaCBpbiBhbnkgdmVuZG9yIHNldC4KIyBzbm9ydF93ZWItaWlzLGVtZXJnaW5nLXNoZWxsY29kZSxldHByby1pbWFwLHNoZWxsY29kZQoKIyBBbnkgb2YgdGhlIGFib3ZlIHZhbHVlcyBjYW4gYmUgb24gYSBzaW5nbGUgbGluZSBvciBtdWx0aXBsZSBsaW5lcywgd2hlbiAKIyBvbiBhIHNpbmdsZSBsaW5lIHRoZXkgc2ltcGx5IG5lZWQgdG8gYmUgc2VwYXJhdGVkIGJ5IGEgLAojIDE6OTgzNywxOjIyMC0xOjMyNjQsMzoxMzAxMC0zOjEzMDEzLHBjcmU6TVMoMFswLTddKS1cZCssTVMwOS0wMDgsY3ZlOjIwMDktMDIzMwoKIyBUaGUgbW9kaWZpY2F0aW9ucyBpbiB0aGlzIGZpbGUgYXJlIGZvciBzYW1wbGUvZXhhbXBsZSBwdXJwb3NlcyBvbmx5IGFuZAojIHNob3VsZCBub3QgYWN0aXZlbHkgYmUgdXNlZCwgeW91IG5lZWQgdG8gbW9kaWZ5IHRoaXMgZmlsZSB0byBmaXQgeW91ciAKIyBlbnZpcm9ubWVudC4KCg==</content>
				</item>
				<item>
					<name>dropsid-sample.conf</name>
					<modtime>1604937812</modtime>
					<content>IyBOb3RlOiBUaGlzIGZpbGUgaXMgdXNlZCB0byBzcGVjaWZ5IHdoYXQgcnVsZXMgeW91IHdpc2ggdG8gYmUgc2V0IHRvIGhhdmUKIyBhbiBhY3Rpb24gb2YgZHJvcCByYXRoZXIgdGhhbiBhbGVydC4KCiMgRXhhbXBsZSBvZiBtb2RpZnlpbmcgc3RhdGUgZm9yIGluZGl2aWR1YWwgcnVsZXMKIyAxOjEwMzQsMTo5ODM3LDE6MTI3MCwxOjMzOTAsMTo3MTAsMToxMjQ5LDM6MTMwMTAKCiMgRXhhbXBsZSBvZiBtb2RpZnlpbmcgc3RhdGUgZm9yIHJ1bGUgcmFuZ2VzCiMgMToyMjAtMTozMjY0LDM6MTMwMTAtMzoxMzAxMwoKIyBDb21tZW50cyBhcmUgYWxsb3dlZCBpbiB0aGlzIGZpbGUsIGFuZCBjYW4gYWxzbyBiZSBvbiB0aGUgc2FtZSBsaW5lCiMgQXMgdGhlIG1vZGlmeSBzdGF0ZSBzeW50YXgsIGFzIGxvbmcgYXMgaXQgaXMgYSB0cmFpbGluZyBjb21tZW50CiMgMToxMDExICMgSSBEaXNhYmxlZCB0aGlzIHJ1bGUgYmVjYXVzZSBJIGNvdWxkIQoKIyBFeGFtcGxlIG9mIG1vZGlmeWluZyBzdGF0ZSBmb3IgTVMgYW5kIGN2ZSBydWxlcywgbm90ZSB0aGUgdXNlIG9mIHRoZSA6IAojIGluIGN2ZS4gVGhpcyB3aWxsIG1vZGlmeSBNUzA5LTAwOCwgY3ZlIDIwMDktMDIzMywgYnVndHJhcSAyMTMwMSwKIyBhbmQgYWxsIE1TMDAgYW5kIGFsbCBjdmUgMjAwMCByZWxhdGVkIHNpZHMhICBUaGVzZSBzdXBwb3J0IHJlZ3VsYXIgZXhwcmVzc2lvbgojIG1hdGNoaW5nIG9ubHkgYWZ0ZXIgeW91IGhhdmUgc3BlY2lmaWVkIHdoYXQgeW91IGFyZSBsb29raW5nIGZvciwgaS5lLiAKIyBNUzAwLTxyZWdleD4gb3IgY3ZlOjxyZWdleD4sIHRoZSBmaXJzdCBzZWN0aW9uIENBTk5PVCBjb250YWluIGEgcmVndWxhcgojIGV4cHJlc3Npb24gKE1TXGR7Mn0tXGQrKSB3aWxsIE5PVCB3b3JrLCB1c2UgdGhlIHBjcmU6IGtleXdvcmQgKGJlbG93KQojIGZvciB0aGlzLgojIE1TMDktMDA4LGN2ZToyMDA5LTAyMzMsYnVndHJhcToyMTMwMSxNUzAwLVxkKyxjdmU6MjAwMC1cZCsKCiMgRXhhbXBsZSBvZiB1c2luZyB0aGUgcGNyZToga2V5d29yZCB0byBtb2RpZnkgcnVsZXN0YXRlLiAgdGhlIHBjcmUga2V5d29yZCAKIyBhbGxvd3MgZm9yIGZ1bGwgdXNlIG9mIHJlZ3VsYXIgZXhwcmVzc2lvbiBzeW50YXgsIHlvdSBkbyBub3QgbmVlZCB0byBkZXNpZ25hdGUKIyB3aXRoIC8gYW5kIGFsbCBwY3JlIHNlYXJjaGVzIGFyZSB0cmVhdGVkIGFzIGNhc2UgaW5zZW5zaXRpdmUuIEZvciBtb3JlIGluZm9ybWF0aW9uIAojIGFib3V0IHJlZ3VsYXIgZXhwcmVzc2lvbiBzeW50YXg6IGh0dHA6Ly93d3cucmVndWxhci1leHByZXNzaW9ucy5pbmZvLwojIFRoZSBmb2xsb3dpbmcgZXhhbXBsZSBtb2RpZmllcyBzdGF0ZSBmb3IgYWxsIE1TMDcgdGhyb3VnaCBNUzEwIAojIHBjcmU6TVMoMFs3LTldfDEwKS1cZCsKCiMgVGhlIGZvbGxvd2luZyBleGFtcGxlIG1vZGlmaWVzIHN0YXRlIGZvciBTbm9ydCBWUlQgcnVsZXMgdGFnZ2VkIHdpdGggSVBTIAojIFBvbGljeSBTZWN1cml0eSBhbmQgaXBzIGRyb3AKIyAtLS0tLS0tLS0tLS0tLS0tLQojIHBjcmU6InBjcmU6c2VjdXJpdHktaXBzXHMqZHJvcCIKCiMgRXhhbXBsZSBvZiBtb2RpZnlpbmcgc3RhdGUgZm9yIHNwZWNpZmljIGNhdGVnb3JpZXMgZW50aXJlbHkKIyBWUlQtd2ViLWlpcyxFVC1zaGVsbGNvZGUsRVQtZW1lcmdpbmd0aHJlYXRzLXNtdHAsQ3VzdG9tLXNoZWxsY29kZSxDdXN0b20tZW1lcmdpbmd0aHJlYXRzLXNtdHAKCiMgQW55IG9mIHRoZSBhYm92ZSB2YWx1ZXMgY2FuIGJlIG9uIGEgc2luZ2xlIGxpbmUgb3IgbXVsdGlwbGUgbGluZXMsIHdoZW4gCiMgb24gYSBzaW5nbGUgbGluZSB0aGV5IHNpbXBseSBuZWVkIHRvIGJlIHNlcGFyYXRlZCBieSBhICwKIyAxOjk4MzcsMToyMjAtMTozMjY0LDM6MTMwMTAtMzoxMzAxMyxwY3JlOk1TKDBbMC03XSktXGQrLE1TMDktMDA4LGN2ZToyMDA5LTAyMzMKCiMgVGhlIG1vZGlmaWNhdGlvbnMgaW4gdGhpcyBmaWxlIGFyZSBmb3Igc2FtcGxlL2V4YW1wbGUgcHVycG9zZXMgb25seSBhbmQKIyBzaG91bGQgbm90IGFjdGl2ZWx5IGJlIHVzZWQsIHlvdSBuZWVkIHRvIG1vZGlmeSB0aGlzIGZpbGUgdG8gZml0IHlvdXIgCiMgZW52aXJvbm1lbnQuCg==</content>
				</item>
				<item>
					<name>enablesid-sample.conf</name>
					<modtime>1604937812</modtime>
					<content>IyBleGFtcGxlIGVuYWJsZXNpZC5jb25mCgojIEV4YW1wbGUgb2YgbW9kaWZ5aW5nIHN0YXRlIGZvciBpbmRpdmlkdWFsIHJ1bGVzCiMgMToxMDM0LDE6OTgzNywxOjEyNzAsMTozMzkwLDE6NzEwLDE6MTI0OSwzOjEzMDEwCgojIEV4YW1wbGUgb2YgbW9kaWZ5aW5nIHN0YXRlIGZvciBydWxlIHJhbmdlcwojIDE6MjIwLTE6MzI2NCwzOjEzMDEwLTM6MTMwMTMKCiMgQ29tbWVudHMgYXJlIGFsbG93ZWQgaW4gdGhpcyBmaWxlLCBhbmQgY2FuIGFsc28gYmUgb24gdGhlIHNhbWUgbGluZQojIEFzIHRoZSBtb2RpZnkgc3RhdGUgc3ludGF4LCBhcyBsb25nIGFzIGl0IGlzIGEgdHJhaWxpbmcgY29tbWVudAojIDE6MTAxMSAjIEkgRGlzYWJsZWQgdGhpcyBydWxlIGJlY2F1c2UgSSBjb3VsZCEKCiMgRXhhbXBsZSBvZiBtb2RpZnlpbmcgc3RhdGUgZm9yIE1TIGFuZCBjdmUgcnVsZXMsIG5vdGUgdGhlIHVzZSBvZiB0aGUgOiAKIyBpbiBjdmUuIFRoaXMgd2lsbCBtb2RpZnkgTVMwOS0wMDgsIGN2ZSAyMDA5LTAyMzMsIGJ1Z3RyYXEgMjEzMDEsCiMgYW5kIGFsbCBNUzAwIGFuZCBhbGwgY3ZlIDIwMDAgcmVsYXRlZCBzaWRzISAgVGhlc2Ugc3VwcG9ydCByZWd1bGFyIGV4cHJlc3Npb24KIyBtYXRjaGluZyBvbmx5IGFmdGVyIHlvdSBoYXZlIHNwZWNpZmllZCB3aGF0IHlvdSBhcmUgbG9va2luZyBmb3IsIGkuZS4gCiMgTVMwMC08cmVnZXg+IG9yIGN2ZTo8cmVnZXg+LCB0aGUgZmlyc3Qgc2VjdGlvbiBDQU5OT1QgY29udGFpbiBhIHJlZ3VsYXIKIyBleHByZXNzaW9uIChNU1xkezJ9LVxkKykgd2lsbCBOT1Qgd29yaywgdXNlIHRoZSBwY3JlOiBrZXl3b3JkIChiZWxvdykKIyBmb3IgdGhpcy4KIyBNUzA5LTAwOCxjdmU6MjAwOS0wMjMzLGJ1Z3RyYXE6MjEzMDEsTVMwMC1cZCssY3ZlOjIwMDAtXGQrCgojIEV4YW1wbGUgb2YgdXNpbmcgdGhlIHBjcmU6IGtleXdvcmQgdG8gbW9kaWZ5IHJ1bGVzdGF0ZS4gIHRoZSBwY3JlIGtleXdvcmQgCiMgYWxsb3dzIGZvciBmdWxsIHVzZSBvZiByZWd1bGFyIGV4cHJlc3Npb24gc3ludGF4LCB5b3UgZG8gbm90IG5lZWQgdG8gZGVzaWduYXRlCiMgd2l0aCAvIGFuZCBhbGwgcGNyZSBzZWFyY2hlcyBhcmUgdHJlYXRlZCBhcyBjYXNlIGluc2Vuc2l0aXZlLiBGb3IgbW9yZSBpbmZvcm1hdGlvbiAKIyBhYm91dCByZWd1bGFyIGV4cHJlc3Npb24gc3ludGF4OiBodHRwOi8vd3d3LnJlZ3VsYXItZXhwcmVzc2lvbnMuaW5mby8KIyBUaGUgZm9sbG93aW5nIGV4YW1wbGUgbW9kaWZpZXMgc3RhdGUgZm9yIGFsbCBNUzA3IHRocm91Z2ggTVMxMCAKIyBwY3JlOk1TKDBbNy05XXwxMCktXGQrCiMgcGNyZToiSm9vbWxhIgoKIyBFeGFtcGxlIG9mIG1vZGlmeWluZyBzdGF0ZSBmb3Igc3BlY2lmaWMgY2F0ZWdvcmllcyBlbnRpcmVseS4KIyAic25vcnRfIiBsaW1pdHMgdG8gU25vcnQgVlJUIHJ1bGVzLCAiZW1lcmdpbmctIiBsaW1pdHMgdG8gCiMgRW1lcmdpbmcgVGhyZWF0cyBPcGVuIHJ1bGVzLCAiZXRwcm8tIiBsaW1pdHMgdG8gRVQtUFJPIHJ1bGVzLgojICJzaGVsbGNvZGUiIHdpdGggbm8gcHJlZml4IHdvdWxkIG1hdGNoIGluIGFueSB2ZW5kb3Igc2V0LgojIHNub3J0X3dlYi1paXMsZW1lcmdpbmctc2hlbGxjb2RlLGV0cHJvLWltYXAsc2hlbGxjb2RlCgojIEFueSBvZiB0aGUgYWJvdmUgdmFsdWVzIGNhbiBiZSBvbiBhIHNpbmdsZSBsaW5lIG9yIG11bHRpcGxlIGxpbmVzLCB3aGVuIAojIG9uIGEgc2luZ2xlIGxpbmUgdGhleSBzaW1wbHkgbmVlZCB0byBiZSBzZXBhcmF0ZWQgYnkgYSAsCiMgMTo5ODM3LDE6MjIwLTE6MzI2NCwzOjEzMDEwLTM6MTMwMTMscGNyZTpNUygwWzAtN10pLVxkKyxNUzA5LTAwOCxjdmU6MjAwOS0wMjMzCgo=</content>
				</item>
				<item>
					<name>modifysid-sample.conf</name>
					<modtime>1604937812</modtime>
					<content>IyBleGFtcGxlIG1vZGlmeXNpZC5jb25mCiMKIyBmb3JtYXR0aW5nIGlzIHNpbXBsZQojIDxzaWQsIGNhdGVnb3J5LCBsaXN0IG9mIHNpZHMmY2F0ZWdvcmllcz4gIndoYXQgSSdtIHJlcGxhY2luZyIgIndoYXQgSSdtIHJlcGxhY2luZyBpdCB3aXRoIgojCiMgTm90ZSB0aGF0IHRoaXMgd2lsbCBvbmx5IHdvcmsgd2l0aCBHSUQ6MSBydWxlcywgc2ltcGx5IGJlY2F1c2UgbW9kaWZ5aW5nCiMgR0lEOjMgU08gc3R1YiBydWxlcyB3b3VsZCBub3QgYWN0dWFsbHkgYWZmZWN0IHRoZSBydWxlLgojCiMgSWYgeW91IGFyZSBhdHRlbXB0aW5nIHRvIGNoYW5nZSBydWxlc3RhdGUgKGVuYWJsZSxkaXNhYmxlKSBmcm9tIGhlcmUKIyB0aGVuIHlvdSBhcmUgZG9pbmcgaXQgd3JvbmcuIERvIHRoaXMgZnJvbSB3aXRoaW4gdGhlIHJlc3BlY3RpdmUgCiMgcnVsZXN0YXRlIG1vZGlmaWNhdGlvbiBjb25maWd1cmF0aW9uIGZpbGVzLgoKIyB0aGUgZm9sbG93aW5nIGFwcGxpZXMgdG8gc2lkIDEwMDEwIG9ubHkgYW5kIHJlcHJlc2VudHMgd2hhdCB3b3VsZCBub3JtYWxseQojIGJlIHMvdG9fY2xpZW50L2Zyb21fc2VydmVyLwojIDEwMDEwICJ0b19jbGllbnQiICJmcm9tX3NlcnZlciIKCiMgdGhlIGZvbGxvd2luZyB3b3VsZCByZXBsYWNlIEhUVFBfUE9SVFMgd2l0aCBIVFRQU19QT1JUUyBmb3IgQUxMIEdJRDoxCiMgcnVsZXMKIyAiSFRUUF9QT1JUUyIgIkhUVFBTX1BPUlRTIgoKIyBtdWx0aXBsZSBzaWRzIGNhbiBiZSBzcGVjaWZpZWQgYXMgbm90ZWQgYmVsb3c6CiMgMzAyLDQyOSwxODIxICIkRVhURVJOQUxfTkVUIiAiJEhPTUVfTkVUIgoKIyBtb2RpZnkgYWxsIHNpZ25hdHVyZXMgaW4gYSBjYXRlZ29yeS4gRXhhbXBsZTogcmVwbGFjZSAiJEVYVEVSTkFMX05FVFMiIHdpdGggImFueSIgdG8gYmUgYWxlcnRzIG9uIGluc2lkZXIgdGhyZWF0cyBhcyB3ZWxsCiMgZW1lcmdpbmctc2NhbiAiJEVYVEVSTkFMX05FVCIgImFueSIKCiMgbW9kaWZ5IGFsbCBzaWduYXR1cmVzIGluIG11bHRpcGxlIGNhdGVnb3JpZXMKIyBlbWVyZ2luZy1zY2FuLGVtZXJnaW5nLXNxbCAiJEVYVEVSTkFMX05FVCIgImFueSIKCiMgbW9kaWZ5IGFsbCBzaWduYXR1cmVzIGZvciBhIGNhdGVnb3J5IGFuZCBzcGVjaWZpYyBTSURzIGZyb20gb3RoZXIgY2F0ZWdvcmllcwojIGVtZXJnaW5nLXNxbCwyMTAwNjkxLDIwMDk4MTcgIiRFWFRFUk5BTF9ORVQiICJhbnkiCg==</content>
				</item>
			</sid_mgmt_lists>
			<rule>
				<interface>wan</interface>
				<enable>wanids</enable>
				<uuid>40910</uuid>
				<descr><![CDATA[WAN]]></descr>
				<max_pcap_log_size>32</max_pcap_log_size>
				<max_pcap_log_files>1000</max_pcap_log_files>
				<enable_stats_collection>off</enable_stats_collection>
				<enable_stats_log>off</enable_stats_log>
				<append_stats_log>off</append_stats_log>
				<stats_upd_interval>10</stats_upd_interval>
				<enable_telegraf_stats>off</enable_telegraf_stats>
				<enable_http_log>on</enable_http_log>
				<append_http_log>on</append_http_log>
				<enable_tls_log>off</enable_tls_log>
				<enable_tls_store>off</enable_tls_store>
				<http_log_extended>on</http_log_extended>
				<tls_log_extended>on</tls_log_extended>
				<enable_pcap_log>off</enable_pcap_log>
				<enable_file_store>off</enable_file_store>
				<file_store_logdir>L3Zhci9sb2cvc3VyaWNhdGEvc3VyaWNhdGFfL2ZpbGVzdG9yZQ==</file_store_logdir>
				<enable_eve_log>off</enable_eve_log>
				<runmode>autofp</runmode>
				<max_pending_packets>1024</max_pending_packets>
				<inspect_recursion_limit>3000</inspect_recursion_limit>
				<intf_snaplen>1518</intf_snaplen>
				<detect_eng_profile>medium</detect_eng_profile>
				<mpm_algo>auto</mpm_algo>
				<sgh_mpm_context>auto</sgh_mpm_context>
				<blockoffenders>wanips</blockoffenders>
				<ips_mode>ips_mode_legacy</ips_mode>
				<blockoffenderskill>on</blockoffenderskill>
				<block_drops_only>off</block_drops_only>
				<blockoffendersip>both</blockoffendersip>
				<passlistname>default</passlistname>
				<homelistname>default</homelistname>
				<externallistname>default</externallistname>
				<suppresslistname>default</suppresslistname>
				<alertsystemlog>off</alertsystemlog>
				<alertsystemlog_facility>local1</alertsystemlog_facility>
				<alertsystemlog_priority>notice</alertsystemlog_priority>
				<eve_output_type>regular</eve_output_type>
				<eve_systemlog_facility>local1</eve_systemlog_facility>
				<eve_systemlog_priority>notice</eve_systemlog_priority>
				<eve_log_alerts>on</eve_log_alerts>
				<eve_log_alerts_payload>on</eve_log_alerts_payload>
				<eve_log_alerts_packet>on</eve_log_alerts_packet>
				<eve_log_alerts_metadata>on</eve_log_alerts_metadata>
				<eve_log_alerts_http>on</eve_log_alerts_http>
				<eve_log_alerts_xff>off</eve_log_alerts_xff>
				<eve_log_alerts_xff_mode>extra-data</eve_log_alerts_xff_mode>
				<eve_log_alerts_xff_deployment>reverse</eve_log_alerts_xff_deployment>
				<eve_log_alerts_xff_header>X-Forwarded-For</eve_log_alerts_xff_header>
				<eve_log_anomaly>off</eve_log_anomaly>
				<eve_log_anomaly_type_decode>off</eve_log_anomaly_type_decode>
				<eve_log_anomaly_type_stream>off</eve_log_anomaly_type_stream>
				<eve_log_anomaly_type_applayer>on</eve_log_anomaly_type_applayer>
				<eve_log_anomaly_packethdr>off</eve_log_anomaly_packethdr>
				<eve_log_http>on</eve_log_http>
				<eve_log_dns>on</eve_log_dns>
				<eve_log_tls>on</eve_log_tls>
				<eve_log_dhcp>on</eve_log_dhcp>
				<eve_log_nfs>on</eve_log_nfs>
				<eve_log_smb>on</eve_log_smb>
				<eve_log_krb5>on</eve_log_krb5>
				<eve_log_ikev2>on</eve_log_ikev2>
				<eve_log_tftp>on</eve_log_tftp>
				<eve_log_rdp>off</eve_log_rdp>
				<eve_log_sip>off</eve_log_sip>
				<eve_log_files>on</eve_log_files>
				<eve_log_ssh>on</eve_log_ssh>
				<eve_log_smtp>on</eve_log_smtp>
				<eve_log_stats>off</eve_log_stats>
				<eve_log_flow>off</eve_log_flow>
				<eve_log_netflow>off</eve_log_netflow>
				<eve_log_snmp>on</eve_log_snmp>
				<eve_log_stats_totals>on</eve_log_stats_totals>
				<eve_log_stats_deltas>off</eve_log_stats_deltas>
				<eve_log_stats_threads>off</eve_log_stats_threads>
				<eve_log_http_extended>on</eve_log_http_extended>
				<eve_log_tls_extended>on</eve_log_tls_extended>
				<eve_log_dhcp_extended>off</eve_log_dhcp_extended>
				<eve_log_smtp_extended>on</eve_log_smtp_extended>
				<eve_log_http_extended_headers>accept, accept-charset, accept-datetime, accept-encoding, accept-language, accept-range, age, allow, authorization, cache-control, connection, content-encoding, content-language, content-length, content-location, content-md5, content-range, content-type, cookie, date, dnt, etags, from, last-modified, link, location, max-forwards, origin, pragma, proxy-authenticate, proxy-authorization, range, referrer, refresh, retry-after, server, set-cookie, te, trailer, transfer-encoding, upgrade, vary, via, warning, www-authenticate, x-authenticated-user, x-flash-version, x-forwarded-proto, x-requested-with</eve_log_http_extended_headers>
				<eve_log_smtp_extended_fields>bcc, received, reply-to, x-mailer, x-originating-ip</eve_log_smtp_extended_fields>
				<eve_log_tls_extended_fields></eve_log_tls_extended_fields>
				<eve_log_files_magic>off</eve_log_files_magic>
				<eve_log_files_hash>none</eve_log_files_hash>
				<eve_log_drop>on</eve_log_drop>
				<delayed_detect>off</delayed_detect>
				<intf_promisc_mode>on</intf_promisc_mode>
				<eve_redis_server>127.0.0.1</eve_redis_server>
				<eve_redis_port>6379</eve_redis_port>
				<eve_redis_mode>list</eve_redis_mode>
				<eve_redis_key>suricata</eve_redis_key>
				<ip_max_frags>65535</ip_max_frags>
				<ip_frag_timeout>60</ip_frag_timeout>
				<frag_memcap>33554432</frag_memcap>
				<ip_max_trackers>65535</ip_max_trackers>
				<frag_hash_size>65536</frag_hash_size>
				<flow_memcap>33554432</flow_memcap>
				<flow_prealloc>10000</flow_prealloc>
				<flow_hash_size>65536</flow_hash_size>
				<flow_emerg_recovery>30</flow_emerg_recovery>
				<flow_prune>5</flow_prune>
				<flow_tcp_new_timeout>60</flow_tcp_new_timeout>
				<flow_tcp_established_timeout>3600</flow_tcp_established_timeout>
				<flow_tcp_closed_timeout>120</flow_tcp_closed_timeout>
				<flow_tcp_emerg_new_timeout>10</flow_tcp_emerg_new_timeout>
				<flow_tcp_emerg_established_timeout>300</flow_tcp_emerg_established_timeout>
				<flow_tcp_emerg_closed_timeout>20</flow_tcp_emerg_closed_timeout>
				<flow_udp_new_timeout>30</flow_udp_new_timeout>
				<flow_udp_established_timeout>300</flow_udp_established_timeout>
				<flow_udp_emerg_new_timeout>10</flow_udp_emerg_new_timeout>
				<flow_udp_emerg_established_timeout>100</flow_udp_emerg_established_timeout>
				<flow_icmp_new_timeout>30</flow_icmp_new_timeout>
				<flow_icmp_established_timeout>300</flow_icmp_established_timeout>
				<flow_icmp_emerg_new_timeout>10</flow_icmp_emerg_new_timeout>
				<flow_icmp_emerg_established_timeout>100</flow_icmp_emerg_established_timeout>
				<stream_memcap>67108864</stream_memcap>
				<stream_prealloc_sessions>32768</stream_prealloc_sessions>
				<reassembly_memcap>67108864</reassembly_memcap>
				<reassembly_depth>1048576</reassembly_depth>
				<reassembly_to_server_chunk>2560</reassembly_to_server_chunk>
				<reassembly_to_client_chunk>2560</reassembly_to_client_chunk>
				<max_synack_queued>5</max_synack_queued>
				<enable_midstream_sessions>off</enable_midstream_sessions>
				<enable_async_sessions>off</enable_async_sessions>
				<asn1_max_frames>256</asn1_max_frames>
				<dns_global_memcap>16777216</dns_global_memcap>
				<dns_state_memcap>524288</dns_state_memcap>
				<dns_request_flood_limit>500</dns_request_flood_limit>
				<http_parser_memcap>67108864</http_parser_memcap>
				<dns_parser_udp>yes</dns_parser_udp>
				<dns_parser_tcp>yes</dns_parser_tcp>
				<dns_parser_udp_ports>53</dns_parser_udp_ports>
				<dns_parser_tcp_ports>53</dns_parser_tcp_ports>
				<http_parser>yes</http_parser>
				<tls_parser>yes</tls_parser>
				<tls_detect_ports>443</tls_detect_ports>
				<tls_encrypt_handling>full</tls_encrypt_handling>
				<tls_ja3_fingerprint>on</tls_ja3_fingerprint>
				<smtp_parser>yes</smtp_parser>
				<smtp_parser_decode_mime></smtp_parser_decode_mime>
				<smtp_parser_decode_base64>on</smtp_parser_decode_base64>
				<smtp_parser_decode_quoted_printable>on</smtp_parser_decode_quoted_printable>
				<smtp_parser_extract_urls>on</smtp_parser_extract_urls>
				<smtp_parser_compute_body_md5></smtp_parser_compute_body_md5>
				<imap_parser>detection-only</imap_parser>
				<ssh_parser>yes</ssh_parser>
				<ftp_parser>yes</ftp_parser>
				<dcerpc_parser>yes</dcerpc_parser>
				<smb_parser>yes</smb_parser>
				<msn_parser>detection-only</msn_parser>
				<krb5_parser>yes</krb5_parser>
				<ikev2_parser>yes</ikev2_parser>
				<nfs_parser>yes</nfs_parser>
				<tftp_parser>yes</tftp_parser>
				<ntp_parser>yes</ntp_parser>
				<dhcp_parser>yes</dhcp_parser>
				<enable_iprep>off</enable_iprep>
				<host_memcap>33554432</host_memcap>
				<host_hash_size>4096</host_hash_size>
				<host_prealloc>1000</host_prealloc>
				<host_os_policy>
					<item>
						<name>default</name>
						<bind_to>all</bind_to>
						<policy>bsd</policy>
					</item>
				</host_os_policy>
				<libhtp_policy>
					<item>
						<name>default</name>
						<bind_to>all</bind_to>
						<personality>IDS</personality>
						<request-body-limit>4096</request-body-limit>
						<response-body-limit>4096</response-body-limit>
						<double-decode-path>no</double-decode-path>
						<double-decode-query>no</double-decode-query>
						<uri-include-all>no</uri-include-all>
						<meta-field-limit>18432</meta-field-limit>
					</item>
				</libhtp_policy>
				<rulesets>app-layer-events.rules||decoder-events.rules||dnp3-events.rules||dns-events.rules||files.rules||http-events.rules||ipsec-events.rules||kerberos-events.rules||modbus-events.rules||nfs-events.rules||ntp-events.rules||smb-events.rules||smtp-events.rules||tls-events.rules||GPLv2_community.rules||emerging-3coresec.rules||emerging-activex.rules||emerging-adware_pup.rules||emerging-attack_response.rules||emerging-botcc.portgrouped.rules||emerging-botcc.rules||emerging-ciarmy.rules||emerging-coinminer.rules||emerging-compromised.rules||emerging-current_events.rules||emerging-dos.rules||emerging-drop.rules||emerging-dshield.rules||emerging-exploit.rules||emerging-exploit_kit.rules||emerging-hunting.rules||emerging-ja3.rules||emerging-malware.rules||emerging-mobile_malware.rules||emerging-phishing.rules||emerging-rpc.rules||emerging-scan.rules||emerging-shellcode.rules||emerging-snmp.rules||emerging-sql.rules||emerging-telnet.rules||emerging-tftp.rules||emerging-tor.rules||emerging-web_client.rules||emerging-web_server.rules||emerging-web_specific_apps.rules||emerging-worm.rules</rulesets>
				<ips_policy_enable>off</ips_policy_enable>
				<autoflowbitrules>on</autoflowbitrules>
				<rdp_parser>yes</rdp_parser>
				<sip_parser>yes</sip_parser>
				<snmp_parser>yes</snmp_parser>
				<disable_sid_file>disablewan.conf</disable_sid_file>
				<sid_state_order>disable_enable</sid_state_order>
				<drop_sid_file>none</drop_sid_file>
				<reject_sid_file>none</reject_sid_file>
			</rule>
			<rule>
				<interface>lan</interface>
				<enable>lanids</enable>
				<uuid>6603</uuid>
				<descr><![CDATA[LAN]]></descr>
				<max_pcap_log_size>32</max_pcap_log_size>
				<max_pcap_log_files>1000</max_pcap_log_files>
				<enable_stats_collection>off</enable_stats_collection>
				<enable_stats_log>off</enable_stats_log>
				<append_stats_log>off</append_stats_log>
				<stats_upd_interval>10</stats_upd_interval>
				<enable_telegraf_stats>off</enable_telegraf_stats>
				<enable_http_log>on</enable_http_log>
				<append_http_log>on</append_http_log>
				<enable_tls_log>off</enable_tls_log>
				<enable_tls_store>off</enable_tls_store>
				<http_log_extended>on</http_log_extended>
				<tls_log_extended>on</tls_log_extended>
				<enable_pcap_log>off</enable_pcap_log>
				<enable_file_store>off</enable_file_store>
				<enable_eve_log>off</enable_eve_log>
				<runmode>autofp</runmode>
				<max_pending_packets>1024</max_pending_packets>
				<inspect_recursion_limit>3000</inspect_recursion_limit>
				<intf_snaplen>1518</intf_snaplen>
				<detect_eng_profile>medium</detect_eng_profile>
				<mpm_algo>auto</mpm_algo>
				<sgh_mpm_context>auto</sgh_mpm_context>
				<blockoffenders>lanips</blockoffenders>
				<ips_mode>ips_mode_legacy</ips_mode>
				<blockoffenderskill>on</blockoffenderskill>
				<block_drops_only>off</block_drops_only>
				<blockoffendersip>both</blockoffendersip>
				<passlistname>default</passlistname>
				<homelistname>default</homelistname>
				<externallistname>default</externallistname>
				<suppresslistname>default</suppresslistname>
				<alertsystemlog>off</alertsystemlog>
				<alertsystemlog_facility>local1</alertsystemlog_facility>
				<alertsystemlog_priority>notice</alertsystemlog_priority>
				<eve_output_type>regular</eve_output_type>
				<eve_systemlog_facility>local1</eve_systemlog_facility>
				<eve_systemlog_priority>notice</eve_systemlog_priority>
				<eve_log_alerts>on</eve_log_alerts>
				<eve_log_alerts_payload>on</eve_log_alerts_payload>
				<eve_log_alerts_packet>on</eve_log_alerts_packet>
				<eve_log_alerts_metadata>on</eve_log_alerts_metadata>
				<eve_log_alerts_http>on</eve_log_alerts_http>
				<eve_log_alerts_xff>off</eve_log_alerts_xff>
				<eve_log_alerts_xff_mode>extra-data</eve_log_alerts_xff_mode>
				<eve_log_alerts_xff_deployment>reverse</eve_log_alerts_xff_deployment>
				<eve_log_alerts_xff_header>X-Forwarded-For</eve_log_alerts_xff_header>
				<eve_log_anomaly>off</eve_log_anomaly>
				<eve_log_anomaly_type_decode>off</eve_log_anomaly_type_decode>
				<eve_log_anomaly_type_stream>off</eve_log_anomaly_type_stream>
				<eve_log_anomaly_type_applayer>on</eve_log_anomaly_type_applayer>
				<eve_log_anomaly_packethdr>off</eve_log_anomaly_packethdr>
				<eve_log_http>on</eve_log_http>
				<eve_log_dns>on</eve_log_dns>
				<eve_log_tls>on</eve_log_tls>
				<eve_log_dhcp>on</eve_log_dhcp>
				<eve_log_nfs>on</eve_log_nfs>
				<eve_log_smb>on</eve_log_smb>
				<eve_log_krb5>on</eve_log_krb5>
				<eve_log_ikev2>on</eve_log_ikev2>
				<eve_log_tftp>on</eve_log_tftp>
				<eve_log_rdp>off</eve_log_rdp>
				<eve_log_sip>off</eve_log_sip>
				<eve_log_files>on</eve_log_files>
				<eve_log_ssh>on</eve_log_ssh>
				<eve_log_smtp>on</eve_log_smtp>
				<eve_log_stats>off</eve_log_stats>
				<eve_log_flow>off</eve_log_flow>
				<eve_log_netflow>off</eve_log_netflow>
				<eve_log_snmp>on</eve_log_snmp>
				<eve_log_stats_totals>on</eve_log_stats_totals>
				<eve_log_stats_deltas>off</eve_log_stats_deltas>
				<eve_log_stats_threads>off</eve_log_stats_threads>
				<eve_log_http_extended>on</eve_log_http_extended>
				<eve_log_tls_extended>on</eve_log_tls_extended>
				<eve_log_dhcp_extended>off</eve_log_dhcp_extended>
				<eve_log_smtp_extended>on</eve_log_smtp_extended>
				<eve_log_http_extended_headers>accept, accept-charset, accept-datetime, accept-encoding, accept-language, accept-range, age, allow, authorization, cache-control, connection, content-encoding, content-language, content-length, content-location, content-md5, content-range, content-type, cookie, date, dnt, etags, from, last-modified, link, location, max-forwards, origin, pragma, proxy-authenticate, proxy-authorization, range, referrer, refresh, retry-after, server, set-cookie, te, trailer, transfer-encoding, upgrade, vary, via, warning, www-authenticate, x-authenticated-user, x-flash-version, x-forwarded-proto, x-requested-with</eve_log_http_extended_headers>
				<eve_log_smtp_extended_fields>bcc, received, reply-to, x-mailer, x-originating-ip</eve_log_smtp_extended_fields>
				<eve_log_tls_extended_fields></eve_log_tls_extended_fields>
				<eve_log_files_magic>off</eve_log_files_magic>
				<eve_log_files_hash>none</eve_log_files_hash>
				<eve_log_drop>on</eve_log_drop>
				<delayed_detect>off</delayed_detect>
				<intf_promisc_mode>on</intf_promisc_mode>
				<eve_redis_server>127.0.0.1</eve_redis_server>
				<eve_redis_port>6379</eve_redis_port>
				<eve_redis_mode>list</eve_redis_mode>
				<eve_redis_key>suricata</eve_redis_key>
				<ip_max_frags>65535</ip_max_frags>
				<ip_frag_timeout>60</ip_frag_timeout>
				<frag_memcap>33554432</frag_memcap>
				<ip_max_trackers>65535</ip_max_trackers>
				<frag_hash_size>65536</frag_hash_size>
				<flow_memcap>33554432</flow_memcap>
				<flow_prealloc>10000</flow_prealloc>
				<flow_hash_size>65536</flow_hash_size>
				<flow_emerg_recovery>30</flow_emerg_recovery>
				<flow_prune>5</flow_prune>
				<flow_tcp_new_timeout>60</flow_tcp_new_timeout>
				<flow_tcp_established_timeout>3600</flow_tcp_established_timeout>
				<flow_tcp_closed_timeout>120</flow_tcp_closed_timeout>
				<flow_tcp_emerg_new_timeout>10</flow_tcp_emerg_new_timeout>
				<flow_tcp_emerg_established_timeout>300</flow_tcp_emerg_established_timeout>
				<flow_tcp_emerg_closed_timeout>20</flow_tcp_emerg_closed_timeout>
				<flow_udp_new_timeout>30</flow_udp_new_timeout>
				<flow_udp_established_timeout>300</flow_udp_established_timeout>
				<flow_udp_emerg_new_timeout>10</flow_udp_emerg_new_timeout>
				<flow_udp_emerg_established_timeout>100</flow_udp_emerg_established_timeout>
				<flow_icmp_new_timeout>30</flow_icmp_new_timeout>
				<flow_icmp_established_timeout>300</flow_icmp_established_timeout>
				<flow_icmp_emerg_new_timeout>10</flow_icmp_emerg_new_timeout>
				<flow_icmp_emerg_established_timeout>100</flow_icmp_emerg_established_timeout>
				<stream_memcap>67108864</stream_memcap>
				<stream_prealloc_sessions>32768</stream_prealloc_sessions>
				<reassembly_memcap>67108864</reassembly_memcap>
				<reassembly_depth>1048576</reassembly_depth>
				<reassembly_to_server_chunk>2560</reassembly_to_server_chunk>
				<reassembly_to_client_chunk>2560</reassembly_to_client_chunk>
				<max_synack_queued>5</max_synack_queued>
				<enable_midstream_sessions>off</enable_midstream_sessions>
				<enable_async_sessions>off</enable_async_sessions>
				<asn1_max_frames>256</asn1_max_frames>
				<dns_global_memcap>16777216</dns_global_memcap>
				<dns_state_memcap>524288</dns_state_memcap>
				<dns_request_flood_limit>500</dns_request_flood_limit>
				<http_parser_memcap>67108864</http_parser_memcap>
				<dns_parser_udp>yes</dns_parser_udp>
				<dns_parser_tcp>yes</dns_parser_tcp>
				<dns_parser_udp_ports>53</dns_parser_udp_ports>
				<dns_parser_tcp_ports>53</dns_parser_tcp_ports>
				<http_parser>yes</http_parser>
				<tls_parser>yes</tls_parser>
				<tls_detect_ports>443</tls_detect_ports>
				<tls_encrypt_handling>default</tls_encrypt_handling>
				<tls_ja3_fingerprint>off</tls_ja3_fingerprint>
				<smtp_parser>yes</smtp_parser>
				<smtp_parser_decode_mime>off</smtp_parser_decode_mime>
				<smtp_parser_decode_base64>on</smtp_parser_decode_base64>
				<smtp_parser_decode_quoted_printable>on</smtp_parser_decode_quoted_printable>
				<smtp_parser_extract_urls>on</smtp_parser_extract_urls>
				<smtp_parser_compute_body_md5>off</smtp_parser_compute_body_md5>
				<imap_parser>detection-only</imap_parser>
				<ssh_parser>yes</ssh_parser>
				<ftp_parser>yes</ftp_parser>
				<dcerpc_parser>yes</dcerpc_parser>
				<smb_parser>yes</smb_parser>
				<msn_parser>detection-only</msn_parser>
				<krb5_parser>yes</krb5_parser>
				<ikev2_parser>yes</ikev2_parser>
				<nfs_parser>yes</nfs_parser>
				<tftp_parser>yes</tftp_parser>
				<ntp_parser>yes</ntp_parser>
				<dhcp_parser>yes</dhcp_parser>
				<enable_iprep>off</enable_iprep>
				<host_memcap>33554432</host_memcap>
				<host_hash_size>4096</host_hash_size>
				<host_prealloc>1000</host_prealloc>
				<host_os_policy>
					<item>
						<name>default</name>
						<bind_to>all</bind_to>
						<policy>bsd</policy>
					</item>
				</host_os_policy>
				<libhtp_policy>
					<item>
						<name>default</name>
						<bind_to>all</bind_to>
						<personality>IDS</personality>
						<request-body-limit>4096</request-body-limit>
						<response-body-limit>4096</response-body-limit>
						<double-decode-path>no</double-decode-path>
						<double-decode-query>no</double-decode-query>
						<uri-include-all>no</uri-include-all>
						<meta-field-limit>18432</meta-field-limit>
					</item>
				</libhtp_policy>
				<rulesets>app-layer-events.rules||decoder-events.rules||dnp3-events.rules||dns-events.rules||files.rules||http-events.rules||ipsec-events.rules||kerberos-events.rules||modbus-events.rules||nfs-events.rules||ntp-events.rules||smb-events.rules||smtp-events.rules||stream-events.rules||tls-events.rules||GPLv2_community.rules||emerging-3coresec.rules||emerging-activex.rules||emerging-adware_pup.rules||emerging-attack_response.rules||emerging-botcc.portgrouped.rules||emerging-botcc.rules||emerging-chat.rules||emerging-ciarmy.rules||emerging-coinminer.rules||emerging-compromised.rules||emerging-current_events.rules||emerging-deleted.rules||emerging-dns.rules||emerging-dos.rules||emerging-drop.rules||emerging-dshield.rules||emerging-exploit.rules||emerging-exploit_kit.rules||emerging-ftp.rules||emerging-games.rules||emerging-hunting.rules||emerging-icmp.rules||emerging-icmp_info.rules||emerging-imap.rules||emerging-inappropriate.rules||emerging-info.rules||emerging-ja3.rules||emerging-malware.rules||emerging-misc.rules||emerging-mobile_malware.rules||emerging-netbios.rules||emerging-p2p.rules||emerging-phishing.rules||emerging-policy.rules||emerging-pop3.rules||emerging-rpc.rules||emerging-scada.rules||emerging-scan.rules||emerging-shellcode.rules||emerging-smtp.rules||emerging-snmp.rules||emerging-sql.rules||emerging-telnet.rules||emerging-tftp.rules||emerging-tor.rules||emerging-user_agents.rules||emerging-voip.rules||emerging-web_client.rules||emerging-web_server.rules||emerging-web_specific_apps.rules||emerging-worm.rules</rulesets>
				<ips_policy_enable>off</ips_policy_enable>
				<autoflowbitrules>on</autoflowbitrules>
				<file_store_logdir>L3Zhci9sb2cvc3VyaWNhdGEvc3VyaWNhdGFfdnRuZXQxNjYwMy9maWxlc3RvcmU=</file_store_logdir>
			</rule>
			<rule>
				<interface>opt1</interface>
				<enable>mgmtids</enable>
				<uuid>6603</uuid>
				<descr><![CDATA[MGMT]]></descr>
				<max_pcap_log_size>32</max_pcap_log_size>
				<max_pcap_log_files>1000</max_pcap_log_files>
				<enable_stats_collection>off</enable_stats_collection>
				<enable_stats_log>off</enable_stats_log>
				<append_stats_log>off</append_stats_log>
				<stats_upd_interval>10</stats_upd_interval>
				<enable_telegraf_stats>off</enable_telegraf_stats>
				<enable_http_log>on</enable_http_log>
				<append_http_log>on</append_http_log>
				<enable_tls_log>off</enable_tls_log>
				<enable_tls_store>off</enable_tls_store>
				<http_log_extended>on</http_log_extended>
				<tls_log_extended>on</tls_log_extended>
				<enable_pcap_log>off</enable_pcap_log>
				<enable_file_store>off</enable_file_store>
				<enable_eve_log>off</enable_eve_log>
				<runmode>autofp</runmode>
				<max_pending_packets>1024</max_pending_packets>
				<inspect_recursion_limit>3000</inspect_recursion_limit>
				<intf_snaplen>1518</intf_snaplen>
				<detect_eng_profile>medium</detect_eng_profile>
				<mpm_algo>auto</mpm_algo>
				<sgh_mpm_context>auto</sgh_mpm_context>
				<blockoffenders>mgmtips</blockoffenders>
				<ips_mode>ips_mode_legacy</ips_mode>
				<blockoffenderskill>on</blockoffenderskill>
				<block_drops_only>off</block_drops_only>
				<blockoffendersip>both</blockoffendersip>
				<passlistname>default</passlistname>
				<homelistname>default</homelistname>
				<externallistname>default</externallistname>
				<suppresslistname>default</suppresslistname>
				<alertsystemlog>off</alertsystemlog>
				<alertsystemlog_facility>local1</alertsystemlog_facility>
				<alertsystemlog_priority>notice</alertsystemlog_priority>
				<eve_output_type>regular</eve_output_type>
				<eve_systemlog_facility>local1</eve_systemlog_facility>
				<eve_systemlog_priority>notice</eve_systemlog_priority>
				<eve_log_alerts>on</eve_log_alerts>
				<eve_log_alerts_payload>on</eve_log_alerts_payload>
				<eve_log_alerts_packet>on</eve_log_alerts_packet>
				<eve_log_alerts_metadata>on</eve_log_alerts_metadata>
				<eve_log_alerts_http>on</eve_log_alerts_http>
				<eve_log_alerts_xff>off</eve_log_alerts_xff>
				<eve_log_alerts_xff_mode>extra-data</eve_log_alerts_xff_mode>
				<eve_log_alerts_xff_deployment>reverse</eve_log_alerts_xff_deployment>
				<eve_log_alerts_xff_header>X-Forwarded-For</eve_log_alerts_xff_header>
				<eve_log_anomaly>off</eve_log_anomaly>
				<eve_log_anomaly_type_decode>off</eve_log_anomaly_type_decode>
				<eve_log_anomaly_type_stream>off</eve_log_anomaly_type_stream>
				<eve_log_anomaly_type_applayer>on</eve_log_anomaly_type_applayer>
				<eve_log_anomaly_packethdr>off</eve_log_anomaly_packethdr>
				<eve_log_http>on</eve_log_http>
				<eve_log_dns>on</eve_log_dns>
				<eve_log_tls>on</eve_log_tls>
				<eve_log_dhcp>on</eve_log_dhcp>
				<eve_log_nfs>on</eve_log_nfs>
				<eve_log_smb>on</eve_log_smb>
				<eve_log_krb5>on</eve_log_krb5>
				<eve_log_ikev2>on</eve_log_ikev2>
				<eve_log_tftp>on</eve_log_tftp>
				<eve_log_rdp>off</eve_log_rdp>
				<eve_log_sip>off</eve_log_sip>
				<eve_log_files>on</eve_log_files>
				<eve_log_ssh>on</eve_log_ssh>
				<eve_log_smtp>on</eve_log_smtp>
				<eve_log_stats>off</eve_log_stats>
				<eve_log_flow>off</eve_log_flow>
				<eve_log_netflow>off</eve_log_netflow>
				<eve_log_snmp>on</eve_log_snmp>
				<eve_log_stats_totals>on</eve_log_stats_totals>
				<eve_log_stats_deltas>off</eve_log_stats_deltas>
				<eve_log_stats_threads>off</eve_log_stats_threads>
				<eve_log_http_extended>on</eve_log_http_extended>
				<eve_log_tls_extended>on</eve_log_tls_extended>
				<eve_log_dhcp_extended>off</eve_log_dhcp_extended>
				<eve_log_smtp_extended>on</eve_log_smtp_extended>
				<eve_log_http_extended_headers>accept, accept-charset, accept-datetime, accept-encoding, accept-language, accept-range, age, allow, authorization, cache-control, connection, content-encoding, content-language, content-length, content-location, content-md5, content-range, content-type, cookie, date, dnt, etags, from, last-modified, link, location, max-forwards, origin, pragma, proxy-authenticate, proxy-authorization, range, referrer, refresh, retry-after, server, set-cookie, te, trailer, transfer-encoding, upgrade, vary, via, warning, www-authenticate, x-authenticated-user, x-flash-version, x-forwarded-proto, x-requested-with</eve_log_http_extended_headers>
				<eve_log_smtp_extended_fields>bcc, received, reply-to, x-mailer, x-originating-ip</eve_log_smtp_extended_fields>
				<eve_log_tls_extended_fields></eve_log_tls_extended_fields>
				<eve_log_files_magic>off</eve_log_files_magic>
				<eve_log_files_hash>none</eve_log_files_hash>
				<eve_log_drop>on</eve_log_drop>
				<delayed_detect>off</delayed_detect>
				<intf_promisc_mode>on</intf_promisc_mode>
				<eve_redis_server>127.0.0.1</eve_redis_server>
				<eve_redis_port>6379</eve_redis_port>
				<eve_redis_mode>list</eve_redis_mode>
				<eve_redis_key>suricata</eve_redis_key>
				<ip_max_frags>65535</ip_max_frags>
				<ip_frag_timeout>60</ip_frag_timeout>
				<frag_memcap>33554432</frag_memcap>
				<ip_max_trackers>65535</ip_max_trackers>
				<frag_hash_size>65536</frag_hash_size>
				<flow_memcap>33554432</flow_memcap>
				<flow_prealloc>10000</flow_prealloc>
				<flow_hash_size>65536</flow_hash_size>
				<flow_emerg_recovery>30</flow_emerg_recovery>
				<flow_prune>5</flow_prune>
				<flow_tcp_new_timeout>60</flow_tcp_new_timeout>
				<flow_tcp_established_timeout>3600</flow_tcp_established_timeout>
				<flow_tcp_closed_timeout>120</flow_tcp_closed_timeout>
				<flow_tcp_emerg_new_timeout>10</flow_tcp_emerg_new_timeout>
				<flow_tcp_emerg_established_timeout>300</flow_tcp_emerg_established_timeout>
				<flow_tcp_emerg_closed_timeout>20</flow_tcp_emerg_closed_timeout>
				<flow_udp_new_timeout>30</flow_udp_new_timeout>
				<flow_udp_established_timeout>300</flow_udp_established_timeout>
				<flow_udp_emerg_new_timeout>10</flow_udp_emerg_new_timeout>
				<flow_udp_emerg_established_timeout>100</flow_udp_emerg_established_timeout>
				<flow_icmp_new_timeout>30</flow_icmp_new_timeout>
				<flow_icmp_established_timeout>300</flow_icmp_established_timeout>
				<flow_icmp_emerg_new_timeout>10</flow_icmp_emerg_new_timeout>
				<flow_icmp_emerg_established_timeout>100</flow_icmp_emerg_established_timeout>
				<stream_memcap>67108864</stream_memcap>
				<stream_prealloc_sessions>32768</stream_prealloc_sessions>
				<reassembly_memcap>67108864</reassembly_memcap>
				<reassembly_depth>1048576</reassembly_depth>
				<reassembly_to_server_chunk>2560</reassembly_to_server_chunk>
				<reassembly_to_client_chunk>2560</reassembly_to_client_chunk>
				<max_synack_queued>5</max_synack_queued>
				<enable_midstream_sessions>off</enable_midstream_sessions>
				<enable_async_sessions>off</enable_async_sessions>
				<asn1_max_frames>256</asn1_max_frames>
				<dns_global_memcap>16777216</dns_global_memcap>
				<dns_state_memcap>524288</dns_state_memcap>
				<dns_request_flood_limit>500</dns_request_flood_limit>
				<http_parser_memcap>67108864</http_parser_memcap>
				<dns_parser_udp>yes</dns_parser_udp>
				<dns_parser_tcp>yes</dns_parser_tcp>
				<dns_parser_udp_ports>53</dns_parser_udp_ports>
				<dns_parser_tcp_ports>53</dns_parser_tcp_ports>
				<http_parser>yes</http_parser>
				<tls_parser>yes</tls_parser>
				<tls_detect_ports>443</tls_detect_ports>
				<tls_encrypt_handling>default</tls_encrypt_handling>
				<tls_ja3_fingerprint>off</tls_ja3_fingerprint>
				<smtp_parser>yes</smtp_parser>
				<smtp_parser_decode_mime>off</smtp_parser_decode_mime>
				<smtp_parser_decode_base64>on</smtp_parser_decode_base64>
				<smtp_parser_decode_quoted_printable>on</smtp_parser_decode_quoted_printable>
				<smtp_parser_extract_urls>on</smtp_parser_extract_urls>
				<smtp_parser_compute_body_md5>off</smtp_parser_compute_body_md5>
				<imap_parser>detection-only</imap_parser>
				<ssh_parser>yes</ssh_parser>
				<ftp_parser>yes</ftp_parser>
				<dcerpc_parser>yes</dcerpc_parser>
				<smb_parser>yes</smb_parser>
				<msn_parser>detection-only</msn_parser>
				<krb5_parser>yes</krb5_parser>
				<ikev2_parser>yes</ikev2_parser>
				<nfs_parser>yes</nfs_parser>
				<tftp_parser>yes</tftp_parser>
				<ntp_parser>yes</ntp_parser>
				<dhcp_parser>yes</dhcp_parser>
				<enable_iprep>off</enable_iprep>
				<host_memcap>33554432</host_memcap>
				<host_hash_size>4096</host_hash_size>
				<host_prealloc>1000</host_prealloc>
				<host_os_policy>
					<item>
						<name>default</name>
						<bind_to>all</bind_to>
						<policy>bsd</policy>
					</item>
				</host_os_policy>
				<libhtp_policy>
					<item>
						<name>default</name>
						<bind_to>all</bind_to>
						<personality>IDS</personality>
						<request-body-limit>4096</request-body-limit>
						<response-body-limit>4096</response-body-limit>
						<double-decode-path>no</double-decode-path>
						<double-decode-query>no</double-decode-query>
						<uri-include-all>no</uri-include-all>
						<meta-field-limit>18432</meta-field-limit>
					</item>
				</libhtp_policy>
				<rulesets>app-layer-events.rules||decoder-events.rules||dnp3-events.rules||dns-events.rules||files.rules||http-events.rules||ipsec-events.rules||kerberos-events.rules||modbus-events.rules||nfs-events.rules||ntp-events.rules||smb-events.rules||smtp-events.rules||stream-events.rules||tls-events.rules||GPLv2_community.rules||emerging-3coresec.rules||emerging-activex.rules||emerging-adware_pup.rules||emerging-attack_response.rules||emerging-botcc.portgrouped.rules||emerging-botcc.rules||emerging-chat.rules||emerging-ciarmy.rules||emerging-coinminer.rules||emerging-compromised.rules||emerging-current_events.rules||emerging-deleted.rules||emerging-dns.rules||emerging-dos.rules||emerging-drop.rules||emerging-dshield.rules||emerging-exploit.rules||emerging-exploit_kit.rules||emerging-ftp.rules||emerging-games.rules||emerging-hunting.rules||emerging-icmp.rules||emerging-icmp_info.rules||emerging-imap.rules||emerging-inappropriate.rules||emerging-info.rules||emerging-ja3.rules||emerging-malware.rules||emerging-misc.rules||emerging-mobile_malware.rules||emerging-netbios.rules||emerging-p2p.rules||emerging-phishing.rules||emerging-policy.rules||emerging-pop3.rules||emerging-rpc.rules||emerging-scada.rules||emerging-scan.rules||emerging-shellcode.rules||emerging-smtp.rules||emerging-snmp.rules||emerging-sql.rules||emerging-telnet.rules||emerging-tftp.rules||emerging-tor.rules||emerging-user_agents.rules||emerging-voip.rules||emerging-web_client.rules||emerging-web_server.rules||emerging-web_specific_apps.rules||emerging-worm.rules</rulesets>
				<ips_policy_enable>off</ips_policy_enable>
				<autoflowbitrules>on</autoflowbitrules>
			</rule>
		</suricata>
		<menu>
			<name>pfBlockerNG</name>
			<section>Firewall</section>
			<url>/pfblockerng/pfblockerng_general.php</url>
		</menu>
		<menu>
			<name>Suricata</name>
			<tooltiptext>Configure Suricata settings</tooltiptext>
			<section>Services</section>
			<url>/suricata/suricata_interfaces.php</url>
		</menu>
		<service>
			<name>suricata</name>
			<rcfile>suricata.sh</rcfile>
			<executable>suricata</executable>
			<description><![CDATA[Suricata IDS/IPS Daemon]]></description>
		</service>
		<service>
			<name>pfb_dnsbl</name>
			<rcfile>pfb_dnsbl.sh</rcfile>
			<executable>lighttpd_pfb</executable>
			<description><![CDATA[pfBlockerNG DNSBL service]]></description>
		</service>
		<service>
			<name>pfb_filter</name>
			<rcfile>pfb_filter.sh</rcfile>
			<executable>php_pfb</executable>
			<description><![CDATA[pfBlockerNG firewall filter service]]></description>
		</service>
		<pfblockerng>
			<config>
				<enable_cb>on</enable_cb>
				<pfb_keep>on</pfb_keep>
				<pfb_reuse></pfb_reuse>
			</config>
		</pfblockerng>
		<pfblockerngipsettings>
			<config>
				<enable_dup>on</enable_dup>
				<suppression>on</suppression>
				<inbound_interface>wan</inbound_interface>
				<inbound_deny_action>block</inbound_deny_action>
				<outbound_interface>lan,opt1</outbound_interface>
				<outbound_deny_action>reject</outbound_deny_action>
				<pass_order>order_0</pass_order>
			</config>
		</pfblockerngipsettings>
		<pfblockerngdnsblsettings>
			<config>
				<pfb_dnsvip>10.10.10.1</pfb_dnsvip>
				<pfb_dnsport>8081</pfb_dnsport>
				<pfb_dnsport_ssl>8443</pfb_dnsport_ssl>
				<pfb_dnsblv6></pfb_dnsblv6>
				<pfb_dnsbl>on</pfb_dnsbl>
				<suppression>czMuYW1hem9uYXdzLmNvbQ0KczMtMS5hbWF6b25hd3MuY29tICMgQ05BTUUgZm9yIChzMy5hbWF6b25hd3MuY29tKQ0KLmdpdGh1Yi5jb20NCi5naXRodWJ1c2VyY29udGVudC5jb20gDQp
naXRodWIubWFwLmZhc3RseS5uZXQgIyBDTkFNRSBmb3IgKHJhdy5naXRodWJ1c2VyY29udGVudC5jb20pDQouZ2l0bGFiLmNvbQ0KLmFwcGxlLmNvbSANCi5zb3VyY2Vmb3JnZS5uZXQNCi5mbHMtbmEuYW1hem9uLmNvbSAjIGFsZXhhDQouY29udHJ
vbC5rb2NoYXZhLmNvbSAjIGFsZXhhIDINCi5kZXZpY2UtbWV0cmljcy11cy0yLmFtYXpvbi5jb20gIyBhbGV4YSAzDQouYW1hem9uLWFkc3lzdGVtLmNvbSAjIGFtYXpvbiBhcHAgYWRzDQoucHgubW9hdGFkcy5jb20gIyBhbWF6b24gYXBwIDINCi5
3aWxkY2FyZC5tb2F0YWRzLmNvbS5lZGdla2V5Lm5ldCAjIENOQU1FIGZvciAocHgubW9hdGFkcy5jb20pDQouZTEzMTM2LmcuYWthbWFpZWRnZS5uZXQgIyBDTkFNRSBmb3IgKHB4Lm1vYXRhZHMuY29tKQ0KLnNlY3VyZS1nbC5pbXJ3b3JsZHdpZGU
uY29tICMgYW1hem9uIGFwcCAzDQoucGl4ZWwuYWRzYWZlcHJvdGVjdGVkLmNvbSAjIGFtYXpvbiBhcHAgNA0KLmFueWNhc3QucGl4ZWwuYWRzYWZlcHJvdGVjdGVkLmNvbSAjIENOQU1FIGZvciAocGl4ZWwuYWRzYWZlcHJvdGVjdGVkLmNvbSkNCi5
icy5zZXJ2aW5nLXN5cy5jb20gIyBhbWF6b24gYXBwIDUNCi5icy5leWVibGFzdGVyLmFrYWRucy5uZXQgIyBDTkFNRSBmb3IgKGJzLnNlcnZpbmctc3lzLmNvbSkNCi5ic2xhLmV5ZWJsYXN0ZXIuYWthZG5zLm5ldCAjIENOQU1FIGZvciAoYnMuc2V
ydmluZy1zeXMuY29tKQ0KLmFkc2FmZXByb3RlY3RlZC5jb20gIyBhbWF6b24gYXBwIDYNCi5hbnljYXN0LnN0YXRpYy5hZHNhZmVwcm90ZWN0ZWQuY29tICMgQ05BTUUgZm9yIChzdGF0aWMuYWRzYWZlcHJvdGVjdGVkLmNvbSkNCmdvb2dsZS5jb20
NCnd3dy5nb29nbGUuY29tDQp5b3V0dWJlLmNvbQ0Kd3d3LnlvdXR1YmUuY29tDQp5b3V0dWJlLXVpLmwuZ29vZ2xlLmNvbSAjIENOQU1FIGZvciAoeW91dHViZS5jb20pDQpzdGFja292ZXJmbG93LmNvbQ0Kd3d3LnN0YWNrb3ZlcmZsb3cuY29tDQp
kcm9wYm94LmNvbQ0Kd3d3LmRyb3Bib3guY29tDQp3d3cuZHJvcGJveC1kbnMuY29tICMgQ05BTUUgZm9yIChkcm9wYm94LmNvbSkNCi5hZHNhZmVwcm90ZWN0ZWQuY29tDQpjb250cm9sLmtvY2hhdmEuY29tDQpzZWN1cmUtZ2wuaW1yd29ybGR3aWR
lLmNvbQ0KcGJzLnR3aW1nLmNvbSAjIHR3aXR0ZXIgaW1hZ2VzDQp3d3cucGJzLnR3aW1nLmNvbSAjIHR3aXR0ZXIgaW1hZ2VzDQpjczE5Ni53YWMuZWRnZWNhc3RjZG4ubmV0ICMgQ05BTUUgZm9yIChwYnMudHdpbWcuY29tKQ0KY3MyLXdhYy5hcHI
tODMxNS5lZGdlY2FzdGRucy5uZXQgIyBDTkFNRSBmb3IgKHBicy50d2ltZy5jb20pDQpjczItd2FjLXVzLjgzMTUuZWNkbnMubmV0ICMgQ05BTUUgZm9yIChwYnMudHdpbWcuY29tKQ0KY3M0NS53YWMuZWRnZWNhc3RjZG4ubmV0ICMgQ05BTUUgZm9
yIChwYnMudHdpbWcuY29tKQ==</suppression>
			</config>
		</pfblockerngdnsblsettings>
		<pfblockerngdnsbl>
			<config>
				<aliasname>ADs_Basic</aliasname>
				<description><![CDATA[ADs Basic - Collection of ADvertisement Domain Feeds.]]></description>
				<row>
					<format>auto</format>
					<state><![CDATA[Enabled]]></state>
					<url>https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts</url>
					<header>StevenBlack_ADs</header>
				</row>
				<action>unbound</action>
				<cron>EveryDay</cron>
				<logging>enabled</logging>
				<order>default</order>
				<dow>1</dow>
			</config>
		</pfblockerngdnsbl>
		<pfblockernglistsv4>
			<config>
				<aliasname>PRI1</aliasname>
				<description><![CDATA[PRI1 - Collection of Feeds from the most reputable blocklist providers. (Primary tier)]]></description>
				<row>
					<format>auto</format>
					<state><![CDATA[Enabled]]></state>
					<url>https://feodotracker.abuse.ch/downloads/ipblocklist_recommended.txt</url>
					<header>Abuse_Feodo_C2</header>
				</row>
				<row>
					<format>auto</format>
					<state><![CDATA[Enabled]]></state>
					<url>https://ransomwaretracker.abuse.ch/downloads/RW_IPBL.txt</url>
					<header>Abuse_IPBL</header>
				</row>
				<row>
					<format>auto</format>
					<state><![CDATA[Enabled]]></state>
					<url>https://sslbl.abuse.ch/blacklist/sslipblacklist.txt</url>
					<header>Abuse_SSLBL</header>
				</row>
				<row>
					<format>auto</format>
					<state><![CDATA[Enabled]]></state>
					<url>https://cinsarmy.com/list/ci-badguys.txt</url>
					<header>CINS_army</header>
				</row>
				<row>
					<format>auto</format>
					<state><![CDATA[Enabled]]></state>
					<url>https://rules.emergingthreats.net/fwrules/emerging-Block-IPs.txt</url>
					<header>ET_Block</header>
				</row>
				<row>
					<format>auto</format>
					<state><![CDATA[Enabled]]></state>
					<url>https://rules.emergingthreats.net/blockrules/compromised-ips.txt</url>
					<header>ET_Comp</header>
				</row>
				<row>
					<format>auto</format>
					<state><![CDATA[Enabled]]></state>
					<url>https://isc.sans.edu/block.txt</url>
					<header>ISC_Block</header>
				</row>
				<row>
					<format>auto</format>
					<state><![CDATA[Enabled]]></state>
					<url>https://www.spamhaus.org/drop/drop.txt</url>
					<header>Spamhaus_Drop</header>
				</row>
				<row>
					<format>auto</format>
					<state><![CDATA[Enabled]]></state>
					<url>https://www.spamhaus.org/drop/edrop.txt</url>
					<header>Spamhaus_eDrop</header>
				</row>
				<row>
					<format>auto</format>
					<state><![CDATA[Enabled]]></state>
					<url>https://talosintelligence.com/documents/ip-blacklist</url>
					<header>Talos_BL</header>
				</row>
				<action>Deny_Outbound</action>
				<cron>01hour</cron>
				<aliaslog>enabled</aliaslog>
				<dow>1</dow>
			</config>
		</pfblockernglistsv4>
		<pfblockerngsafesearch></pfblockerngsafesearch>
	</installedpackages>
	<virtualip>
		<vip>
			<interface>lo0</interface>
			<descr><![CDATA[pfB DNSBL - DO NOT EDIT]]></descr>
			<type>single</type>
			<subnet_bits>32</subnet_bits>
			<subnet>10.10.10.1</subnet>
			<mode>ipalias</mode>
		</vip>
	</virtualip>
	<ntpd>
		<gps>
			<type>Default</type>
		</gps>
	</ntpd>
</pfsense>
ENDOFFILE
}

createpfsenseconfigscript() {
#Bash heredoc is sensitive to indentation so this function uses no indentation while remainder of script uses 2 spaces
cat > configpf.sh <<"ENDOFFILE"
#!/bin/sh
#remove initial wizard, install updated packages, enforce password on console
rm /cf/conf/trigger_initial_wizard
if nc -zw1 netgate.com 443; then
  pkg install -y pfSense-pkg-suricata pfSense-pkg-pfBlockerNG-devel
fi
systemline=$(sed -n  '\|</system>|=' /conf/config.xml)
sed -i '' -e ''$systemline'i\
                <disableconsolemenu></disableconsolemenu>' /conf/config.xml
rm /conf/configpf.sh
halt -p
ENDOFFILE
}

createencodedpfsenseconfigentries() {
#Bash Heredoc is sensitive to indentation so this function uses no indentation while remainder of script uses 2 spaces
#create Management DNS access control view as a file so that it preserves indentation
#conf specified under view so that pfblocker works on Management network also. extra wildcard prevents it from being deleted during pfblocker disable as pfblocker will not recreate the include line under view during re-enable. the actual pfb_dnsbl.conf file is deleted during disable so little harm in leaving the include: line if pfblocker is disabled. 
cat > customoptions.txt <<ENDOFFILE
server:
access-control-view: $pfsensemgmtipaddress/$mgmtsubnet mgmtview

view:
  name: "mgmtview"
  include: /var/unbound/pfb_d*sbl.*conf
  local-zone: "$mgmtdomain" static
  local-data: "$pvehostname.$mgmtdomain 90 IN A $pvemgmtipaddress"
  local-data-ptr: "$pvemgmtipaddress $pvehostname.$mgmtdomain"
  local-data: "$pfsensehostname.$mgmtdomain 90 IN A $pfsensemgmtipaddress"
  local-data-ptr: "$pfsensemgmtipaddress $pfsensehostname.$mgmtdomain"
  local-data: "gitlab.$mgmtdomain 90 IN A $mgmtk3siprangestart"
  local-data-ptr: "$mgmtk3siprangestart gitlab.$mgmtdomain"
  local-data: "kas.$mgmtdomain 90 IN A $mgmtk3siprangestart"
  local-data-ptr: "$mgmtk3siprangestart kas.$mgmtdomain"
  local-data: "minio.$mgmtdomain 90 IN A $mgmtk3siprangestart"
  local-data-ptr: "$mgmtk3siprangestart minio.$mgmtdomain"
  local-data: "vault.$mgmtdomain 90 IN A $mgmtk3siprangestart"
  local-data-ptr: "$mgmtk3siprangestart vault.$mgmtdomain"
ENDOFFILE

#Base64 encode the options so that it can be stored in config.xml
encodedcustomoptions=$(base64 customoptions.txt)
#Transform variable so that it survives SED RegEXP
encodedcustomoptions2=$(echo $encodedcustomoptions)
sed -i  's/unboundcustomoptions/'"$encodedcustomoptions2"'/' config.xml

#Create SID Mgmt file to disable false positives in Suricata
cat > disablesidwan.txt <<ENDOFFILE
1:2210000-1:2210060
1:2220036
1:2230003
1:2230010
1:2260000-1:2260003
ENDOFFILE

#Base64 encode the options so that it can be stored in config.xml
encodedcustomoptions3=$(base64 disablesidwan.txt)
#Transform variable so that it survives SED RegEXP
encodedcustomoptions4=$(echo $encodedcustomoptions3)
sed -i  's/suricatadisablesidwan/'"$encodedcustomoptions4"'/' config.xml
}

modifypfsenseconfig() {
  echo "Modifying pfSense configuration..." >&3

  #copy iso to local-lvm
  sudo mkdir temppvebase/var/lib/tempiso
  sudo cp "$latestpfsiso" temppvebase/var/lib/tempiso

  #Transform idsips variables
  if [ "$enablewanids" = "yes" ]; then
    wanidsonoff=on
  fi

  if [ "$enablewanids" = "no" ]; then
    wanidsonoff=off
  fi

  if [ "$enablelanids" = "yes" ]; then
    lanidsonoff=on
  fi

  if [ "$enablelanids" = "no" ]; then
    lanidsonoff=off
  fi

  if [ "$enablewanips" = "yes" ]; then
    wanipsonoff=on
  fi

  if [ "$enablewanips" = "no" ]; then
    wanipsonoff=off
  fi

  if [ "$enablelanips" = "yes" ]; then
    lanipsonoff=on
  fi

  if [ "$enablelanips" = "no" ]; then
    lanipsonoff=off
  fi

  if [ "$enablemgmtids" = "yes" ]; then
    mgmtidsonoff=on
  fi

  if [ "$enablemgmtids" = "no" ]; then
    mgmtidsonoff=off
  fi

  if [ "$enablemgmtips" = "yes" ]; then
    mgmtipsonoff=on
  fi

  if [ "$enablemgmtips" = "no" ]; then
    mgmtipsonoff=off
  fi

  #Edit interfacename for vlan
  if [ "$mgmtvlan" ]; then
    mgmtinterfacename="$mgmtinterfacename"."$mgmtvlan"
  fi

  if [ "$lanvlan" ]; then
    laninterfacename="$laninterfacename"."$lanvlan"
  fi

  #Apply variable defined config.xml
  sed -i ' s+undefinedtimezone+'$pvetimezone'+g' config.xml
  sed -i ' s/dnsserver1/'$externaldnsserver1'/g' config.xml
  sed -i ' s/dnsserver2/'$externaldnsserver2'/g' config.xml
  sed -i ' s/externaldnsserverhttps1/'$externaldnsserverhttps1'/g' config.xml
  sed -i ' s/externaldnsserverhttps2/'$externaldnsserverhttps2'/g' config.xml
  sed -i ' s/pfsensehostname/'$pfsensehostname'/g' config.xml
  sed -i ' s/mgmtdomain/'$mgmtdomain'/g' config.xml
  sed -i ' s/mgmtport/'$pfsensemgmtport'/g' config.xml
  sed -i ' s/landomain/'$landomain'/g' config.xml
  sed -i ' s/waninterfacename/'$waninterfacename'/g' config.xml
  sed -i ' s/wanipaddr/'$wanipaddress'/g' config.xml
  sed -i ' s/wan6ip/'$wanip6address'/g' config.xml
  sed -i ' s/wansubnet/'$wansubnet'/g' config.xml
  sed -i ' s/laninterfacename/'$laninterfacename'/g' config.xml
  sed -i ' s/lanipaddr/'$pfsenselanipaddress'/g' config.xml
  sed -i ' s/lan6ip/'$lanip6address'/g' config.xml
  sed -i ' s/lansubnet/'$lansubnet'/g' config.xml
  sed -i ' s/opt1interfacename/'$mgmtinterfacename'/g' config.xml
  sed -i ' s/opt1ipaddr/'$pfsensemgmtipaddress'/g' config.xml
  sed -i ' s/opt16ip/'$mgmtip6address'/g' config.xml
  sed -i ' s/opt1subnet/'$mgmtsubnet'/g' config.xml
  sed -i ' s/landhcpstart/'$landhcpstart'/g' config.xml
  sed -i ' s/landhcpend/'$landhcpend'/g' config.xml
  sed -i ' s/opt1dhcpstart/'$mgmtdhcpstart'/g' config.xml
  sed -i ' s/opt1dhcpend/'$mgmtdhcpend'/g' config.xml
  sed -i ' s/mgmtk3sip/'$mgmtk3siprangestart'/g' config.xml
  sed -i ' s/mgmtvlan/'$mgmtvlan'/g' config.xml
  sed -i ' s/lanvlan/'$lanvlan'/g' config.xml
  sed -i ' s/pvehostname/'$pvehostname'/g' config.xml
  sed -i ' s/pvemgmtipaddress/'$pvemgmtipaddress'/g' config.xml
  sed -i ' s/wanids/'$wanidsonoff'/g' config.xml
  sed -i ' s/lanids/'$lanidsonoff'/g' config.xml
  sed -i ' s/mgmtids/'$mgmtidsonoff'/g' config.xml
  sed -i ' s/wanips/'$wanipsonoff'/g' config.xml
  sed -i ' s/lanips/'$lanipsonoff'/g' config.xml
  sed -i ' s/mgmtips/'$mgmtipsonoff'/g' config.xml
  sed -i ' s/gitlabsshport/'$gitlabsshport'/g' config.xml
  sed -i ' s/lank3siprangestart/'$lank3siprangestart'/g' config.xml

  #Using time stamps to identify lan firewall rules will re-enable them if option lanaccessany is specified yes
  if [ "$lanaccessany" = "yes" ]; then
    lananyfirewallrule1_start_line=$(sed -n /'tracker>0100000109'/= config.xml)
    lananyfirewallrule1disableline=$(sed -n ''"$lananyfirewallrule1_start_line"',${/disabled></=}' config.xml | head -1)
    sed -i ''$lananyfirewallrule1disableline'd' config.xml
    lananyfirewallrule2_start_line=$(sed -n /'tracker>0100000110'/= config.xml)
    lananyfirewallrule2disableline=$(sed -n ''"$lananyfirewallrule2_start_line"',${/disabled></=}' config.xml | head -1)
    sed -i ''$lananyfirewallrule2disableline'd' config.xml
  fi

  #Using time stamps to identify managment firewall rules will re-enable them if option managementemailaccess is specified yes
  if [ "$managementemailaccess" = "yes" ]; then
    mgmtemailfirewallrule1_start_line=$(sed -n /'tracker>0100000112'/= config.xml)
    mgmtemailfirewallrule1disableline=$(sed -n ''"$mgmtemailfirewallrule1_start_line"',${/disabled></=}' config.xml | head -1)
    sed -i ''$mgmtemailfirewallrule1disableline'd' config.xml
    mgmtemailfirewallrule2_start_line=$(sed -n /'tracker>0100000113'/= config.xml)
    mgmtemailfirewallrule2disableline=$(sed -n ''"$mgmtemailfirewallrule2_start_line"',${/disabled></=}' config.xml | head -1)
    sed -i ''$mgmtemailfirewallrule2disableline'd' config.xml
  fi

  #Using time stamps to identify managment firewall rules will re-enable them if option managementwebaccess is specified yes
  if [ "$managementwebaccess" = "yes" ]; then 
    mgmtinternetfirewallrule1_start_line=$(sed -n /'tracker>0100000117'/= config.xml)
    mgmtinternetfirewallrule1disableline=$(sed -n ''"$mgmtinternetfirewallrule1_start_line"',${/disabled></=}' config.xml | head -1)
    sed -i ''$mgmtinternetfirewallrule1disableline'd' config.xml
    mgmtinternetfirewallrule2_start_line=$(sed -n /'tracker>0100000118'/= config.xml)
    mgmtinternetfirewallrule2disableline=$(sed -n ''"$mgmtinternetfirewallrule1_start_line"',${/disabled></=}' config.xml | head -1)
    sed -i ''$mgmtinternetfirewallrule2disableline'd' config.xml
  fi
  
    #Using time stamps to identify managment firewall rules will re-enable them if option proxmoxrepoaccess is specified yes
  if [ "$proxmoxrepoaccess" = "yes" ]; then 
    proxmoxinternetfirewallrule1_start_line=$(sed -n /'tracker>0100000119'/= config.xml)
    proxmoxinternetfirewallrule1disableline=$(sed -n ''"$proxmoxinternetfirewallrule1_start_line"',${/disabled></=}' config.xml | head -1)
    sed -i ''$proxmoxinternetfirewallrule1disableline'd' config.xml
    proxmoxinternetfirewallrule2_start_line=$(sed -n /'tracker>0100000120'/= config.xml)
    proxmoxinternetfirewallrule2disableline=$(sed -n ''"$proxmoxinternetfirewallrule1_start_line"',${/disabled></=}' config.xml | head -1)
    sed -i ''$proxmoxinternetfirewallrule2disableline'd' config.xml
  fi
  
  #Using time stamps to identify gitops firewall rules will re-enable them if option deploygitops is specified yes
  if [ "$deploygitops" = "yes" ]; then
    gitopsfirewallrule1_start_line=$(sed -n /'tracker>0100000122'/= config.xml)
    gitopsfirewallrule1disableline=$(sed -n ''"$gitopsfirewallrule1_start_line"',${/disabled></=}' config.xml | head -1)
    sed -i ''$gitopsfirewallrule1disableline'd' config.xml
    gitopsfirewallrule2_start_line=$(sed -n /'tracker>0100000123'/= config.xml)
    gitopsfirewallrule2disableline=$(sed -n ''"$gitopsfirewallrule2_start_line"',${/disabled></=}' config.xml | head -1)
    sed -i ''$gitopsfirewallrule2disableline'd' config.xml
  fi  

  #Using time stamps to identify managment firewall rules will re-enable them if option managementaccessany is specified yes
  if [ "$managementaccessany" = "yes" ]; then
    mgmtanyfirewallrule1_start_line=$(sed -n /'tracker>0100000125'/= config.xml)
    mgmtanyfirewallrule1disableline=$(sed -n ''"$mgmtanyfirewallrule1_start_line"',${/disabled></=}' config.xml | head -1)
    sed -i ''$mgmtanyfirewallrule1disableline'd' config.xml
  fi  

  #create pfconfig iso file
   mkdir pfconfig
   mv config.xml pfconfig/config.xml
   mv configpf.sh pfconfig/configpf.sh
   xorriso -as mkisofs -o pfconfig.iso -r -V 'pfconfig' pfconfig/
   sudo cp pfconfig.iso temppvebase/var/lib/tempiso
}

copygitopsfiles() {
  if [ "$deploygitops" = "yes" ]; then
    echo "Importing from gitlabcustomprojects directory..." >&3
    sudo cp -r gitlabcustomprojects temppvebase/root
    sudo cp $latestubuntuminimal temppvebase/var/lib/tempiso
  fi
}

modifypveinstaller() {
  echo "Modifying Proxmox configuration..." >&3
  #Modify variables so that quotation marks do not interfere with SED Regexp
  pvecountryquote="'$pvecountry'"
  pvetimezonequote="'$pvetimezone'"
  pvepasswordquote="'$pvepassword'"
  pvemailaddressquote="'$pvemailaddress'"
  pvehostnamequote="'$pvehostname'"
  mgmtdomainquote="'$mgmtdomain'"
  pfsensemgmtipaddressquote="'$pfsensemgmtipaddress'"
  pvemgmtipaddressquote="'$pvemgmtipaddress'"
  mgmtsubnetquote="'$mgmtsubnet'"
  mgmtinterfacecardquote="'$mgmtinterfacecard'"

  #Proxmox password
  if [ "$pvepassword" ]; then
    password_start_line=$(sed -n /'sub create_password_view {'/= proxinstall)
    password_end_line=$(($password_start_line+$password_length))
    #comment     set_next (undef,  sub {
    sed -i ''"$password_start_line"','"$password_end_line"' s/    set_next (undef,  sub {/#    set_next (undef,  sub {/g' proxinstall
    #comment close brackets
    declare -a password_closebrackets
    password_closebrackets=($(sed -n ''"$password_start_line"','"$password_end_line"'{/    });/=;}' proxinstall))
    password_firstclosebracket=${password_closebrackets[0]}
    sed -i ''"$password_firstclosebracket"' s/    });/#    });/g' proxinstall
    #set password
    sed -i ' s/	$password = $t1;/	$password = '"$pvepasswordquote"';/g' proxinstall
    sed -i 's/	my $t1 = $pwe1->get_text;/	my $t1 = '"$pvepasswordquote"';/g' proxinstall
    sed -i 's/	my $t2 = $pwe2->get_text;/	my $t2 = '"$pvepasswordquote"';/g' proxinstall
    #set mail
    sed -i ' s/my $mailto = .*/my $mailto = '"$pvemailaddressquote"';/g' proxinstall
    sed -i ' s/	$mailto = $t3;/	$mailto = '"$pvemailaddressquote"';/g' proxinstall
  fi

  #Automate Disk Selection to empty SDA ext4
  if [ "$pveautoformatharddrive" = "yes" ]; then
    #Findhdsel
    hdsel_start_line=$(sed -n /'sub create_hdsel_view {'/= proxinstall)
    hdsel_end_line=$(($hdsel_start_line+$hdsel_length))
    #comment set_next
    sed -i ''"$hdsel_start_line"','"$hdsel_end_line"' s/    set_next(undef, sub {/#    set_next(undef, sub {/g' proxinstall
    #comment secondclosebrackets
    declare -a hdsel_closebrackets
    hdsel_closebrackets=($(sed -n ''"$hdsel_start_line"','"$hdsel_end_line"'{/    });/=;}' proxinstall))
    hdsel_secondclosebracket=${hdsel_closebrackets[1]}
    sed -i ''"$hdsel_secondclosebracket"' s/    });/#    });/g' proxinstall
    #end Disk Selection
  fi

  #iphostname
  ip_start_line=$(sed -n /'sub create_ipconf_view {'/= proxinstall)
  ip_end_line=$(($ip_start_line+$ip_length))
  #comment     set_next (undef,  sub {
  sed -i ''"$ip_start_line"','"$ip_end_line"' s/    set_next(undef, sub {/#    set_next(undef, sub {/g' proxinstall
  #comment close brackets
  declare -a ip_closebrackets
  ip_closebrackets=($(sed -n ''"$ip_start_line"','"$ip_end_line"'{/    });/=;}' proxinstall))
  ip_firstclosebracket=${ip_closebrackets[0]}
  sed -i ''"$ip_firstclosebracket"' s/    });/#    });/g' proxinstall
  #Define network variable values
  sed -i 's/my $domain =.*/my $domain = '"$mgmtdomainquote"';/g' proxinstall
  sed -i 's/my $hostname =.*/my $hostname = '"$pvehostnamequote"';/g' proxinstall
  #Insert new network variables
  autorebootsecondsline=$(sed -n /'$autoreboot_seconds = 5;'/= proxinstall)
  ipaddressinsertline=$(($autorebootsecondsline+1))
  sed -i ''"$ipaddressinsertline"'i\my $gateway = '"$pfsensemgmtipaddressquote"';\' proxinstall
  sed -i ''"$ipaddressinsertline"'i\my $netmask = '"$mgmtsubnetquote"';\' proxinstall
  sed -i ''"$ipaddressinsertline"'i\my $ipaddress = '"$pvemgmtipaddressquote"';\' proxinstall
  sed -i ''"$ipaddressinsertline"'i\my $dnsserver = '"$pfsensemgmtipaddressquote"';\' proxinstall
  sed -i ''"$ipaddressinsertline"'i\my $mngmt_nic = '"$mgmtinterfacecardquote"';\' proxinstall
  #Define variables in config
  sed -i 's/    ipaddress => undef,/    ipaddress => $ipaddress,/g' proxinstall
  sed -i 's/    netmask => undef,/    netmask => $netmask,/g' proxinstall
  sed -i 's/    gateway => undef,/    gateway => $gateway,/g' proxinstall
  sed -i 's/    mngmt_nic => undef,/    mngmt_nic => $mngmt_nic,/g' proxinstall
  #create dnsserver config entry
  gatewayconfigline=$(sed -n /'    gateway => $gateway,'/= proxinstall)
  gatewayconfiginsertline=$(($gatewayconfigline+1))
  sed -i ''"$gatewayconfiginsertline"'i\    dnsserver => $dnsserver,\' proxinstall
  #Prevent Proxmox installer from writing to interfaces file
  sed -i 's+	write_config($ifaces, "$targetdir/etc/network/interfaces");+#	write_config($ifaces, "$targetdir/etc/network/interfaces");+g' proxinstall
  #Comment out FQDN check
  invalidfqdnfirstline=$(sed -n /'	if ($text && $text =~ m'/= proxinstall)
  invalidfqdnmidline=$(sed -n /'	    display_message("Hostname does not look like a fully qualified domain name.");'/= proxinstall)
  invalidfqdn_end_line2=$(($invalidfqdnmidline+$invalidfqdn_length))
  invalidfqdn_end_line=$(sed -n ''"$invalidfqdnmidline"','"$invalidfqdn_end_line2"'{/	}/=;}' proxinstall)
  sed -i -e ''"$invalidfqdnfirstline"','"$invalidfqdn_end_line"'s/^/# /' proxinstall

  #Automate EULA Agreement
  sed -i 's+    set_next("I a_gree", [\]&create_hdsel_view);+    create_hdsel_view();+' proxinstall

  #start country
  #find country_view
  country_start_line=$(sed -n /'sub create_country_view {'/= proxinstall)
  country_end_line=$(($country_start_line+$country_length))
  #comment fourthclosebrackets
  declare -a country_closebrackets
  country_closebrackets=($(sed -n ''"$country_start_line"','"$country_end_line"'{/    });/=;}' proxinstall))
  country_fourthclosebracket=${country_closebrackets[3]}
  sed -i ''"$country_fourthclosebracket"' s/    });/#    });/g' proxinstall
  #comment set_next
  sed -i ''"$country_start_line"','"$country_end_line"' s/    set_next (undef,  sub {/#    set_next (undef,  sub {/g' proxinstall
  #my $country; first change to = 'United States'
  declare -a country_lines
  country_lines=($(sed -n /'my $country;'/= proxinstall))
  country_first_line=${country_lines[0]}
  #modify both country variable
  sed -i ' s/my $country;/my $country = '"$pvecountryquote"';/g' proxinstall
  #timezone change to 'United States/New York'
  sed -i 's+my $timezone =.*+my $timezone = '"$pvetimezonequote"';+g' proxinstall
  #set country
  sed -i ' s/	    $country = $cc;/	    $country = '"$pvecountryquote"';/g' proxinstall
  declare -a country_hashcheck
  country_hashcheck=($(sed -n /'if (my $cc = $countryhash->{lc($text)}) {'/= proxinstall))
  country_hashcheck_second_line=${country_hashcheck[1]}
  sed -i ''"$country_hashcheck_second_line"' s/	if (my $cc = $countryhash->{lc($text)}) {/#	if (my $cc = $countryhash->{lc($text)}) {/g' proxinstall
  sed -i ''"$country_hashcheck_second_line"','"$country_end_line"' s/	    return;/#	    return;/g' proxinstall
  sed -i ''"$country_hashcheck_second_line"','"$country_end_line"' s/	} else {/#	} else {/g' proxinstall
  sed -i ''"$country_hashcheck_second_line"','"$country_end_line"' s/	    display_message("Please select a country first.");/#	    display_message("Please select a country first.");/g' proxinstall
  sed -i ''"$country_hashcheck_second_line"','"$country_end_line"' s/	    $w->grab_focus();/#	    $w->grab_focus();/g' proxinstall
  sed -i ''"$country_hashcheck_second_line"','"$country_end_line"' s/	}/#	}/g' proxinstall
  #end country


  #Automate summary agreement
  ack_start_line=$(sed -n /'sub create_ack_view {'/= proxinstall)
  ack_end_line=$(($ack_start_line+$ack_length))
  #comment     set_next (undef,  sub {
  sed -i ''"$ack_start_line"','"$ack_end_line"' s/    set_next(undef, sub {/#    set_next(undef, sub {/g' proxinstall
  #comment close brackets
  declare -a ack_closebrackets
  ack_closebrackets=($(sed -n ''"$ack_start_line"','"$ack_end_line"'{/    });/=;}' proxinstall))
  ack_secondclosebracket=${ack_closebrackets[1]}
  sed -i ''"$ack_secondclosebracket"' s/    });/#    });/g' proxinstall

  #copy custom files to iso
  sudo cp proxinstall temppveinstall/usr/bin/proxinstall
  #Set Proxmox to be a client of pfSense NTP server
  sudo sed -i ' s/#NTP=/NTP='"$pfsensemgmtipaddress"'/g' temppvebase/etc/systemd/timesyncd.conf

  if [ "$pveinstallerdisabledhcp" = "yes" ]; then
    #Remove DHCP request in Proxmox installer
    sudo sed -i ' s/dhclient -v/#dhclient -v/g' temppveinstall/usr/sbin/unconfigured.sh
    sudo sed -i ' s/echo -n "Attempting to get DHCP leases... "/#echo -n "Attempting to get DHCP leases... "/g' temppveinstall/usr/sbin/unconfigured.sh
    sudo sed -i ' s+kill $(pidof dhclient) 2+#kill $(pidof dhclient) 2+g' temppveinstall/usr/sbin/unconfigured.sh
  fi
  if [ "$pveinstallerdisablegrub" = "yes" ]; then
    #Set default and timeout in grub boot menu
    sudo sed -i '1i\default=0\' tempiso/boot/grub/grub.cfg
    sudo sed -i '2i\timeout=10\' tempiso/boot/grub/grub.cfg
    sudo sed -i '3i\timeout_style=countdown\' tempiso/boot/grub/grub.cfg
  fi
}

createpvestartupscript() {
#Bash heredoc is sensitive to indentation so this function uses no indentation while remainder of script uses 2 spaces
if [ -f tempvebase/etc/crontab ]; then
  echo "Modifying existing crontab"
else
  echo "Extracting and modifying crontab from package"
  cronpackage=$(ls tempiso/proxmox/packages/cron*.deb)
  dpkg-deb --extract $cronpackage tempcron
  sudo cp tempcron/etc/crontab temppvebase/etc/crontab
  sudo rm -r tempcron
fi

#create cron job to create vm's, move iso's, config pf, self delete
crontabjob1='@reboot root bash /etc/cron.d/createvm/createvm.sh'
#find last line of crontab
crontab_end_line=$(wc -l < temppvebase/etc/crontab)
crontab_deletion_cmd="${crontab_end_line}d"
sudo sed -i ''$crontab_end_line'i\'"$crontabjob1"'\' temppvebase/etc/crontab
#create createvm script to be used as con job
sudo mkdir temppvebase/etc/cron.d/createvm

cat > createvm.sh <<EOF
#!/bin/bash
#Create log file
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
startdate=\$(date +"%Y_%m_%d_%H%M%S")
exec 1>/var/log/"\$startdate"_GitOpsBox_install.log 2>&1
set -xv
#To direct output to console use >&3
echo "Log file "\$startdate"_GitOpsBox_install.log created"
sleep 30

if [ "$disablepvesubscriptionprompt" = "yes" ]; then
  sed -Ezi.bak "s/(Ext.Msg.show\(\{\s+title: gettext\('No valid sub)/void\(\{ \/\/\1/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
  systemctl restart pveproxy.service
fi

if [ "$enablepvenosubscriptionrepo" = "yes" ]; then
  #find and trim current debian codename based on repos
  mainpverepo=\$(cat /etc/apt/sources.list | head -1)
  mainpverepotrim1=\${mainpverepo#*deb http://ftp.debian.org/debian }
  pverepocodename=\${mainpverepotrim1% main contrib*}
  #insert no-subscription repo into repo file
  newpverepo="deb http://download.proxmox.com/debian/pve \$pverepocodename pve-no-subscription"
  echo \$newpverepo >> /etc/apt/sources.list
  #comment out subscription repo
  sed -i -e '/deb/s/^/#/' /etc/apt/sources.list.d/pve-enterprise.list
fi

if [ "$enablenestedvirtualizationintel" = "yes" ]; then
  echo "options kvm-intel nested=Y" > /etc/modprobe.d/kvm-intel.conf
  modprobe -r kvm_intel
  modprobe kvm_intel
fi
if [ "$enablenestedvirtualizationamd" = "yes" ]; then
  echo "options kvm-amd nested=1" > /etc/modprobe.d/kvm-amd.conf
  modprobe -r kvm_amd
  modprobe kvm_amd
fi      
#move iso's during cron after template directories created by pve
mv /var/lib/tempiso/* /var/lib/vz/template/iso
rm -d /var/lib/tempiso
#create pf vm
qm create 100 --ide0 local-lvm:$pfsensehddsize --ide1 local:iso/$latestpfsiso,media=cdrom --cdrom local:iso/pfconfig.iso --cores $pfsensecores --memory $pfsensememory --name pfSense1 --onboot 1 --ostype other --net0 virtio,bridge=vmbr0 --net1 virtio,bridge=vmbr1 --net2 virtio,bridge=vmbr2 --description "The default credentials for pfSense is username: admin password: pfsense%0AThis should be changed within the pfSense web interface.%0AThe web interface should be available on https://$pfsensemgmtipaddress:$pfsensemgmtport"
#unattend pfsense install
qm start 100
qm create 110 --name 10pc-ReadNotes --description "Welcome to GitOpsBox, this temporary Virtual Machine only serves%0Aas notice that pfSense is still installing. The progress of the%0ApfSense configuration is measured in percent as the%0AVM name e.g. 10pc is 10 percent. The deployment time is roughly 15 mins.%0AOnce complete the network should provide DHCP leases and this%0Atemporary VM will delete. Please do not make any password, configuration changes%0Aor console inputs during this time."
#wait for pfsense iso to boot 
sleep 120
qm set 110 --name 20pc-ReadNotes
qm sendkey 100 kp_enter
sleep 5
qm sendkey 100 kp_enter
sleep 5
qm sendkey 100 kp_enter
sleep 5
#change to ufs filesystem depending on pfsenses version based menu change
pfsensefilename=\$(ls /var/lib/vz/template/iso/pfSense-CE*.iso)
#Trim filename down to just version number
pfsensetrim1=\${pfsensefilename#*pfSense-CE-}
pfsenseversion=\${pfsensetrim1%-RELEASE*}
requiredpfsenseversion=2.5.2

if [ "\$(printf '%s\n' "\$requiredpfsenseversion" "\$pfsenseversion" | sort -V |head -n1)" = "\$requiredpfsenseversion" ]; then
  echo "Greater or equal to \$requiredpfsenseversion"
  echo "Down key needed for ufs filesystem menu choice"
  qm sendkey 100 down
else
  echo "Less than \$requiredpfsenseversion"
  echo "No down key needed for ufs filesystem menu choice"
fi

sleep 5
qm sendkey 100 kp_enter
#wait for pfsense to install to disk. generous timeout to allow for slow disks
sleep 120
qm set 110 --name 40pc-ReadNotes
qm sendkey 100 left
sleep 5
qm sendkey 100 kp_enter
sleep 5
#mkdir /tmp/iso
qm sendkey 100 m
qm sendkey 100 k
qm sendkey 100 d
qm sendkey 100 i
qm sendkey 100 r
qm sendkey 100 spc
qm sendkey 100 slash
qm sendkey 100 t
qm sendkey 100 m
qm sendkey 100 p
qm sendkey 100 slash
qm sendkey 100 i
qm sendkey 100 s
qm sendkey 100 o
qm sendkey 100 kp_enter
sleep 5
#mount -t cd9660 /dev/cd1 /tmp/iso
qm sendkey 100 m
qm sendkey 100 o
qm sendkey 100 u
qm sendkey 100 n
qm sendkey 100 t
qm sendkey 100 spc
qm sendkey 100 minus
qm sendkey 100 t
qm sendkey 100 spc
qm sendkey 100 c
qm sendkey 100 d
qm sendkey 100 9
qm sendkey 100 6
qm sendkey 100 6
qm sendkey 100 0
qm sendkey 100 spc
qm sendkey 100 slash
qm sendkey 100 d
qm sendkey 100 e
qm sendkey 100 v
qm sendkey 100 slash
qm sendkey 100 c
qm sendkey 100 d
qm sendkey 100 1
qm sendkey 100 spc
qm sendkey 100 slash
qm sendkey 100 t
qm sendkey 100 m
qm sendkey 100 p
qm sendkey 100 slash
qm sendkey 100 i
qm sendkey 100 s
qm sendkey 100 o
qm sendkey 100 kp_enter
sleep 5
#cp -r /tmp/iso/ /conf/
qm sendkey 100 c
qm sendkey 100 p
qm sendkey 100 spc
qm sendkey 100 minus
qm sendkey 100 r
qm sendkey 100 spc
qm sendkey 100 slash
qm sendkey 100 t
qm sendkey 100 m
qm sendkey 100 p
qm sendkey 100 slash
qm sendkey 100 i
qm sendkey 100 s
qm sendkey 100 o
qm sendkey 100 slash
qm sendkey 100 spc
qm sendkey 100 slash
qm sendkey 100 c
qm sendkey 100 o
qm sendkey 100 n
qm sendkey 100 f
qm sendkey 100 slash
qm sendkey 100 kp_enter
sleep 5
#remove cd and usb from qm 100
qm set 100 --delete ide1
qm set 100 --delete cdrom
rm /var/lib/vz/template/iso/pfconfig.iso
qm shutdown 100
qm set 110 --name 50pc-ReadNotes
qm wait 100
qm set 110 --name 60pc-ReadNotes
qm start 100
#long sleep due to disk speed and WAN dhcp timeout
sleep 120
qm set 110 --name 70pc-ReadNotes
sleep 120
qm set 110 --name 80pc-ReadNotes
# Reset pfSense password to default "pfsense"
qm sendkey 100 3
qm sendkey 100 kp_enter
qm sendkey 100 y
qm sendkey 100 kp_enter
qm sendkey 100 kp_enter
#run shell script to remove wizard, install suricata, pfblocker, enable console password
qm sendkey 100 8
qm sendkey 100 kp_enter
qm sendkey 100 s
qm sendkey 100 h
qm sendkey 100 kp_enter
qm sendkey 100 s
qm sendkey 100 h
qm sendkey 100 spc
qm sendkey 100 slash
qm sendkey 100 c
qm sendkey 100 o
qm sendkey 100 n
qm sendkey 100 f
qm sendkey 100 slash
qm sendkey 100 c
qm sendkey 100 o
qm sendkey 100 n
qm sendkey 100 f
qm sendkey 100 i
qm sendkey 100 g
qm sendkey 100 p
qm sendkey 100 f
qm sendkey 100 dot
qm sendkey 100 s
qm sendkey 100 h
qm sendkey 100 kp_enter
#wait for script to run and pfsense to reboot
qm wait 100
qm set 110 --name 90pc-ReadNotes
qm start 100
sleep 130
if [ "$enablepausedeployformanualwanconfig" = "yes" ]; then
  qm set 110 --name DEPLOYPAUSED --description "GitOpsBox deployment is paused as the option%0Aenablepausedeployformanualwanconfig was enabled. This is so that the WAN may be manually%0Aconfigured for pfSense. pfSense packages suricata and pfBlockerNG-devel will also need to be manually installed. Confirm that the DNS Resolver service is started.%0ATo resume GitOpsBox deployment, configure the WAN for internet access%0Aand then destroy this DEPLOYPAUSED vm and the script will resume. The default credentials for pfSense is username: admin password: pfsense%0AThis should be changed within the pfSense web interface.%0AThe web interface should be available on https://$pfsensemgmtipaddress:$pfsensemgmtport"
  qm config 110
  until [ \$? -eq 2 ]; do
    sleep 30
    echo "Progress VM still exists for WAN pause, waiting 30s to check if VM has been destroyed"
    qm config 110
  done
fi
qm destroy 110
if [ "$deploygitops" = "yes" ]; then
  qm create 111 --name GitOpsDeploying-ReadNotes --description "Welcome to GitOpsBox, this temporary Virtual Machine only serves%0Aas notice that GitOpsBox is still installing. There is no percentage progress recorded on this VM.%0AAfter the management kubernetes host and gitlab have been deployed this VM will delete.%0AFurther progress for the GitOps deployment can be viewed on gitlab web interface%0Aunder individual jobs. Gitlab can be accessed at https://gitlab.$mgmtdomain.%0AGitlab password for user 'root' is found in MGMT-UbuntuK3S-1-gitlabinitialrootpassword.txt in home directory of proxmox after deployment.%0AThe total deployment time is roughly 45 mins.%0APlease do not make any password, configuration changes or console inputs during this time."
  #run gitops script
  bash /etc/cron.d/createvm/createmgmtk3s.sh
  qm destroy 111
  mgmtvmlogfile=\$(ls /var/log/*_GitOpsBox_mgmtk3sVM.log)
  echo "VM log appended below"
  cat "\$mgmtvmlogfile"
  rm -f "\$mgmtvmlogfile"
fi
#self delete
sed -i '$crontab_deletion_cmd' /etc/crontab
rm -r /etc/cron.d/createvm
EOF

sudo mv createvm.sh temppvebase/etc/cron.d/createvm/createvm.sh
}

createmgmtk3svmshellscript() {
#Bash heredoc is sensitive to indentation so this function uses no indentation while remainder of script uses 2 spaces
if [ "$deploygitops" = "yes" ]; then
cat << EOF > createmgmtk3s.sh
#!/bin/bash
setvariables () {
#new
mgmtk3siprangestart=$mgmtk3siprangestart
mgmtk3spodiprangestart=$mgmtk3spodiprangestart
mgmtk3spodsubnetmaskbits=$mgmtk3spodsubnetmaskbits
mgmtk3sserviceiprangestart=$mgmtk3sserviceiprangestart
mgmtk3sservicesubnetmaskbits=$mgmtk3sservicesubnetmaskbits
#magic
mgmtk3scorednsip=\$(echo $mgmtk3sserviceiprangestart | cut -d . -f 1-3 | sed "s/$/.10/g")
mgmtk3shostmemory=$mgmtk3shostmemory
#gitlabk8srequires 4CPU to deploy
mgmtk3shostcpucores=$mgmtk3shostcpucores
mgmtk3sdisksize=$mgmtk3sdisksize
#dns record
mgmtsubnet=$mgmtsubnet
pfsensemgmtipaddress=$pfsensemgmtipaddress
landomain=$landomain
}

main() {
  createlogfile
  setvariables
  pveinstalldependencies
  mgmtk3sbuildvm
  mgmtk3sbuildk3s
  mgmtk3sgetkubeconfig
  mgmtk3sinstalldependencies
  mgmtk3scopyexecutegitlabvaultinstall
  mgmtk3sexportandtidy
 }

createlogfile () {
  exec 3>&1 4>&2
  trap 'exec 2>&4 1>&3' 0 1 2 3 15
  startdate=\$(date +"%Y_%m_%d_%H%M%S")
  exec 1>/var/log/"\$startdate"_GitOpsBox_mgmtk3sVM.log 2>&1
  set -xv
  echo "Log file "\$startdate"_GitOpsBox_mgmtk3sVM.log created" >&3
}

pveinstalldependencies () {

until [ -f /usr/bin/expect ];
do
  sleep 20
  apt-get -o DPkg::Lock::Timeout=600 update
  apt-get -o DPkg::Lock::Timeout=600 install -y expect
done
}

mgmtk3sbuildvm () {
#find mgmtk3sqmid
mgmtk3sid=\$(pvesh get /cluster/nextid)
#find empty ip for VM
mgmtk3siprangestartfirstthreeoctets=\$(echo $mgmtk3siprangestart | cut -d . -f 1-3)
mgmtk3siprangestartlastoctet=\$(echo $mgmtk3siprangestart | cut -d . -f 4)
#find empty name for VM
vmnumber=1
mgmtk3sname="MGMT-UbuntuK3S-"\$vmnumber
vmnamesearch=\$(qm list | grep "\$mgmtk3sname")
until [[ -z "\${vmnamesearch}" ]];
do
  vmnumber=\$((vmnumber+1))
  mgmtk3siprangestartlastoctet=\$((mgmtk3siprangestartlastoctet+1))
  mgmtk3sname="MGMT-UbuntuK3S-"\$vmnumber
  vmnamesearch=\$(qm list | grep "\$mgmtk3sname")
done

mgmtk3sip="\$mgmtk3siprangestartfirstthreeoctets"."\$mgmtk3siprangestartlastoctet"

#find ubuntuminimalimg
ubuntuminimalimg=\$(find /var/lib/vz/template/iso -name "ubuntu-*-minimal-cloudimg-amd64.img")

#create vm
qm create "\$mgmtk3sid" --name "\$mgmtk3sname" --memory $mgmtk3shostmemory --cores $mgmtk3shostcpucores --net0 virtio,bridge=vmbr2,firewall=1 --ostype l26 --onboot 1 --serial0 socket --vga serial0 --description "Management kubernetes host built from minimal Ubuntu server and K3S for GitOpsBox. Hosts Gitlab and Vault. SSH access can be made from Proxmox console using 'ssh -o ubuntu@\$mgmtk3sip'. Kubeconfig file is found at \$mgmtk3sname-k3s.yaml. Password for ubuntu user is stored in \$mgmtk3sname-ubuntu-password.txt. Gitlab can be accessed at https://gitlab.$mgmtdomain from Management network or LAN network. LAN network is intended only for segregated access to LAN gitlab group via additional users. Gitlab password for user 'root' is found in \$mgmtk3sname-gitlabinitialrootpassword.txt. Vault can be accessed from management network at https://vault.$mgmtdomain. Unseal keys and initial root token are found in \$mgmtk3sname-vaultunsealkeys.txt. Poor quality console via serial is due to minimal ubuntu server not including video drivers."

qm importdisk \$mgmtk3sid \$ubuntuminimalimg local-lvm -format qcow2

qm set \$mgmtk3sid --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-\$mgmtk3sid-disk-0

qm set \$mgmtk3sid --ide2 local-lvm:cloudinit --bootdisk scsi0 --boot c

qm resize \$mgmtk3sid scsi0 $mgmtk3sdisksize

qm set \$mgmtk3sid --ipconfig0 ip="\$mgmtk3sip"/"\$mgmtsubnet",gw="\$pfsensemgmtipaddress"

#stop log so password is not in log
set +xv
mgmtk3spassword=\$(openssl rand -hex 12)
echo \$mgmtk3spassword > \$mgmtk3sname-ubuntu-password.txt
chmod 600 \$mgmtk3sname-ubuntu-password.txt
#enable ssh from pve
qm set \$mgmtk3sid --sshkey ~/.ssh/id_rsa.pub > /dev/null
qm set \$mgmtk3sid --cipassword "\$mgmtk3spassword"
set -xv

qm start \$mgmtk3sid

sleep 60
}

mgmtk3sbuildk3s () {
cat << EOM > config.yaml
cluster-cidr: $mgmtk3spodiprangestart/$mgmtk3spodsubnetmaskbits
service-cidr: $mgmtk3sserviceiprangestart/$mgmtk3sservicesubnetmaskbits
cluster-dns: \$mgmtk3scorednsip
resolv-conf: /run/systemd/resolve/resolv.conf
EOM
scp -o StrictHostKeyChecking=no \$mgmtk3sname-ubuntu-password.txt ubuntu@\$mgmtk3sip:~/\$mgmtk3sname-ubuntu-password.txt
scp -o StrictHostKeyChecking=no config.yaml ubuntu@\$mgmtk3sip:~/config.yaml
rm -f config.yaml
ssh -o StrictHostKeyChecking=no ubuntu@\$mgmtk3sip /bin/bash << EOM
set -xv
#exit if internet not available
wget --timeout 10 --spider https://ubuntu.com
if [ "\$?" != "0" ]; then exit 1; fi
sudo mkdir --parents /etc/rancher/k3s/
sudo mv config.yaml /etc/rancher/k3s/config.yaml
sudo chown 0:0 /etc/rancher/k3s/config.yaml
sudo chmod 0644 /etc/rancher/k3s/config.yaml
curl -sfL https://get.k3s.io | sh -
sleep 90
sudo cp --no-preserve=all /etc/rancher/k3s/k3s.yaml ~/k3s.yaml
kubectl --kubeconfig=k3s.yaml wait --timeout=120s --for=condition=available deployment/traefik --namespace kube-system
EOM
}

mgmtk3sgetkubeconfig () {
scp -o StrictHostKeyChecking=no ubuntu@\$mgmtk3sip:~/k3s.yaml \$mgmtk3sname-k3s.yaml
sed -i 's/127.0.0.1/'\$mgmtk3sip'/g' \$mgmtk3sname-k3s.yaml
chmod 600 \$mgmtk3sname-k3s.yaml
}

mgmtk3sinstalldependencies () {
  #Install dependencies seperate of main script due to ssh -tt and apt install preventing exit at end of script.
  #Install helm
  ssh -o StrictHostKeyChecking=no ubuntu@\$mgmtk3sip 'sudo apt-get -o DPkg::Lock::Timeout=600 update'
  sleep 10
  ssh -o StrictHostKeyChecking=no ubuntu@\$mgmtk3sip 'curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -'
  ssh -o StrictHostKeyChecking=no ubuntu@\$mgmtk3sip 'sudo apt -o DPkg::Lock::Timeout=600 install -y apt-transport-https'
  ssh -o StrictHostKeyChecking=no ubuntu@\$mgmtk3sip 'echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list'
  ssh -o StrictHostKeyChecking=no ubuntu@\$mgmtk3sip 'sudo apt-get -o DPkg::Lock::Timeout=600 update'
  ssh -o StrictHostKeyChecking=no ubuntu@\$mgmtk3sip 'sudo apt-get -o DPkg::Lock::Timeout=600 install -y helm'
  ssh -o StrictHostKeyChecking=no ubuntu@\$mgmtk3sip 'sudo apt-get -o DPkg::Lock::Timeout=600 update'
  #Install docker
  ssh -o StrictHostKeyChecking=no ubuntu@\$mgmtk3sip 'sudo apt-get -o DPkg::Lock::Timeout=600 install -y docker.io'
  ssh -o StrictHostKeyChecking=no ubuntu@\$mgmtk3sip 'sudo apt-get -o DPkg::Lock::Timeout=600 update'
  ssh -o StrictHostKeyChecking=no ubuntu@\$mgmtk3sip 'sudo apt-get -o DPkg::Lock::Timeout=600 update'
  ssh -o StrictHostKeyChecking=no ubuntu@\$mgmtk3sip 'sudo apt-get -o DPkg::Lock::Timeout=600 install -y acpid'
  ssh -o StrictHostKeyChecking=no ubuntu@\$mgmtk3sip 'sudo apt-get -o DPkg::Lock::Timeout=600 upgrade'
  ssh -o StrictHostKeyChecking=no ubuntu@\$mgmtk3sip 'sudo reboot'
  while true; do command ssh -o StrictHostKeyChecking=no ubuntu@\$mgmtk3sip 'kubectl --kubeconfig=k3s.yaml wait --timeout=240s --for=condition=available deployment/traefik --namespace kube-system'; [ \$? -eq 0 ] && break || sleep 30; done
}

mgmtk3scopyexecutegitlabvaultinstall () {
scp -r -o StrictHostKeyChecking=no ~/gitlabcustomprojects ubuntu@\$mgmtk3sip:~/gitlabcustomprojects
rm -rf gitlabcustomprojects
scp -o StrictHostKeyChecking=no /etc/cron.d/createvm/configmgmtk3s.sh ubuntu@\$mgmtk3sip:~/configmgmtk3s.sh

ssh -o StrictHostKeyChecking=no ubuntu@\$mgmtk3sip /bin/bash << EOM
bash "configmgmtk3s.sh"
exit
EOM
}

mgmtk3sexportandtidy () {
scp -o StrictHostKeyChecking=no ubuntu@\$mgmtk3sip:~/gitlabinitialrootpassword.txt \$mgmtk3sname-gitlabinitialrootpassword.txt
chmod 600 \$mgmtk3sname-gitlabinitialrootpassword.txt
scp -o StrictHostKeyChecking=no ubuntu@\$mgmtk3sip:~/vaultunsealkeys.txt \$mgmtk3sname-vaultunsealkeys.txt
chmod 600 \$mgmtk3sname-vaultunsealkeys.txt

gitopslogfile=\$(ssh -o StrictHostKeyChecking=no ubuntu@\$mgmtk3sip ls *_GitOpsBox_Mgmt.log)
ssh -o StrictHostKeyChecking=no ubuntu@\$mgmtk3sip cat \$gitopslogfile

ssh -tt -o StrictHostKeyChecking=no ubuntu@\$mgmtk3sip /bin/bash << EOM
rm -f \$gitopslogfile
rm -f k3s.yaml
rm -f vaultunsealkeys.txt
rm -f gitlabinitialrootpassword.txt
rm -f configmgmtk3s.sh
rm -f \$mgmtk3sname-ubuntu-password.txt
exit
EOM
ssh-keygen -f "/root/.ssh/known_hosts" -R "\$mgmtk3sip"
}

main "\$@"
EOF

sudo mv createmgmtk3s.sh temppvebase/etc/cron.d/createvm/createmgmtk3s.sh
fi
}

createconfigmgmtk3sshellscript() {
#Bash heredoc is sensitive to indentation so this function uses no indentation while remainder of script uses 2 spaces
if [ "$deploygitops" = "yes" ]; then
cat << EOF > configmgmtk3s.sh
#!/bin/bash

setvariables () {
set -xv
gitlabsshport=$gitlabsshport
landomain=$landomain
mgmtdomain=$mgmtdomain
pvetimezone=$pvetimezone
pvepassword=$pvepassword
#magic variables
#k8shostip=\$(sudo kubectl get services --namespace kube-system traefik --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
#vault
vaulturl=vault.$mgmtdomain
quoteescapevaulturl='\`'\$vaulturl'\`'
#gitlab
starescape='\`*\`'
kasaddress=kas.$mgmtdomain
minioaddress=minio.$mgmtdomain
fullgitlaburl=gitlab.$mgmtdomain
pemname="gitlab.$mgmtdomain.ca.pem"
}

main () {

createlogfilemgmt
setvariables
sudokeepalive
installgitlabhelm
configuregitlabtraefik
gitlabgeneratepersonalaccesstoken
gitlabsetsshkey
gitlabcreatecicdlank3shostforprojectandgroup "LANK3SHost1" "Management"
gitlabcreatecicdnewrepowithagentforprojectandgroup "CreateNewProjectWithAgent" "Management"
gitlabcreatecicdlancodeserverforprojectandgroup "CodeServer1" "LAN"
gitlabcreatecustomgroups
gitlabcreatecustomprojects
gitlabcreateagentforprojectundergroup "LANK3SHost1" "Management"
gitlabinstallrunnerforgroup "Management"
gitlabrevokesshkey
vaultcreateconfigfilesforinstall
vaultcreateselfsignedcertificateforinstall
vaultconfigmapofgitlabca
vaultaddcerttorunner
vaultinstallwithhelm
vaultafterinstallunseal
vaultconfigurejwtforgitlab
vaultcreatesecretsjwtforgitlabgroupmgmt "Management" "LAN"
vaultcreatesecretsjwtforgitlabgroup "LAN"
gitlabcreatenewvariableundergroup vault.ca Management
gitlabcreatenewvariableundergroup vault.ca LAN
vaultcreateforgitlabgroupsecretkeyvalue "Management" "ProxmoxUser" "root" "\$pvepassword"
vaultcreateforgitlabgroupsecretfile "Management" "MGMT-UbuntuK3S-1-Kubeconfig" "k3s.yaml" "k3s.yaml"
vaultcreateforgitlabgroupsecretfile "LAN" "Gitlab-CA" "\$pemname" "\$pemname"
vaultcreateforgitlabgroupsecretfile "Management" "MGMT-UbuntuK3S-1-ubuntu-password" "ubuntu" "MGMT-UbuntuK3S-1-ubuntu-password.txt"
vaultcreateforgitlabgroupsecretfile "Management" "Gitlab-initial-root-password" "root" "gitlabinitialrootpassword.txt"
vaulttidyup
gitlabrevokepersonalaccesstoken
gitlabtidyup
}

createlogfilemgmt () {
  exec 3>&1 4>&2
  trap 'exec 2>&4 1>&3' 0 1 2 3
  startdate=\$(date +"%Y_%m_%d_%H%M%S")
  exec 1>"\$startdate"_GitOpsBox_Mgmt.log 2>&1
  set -xv
  echo "Log file "\$startdate"_GitOpsBox_mgmt.log created" >&3
}

sudokeepalive () {
  while true; do sudo -n true; sleep 60; kill -0 "\$$" || exit; done 2>/dev/null &
}

installgitlabhelm () {

  helm repo add gitlab https://charts.gitlab.io/

  helm upgrade --kubeconfig=k3s.yaml --install gitlab gitlab/gitlab --timeout 600s --set global.hosts.domain="$mgmtdomain" --set global.hosts.externalIP="$mgmtk3siprangestart" --set global.time_zone="$pvetimezone" --set global.ingress.configureCertmanager=false --set global.edition=ce --set global.appConfig.enableUsagePing=false --set gitlab-runner.install=false --set global.kas.enabled=true --set global.shell.port="$gitlabsshport" --set nginx-ingress.enabled=false --set global.ingress.class=none --set global.ingress.provider=traefik --namespace gitlab --create-namespace

  #wait for deployments, get sidekiq name, sidekiq has cpu requirements?
  echo "Waiting for gitlab to deploy..."
  kubectl --kubeconfig=k3s.yaml wait --timeout=3600s --for=condition=available deployment/gitlab-sidekiq-all-in-1-v2 --namespace gitlab

  kubectl --kubeconfig=k3s.yaml wait --timeout=3600s --for=condition=available deployment/gitlab-webservice-default --namespace gitlab
  
  kubectl --kubeconfig=k3s.yaml get secret gitlab-wildcard-tls-ca --namespace gitlab -ojsonpath='{.data.cfssl_ca}' | base64 --decode > "\$pemname"
  
  kubectl --kubeconfig=k3s.yaml get secret --namespace=gitlab gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode > gitlabinitialrootpassword.txt

}

configuregitlabtraefik () {
#Bash heredoc is sensitive to indentation so this function uses no indentation while remainder of script uses 2 spaces
#creates an entrypoint in traefik for gitlab ssh port
#disables sendanonymoususage by omiting it from arguments
#checknewversion is default argument but traefik image is static determined by k3s
cat <<EOM >traefik-config.yaml
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: traefik
  namespace: kube-system
spec:
  valuesContent: |-
    ports:
      gitlabssh:
        port: $gitlabsshport
        expose: true
        exposedPort: $gitlabsshport
        protocol: TCP
    globalArguments:
      - "--global.checknewversion"
EOM

sudo mv traefik-config.yaml /var/lib/rancher/k3s/server/manifests/traefik-config.yaml

cat <<EOM >gitlabsshingressroutetcp.yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRouteTCP
metadata:
  name: gitlabssh-traefik-crd
  namespace: gitlab
spec:
  entryPoints:
    - gitlabssh
  routes:
  - match: HostSNI(\$starescape)
    services:
    - name: gitlab-gitlab-shell
      port: $gitlabsshport
EOM

kubectl --kubeconfig=k3s.yaml --namespace gitlab apply -f gitlabsshingressroutetcp.yaml
}

gitlabgeneratepersonalaccesstoken () {

  gitlabtoolboxpod=\$(kubectl --kubeconfig=k3s.yaml --namespace gitlab get pods -o name |  awk '{if (\$1 ~ "gitlab-toolbox-") print \$0}')
  gitlabtoolboxpod=\${gitlabtoolboxpod#"pod/"}

  gitlabtemppersonalaccesstoken=\$(openssl rand -hex 10)

  kubectl --kubeconfig=k3s.yaml --namespace gitlab exec -it "\$gitlabtoolboxpod" -- /srv/gitlab/bin/rails runner "token = User.find_by_username('root').personal_access_tokens.create(scopes: [:api, :read_user, :read_api, :read_repository, :write_repository, :read_registry, :write_registry, :sudo], name: 'GitOpsBoxtemptoken'); token.set_token('\$gitlabtemppersonalaccesstoken'); token.save;"
}

gitlabcreatecustomgroups () {

readarray -d '' gitlabcustomdirs < <(find "./gitlabcustomprojects" -maxdepth 1 -mindepth 1 -type d -print0)

for i in "\${gitlabcustomdirs[@]}"
do
  tempgitlabgroupname=\$(echo \$i | cut -d'/' -f3- | rev | cut -d'/' -f2- | rev )
  curl --insecure --header "PRIVATE-TOKEN: \$gitlabtemppersonalaccesstoken" -X POST "https://\$fullgitlaburl/api/v4/groups?name=\$tempgitlabgroupname&path=\$tempgitlabgroupname"
done
}

gitlabcreatenewprojectundergroup () {
  gitlabgroupid=\$(curl --insecure --header "PRIVATE-TOKEN: \$gitlabtemppersonalaccesstoken" -X GET https://\$fullgitlaburl/api/v4/groups?search=\$2 | grep -o -P '(?<={"id":).*(?=,"web_url":)')

  curl --silent --insecure --header "PRIVATE-TOKEN: \$gitlabtemppersonalaccesstoken" -X POST "https://\$fullgitlaburl/api/v4/projects?name=\$1&namespace_id=\$gitlabgroupid&initialize_with_readme=true" > /dev/null
}

gitlabcreateagentforprojectundergroup () {
#Bash heredoc is sensitive to indentation so this function uses no indentation while remainder of script uses 2 spaces
gitlabprojectid=\$(curl --insecure --header "PRIVATE-TOKEN: \$gitlabtemppersonalaccesstoken" -X GET https://\$fullgitlaburl/api/v4/projects/\$2%2F\$1 | grep -o -P '(?<={"id":).*(?=,"description":)')

lowercasereponame=\$(echo "\${1,,}")

#create config file for agent under project
curl --insecure --header "PRIVATE-TOKEN: \$gitlabtemppersonalaccesstoken" -X POST --data branch="main" --data content="" --data commit_message="GitOpsBox project creation" "https://\$fullgitlaburl/api/v4/projects/\$gitlabprojectid/repository/files/%2Egitlab%2Fagents%2F\$lowercasereponame-agent%2Fconfig%2Eyaml"

read -r -d '' graphqlcreateclusteragent << EOM
mutation createAgent {
  createClusterAgent(input: { projectPath: \"\$2/\$1\", name: \"\$lowercasereponame-agent\" }) {
    clusterAgent {
      id
      name
    }
    errors
  }
}
EOM

graphqlcreateclusteragent="\$(echo \$graphqlcreateclusteragent)"

createclusteragent=\$(curl --insecure --header "Authorization: Bearer \$gitlabtemppersonalaccesstoken" --header "Content-Type: application/json" -X POST -d "{ \"query\": \"\$graphqlcreateclusteragent\"}" "https://\$fullgitlaburl/api/graphql")

clusteragentgid=\$(echo "\$createclusteragent" | grep -o -P '(?<=id":").*(?=","name)')

gitlabagentnametoken="\$lowercasereponame"-agent"token"

read -r -d '' graphqlclusteragenttokencreate << EOM
mutation createToken {
  clusterAgentTokenCreate(input: { clusterAgentId: \"\$clusteragentgid\", name: \"\$gitlabagentnametoken\" }) {
    secret
    token {
      createdAt
      id
    }
    errors
  }
}
EOM

graphqlclusteragenttokencreate="\$(echo \$graphqlclusteragenttokencreate)"
#disable logging to prevent secrets being recorded during vault unseal
set +xv
createagenttoken=\$(curl --insecure --header "Authorization: Bearer \$gitlabtemppersonalaccesstoken" --header "Content-Type: application/json" -X POST -d "{ \"query\": \"\$graphqlclusteragenttokencreate\"}" "https://\$fullgitlaburl/api/graphql")

agenttoken=\$(echo "\$createagenttoken" | grep -o -P '(?<=secret":").*(?=","token":)')
#re-enable logging
set -xv

kubectl --kubeconfig=k3s.yaml create namespace \$lowercasereponame

kubectl --kubeconfig=k3s.yaml --namespace \$lowercasereponame create configmap \$lowercasereponame-ca-pemstore --from-file="\$pemname"
#disable logging to prevent secrets being recorded during vault unseal
set +xv

sudo docker run --pull=always --rm registry.gitlab.com/gitlab-org/cluster-integration/gitlab-agent/cli:stable generate --name-prefix \$lowercasereponame --agent-token=\$agenttoken --kas-address=wss://\$kasaddress --agent-version stable --namespace \$lowercasereponame | tee agent.yaml >/dev/null
#re-enable logging
set -xv

volumemountinsertline1=\$(sed -n /'volumeMounts:'/= agent.yaml)
volumemountinsertline=\$((volumemountinsertline1+1))
sed -i ''"\$volumemountinsertline"'i\          subPath: '"\$pemname"'\' agent.yaml
sed -i ''"\$volumemountinsertline"'i\          name: ca-pemstore-volume\' agent.yaml
sed -i ''"\$volumemountinsertline"'i\        - mountPath: /etc/ssl/certs/'"\$pemname"'\' agent.yaml

volumesinsertline1=\$(sed -n /'volumes:'/= agent.yaml)
volumesinsertline=\$((volumesinsertline1+1))
sed -i ''"\$volumesinsertline"'i\            path: '"\$pemname"'\' agent.yaml
sed -i ''"\$volumesinsertline"'i\          - key: '"\$pemname"'\' agent.yaml
sed -i ''"\$volumesinsertline"'i\          items:\' agent.yaml
sed -i ''"\$volumesinsertline"'i\          name: '"\$lowercasereponame"'-ca-pemstore\' agent.yaml
sed -i ''"\$volumesinsertline"'i\        configMap:\' agent.yaml
sed -i ''"\$volumesinsertline"'i\      - name: ca-pemstore-volume\' agent.yaml

kubectl --kubeconfig=k3s.yaml apply -f agent.yaml
sudo rm -f agent.yaml
}

gitlabinstallrunnerforgroup () {  
#Bash heredoc is sensitive to indentation so this function uses no indentation while remainder of script uses 2 spaces
#disable logging to prevent secrets being recorded during vault unseal
set +xv

gitlabgrouprunnertoken=\$(curl --insecure --header "PRIVATE-TOKEN: \$gitlabtemppersonalaccesstoken" "https://\$fullgitlaburl/api/v4/groups/\$1" | grep -o -P '(?<="runners_token":").*(?=","prevent_sharing_groups_outside_hierarchy":)')
#re-enable logging
set -xv

lowercasegroupname=\$(echo "\${1,,}")

kubectl --kubeconfig=k3s.yaml create namespace \$lowercasegroupname-runner

kubectl --kubeconfig=k3s.yaml get secret gitlab-wildcard-tls-chain --namespace gitlab -o yaml | sed 's/namespace: .*/namespace: '"\$lowercasegroupname"'-runner/' | kubectl --kubeconfig=k3s.yaml apply -f -
#disable logging to prevent secrets being recorded during vault unseal
set +xv

kubectl --kubeconfig=k3s.yaml create secret generic \$lowercasegroupname-runner --namespace \$lowercasegroupname-runner --from-literal=runner-registration-token=\$gitlabgrouprunnertoken --from-literal=runner-token=""
#re-enable logging
set -xv

helm upgrade --kubeconfig=k3s.yaml --install gitlab-runner gitlab/gitlab-runner --namespace \$lowercasegroupname-runner --set certsSecretName=gitlab-wildcard-tls-chain --set gitlabUrl=https://"\$fullgitlaburl" --set runners.secret=\$lowercasegroupname-runner --set image=gitlab/gitlab-runner:latest --set securityContext.runAsUser=999 --set securityContext.fsGroup=999 --set rbac.create=true --set runners.locked=false --set podAnnotations.gitlab.com/prometheus_scrape="true" --set podAnnotations.gitlab.com/prometheus_port=9252 --set "runners.config=[[runners]]
  [runners.kubernetes]
  image = \"gitlab/gitlab-runner:latest\"
  [runners.cache]
          Type = \"s3\"
          Path = \"gitlab-runner\"
          Shared = true
          [runners.cache.s3]
            ServerAddress = \"\$minioaddress:9000\"
            BucketName = \"runner-cache\"
            BucketLocation = \"us-east-1\"
            Insecure = false"
}

gitlabsetsshkey () {
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -q -N ""
sshkey=\$(cat ~/.ssh/id_ed25519.pub)
gitlabcurrentuserid=\$(curl --insecure --header "PRIVATE-TOKEN: \$gitlabtemppersonalaccesstoken" -X GET https://\$fullgitlaburl/api/v4/user | grep -o -P '(?<={"id":).*(?=,"username":)')
#add ssh key to user with id
gitlabnewsshkeyid=\$(curl --insecure --header "PRIVATE-TOKEN: \$gitlabtemppersonalaccesstoken" -X POST --data title="GitOpsBox create ssh key" --data-urlencode key="\$sshkey" "https://\$fullgitlaburl/api/v4/users/\$gitlabcurrentuserid/keys?" | grep -o -P '(?<={"id":).*(?=,"title":)')
git config --global user.email "admin@example.com"
git config --global user.name "GitOpsBox"
}

gitlabcreatecustomprojects () {

readarray -d '' gitlabcustomsubdirs < <(find "./gitlabcustomprojects" -maxdepth 2 -mindepth 2 -type d -print0)

for i in "\${gitlabcustomsubdirs[@]}"
do
  tempgitlabreponame=\$(echo \$i | cut -d'/' -f4-)
  tempgitlabgroupname=\$(echo \$i | cut -d'/' -f3- | rev | cut -d'/' -f2- | rev )
  gitlabcreatenewprojectundergroup "\$tempgitlabreponame" "\$tempgitlabgroupname"

  gitlabsshrepourl=\$(curl --insecure --header "PRIVATE-TOKEN: \$gitlabtemppersonalaccesstoken" -X GET https://\$fullgitlaburl/api/v4/projects/\$tempgitlabgroupname%2F\$tempgitlabreponame | grep -o -P '(?<=,"ssh_url_to_repo":").*(?=","http_url_to_repo":")')
  GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" git clone "\$gitlabsshrepourl" ./gitlabcustomprojects/temp
  mv ./gitlabcustomprojects/temp/.git "\$i/.git"
  mv ./gitlabcustomprojects/temp/README.md "\$i/README.md"
  rm -rf ./gitlabcustomprojects/temp
  cd \$i
  git add -A
  git commit -m "GitOpsBox project creation"
  git push origin main
  rm -rf .git
  cd ..
  cd ..
  cd ..
done
}

gitlabrevokesshkey () {
  curl --insecure --header "PRIVATE-TOKEN: \$gitlabtemppersonalaccesstoken" -X DELETE "https://\$fullgitlaburl/api/v4/users/\$gitlabcurrentuserid/keys/\$gitlabnewsshkeyid?"
  rm -f ~/.ssh/id_ed25519.pub
  rm -f ~/.ssh/id_ed25519
}

gitlabrevokepersonalaccesstoken () {
  #escape exclamation mark from bash so that it can be used in ruby console
  exclaim='!'

  kubectl --kubeconfig=k3s.yaml --namespace gitlab exec -it "\$gitlabtoolboxpod" -- /srv/gitlab/bin/rails runner "token = PersonalAccessToken.find_by_token('\$gitlabtemppersonalaccesstoken'); token.revoke\$exclaim"
}

gitlabtidyup () {
sudo rm -f \$pemname
sudo rm -f gitlabsshingressroutetcp.yaml
sudo rm -f gitlabssh.sh
sudo rm ~/.ssh/known_hosts
sudo rm -rf gitlabcustomprojects
}

vaultcreateconfigfilesforinstall () {
#Bash heredoc is sensitive to indentation so this function uses no indentation while remainder of script uses 2 spaces
cat <<EOM >vaultingressroutetcp.yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRouteTCP
metadata:
  name: vault-traefik-crd
  namespace: vault
spec:
  entryPoints:
    - websecure
  tls:
    passthrough: true
  routes:
  - match: HostSNI(\$quoteescapevaulturl)
    services:
    - name: vault
      port: 8200
EOM

cat << EOM > vaultservervalues.yaml
global:
  tlsDisable: false
server:
  extraEnvironmentVars:
    VAULT_CACERT: /vault/userconfig/vault-server-tls/vault.ca
  volumes:
    - name: gitlab-ca
      configMap:
        name: vault-ca-pemstore
        items:
        - key: \$pemname
          path: \$pemname
    - name: vault-server-tls
      secret:
        secretName: vault-server-tls
  volumeMounts:
  - name: gitlab-ca
    mountPath: "/vault/userconfig/gitlab-ca"
    subPath: \$pemname
  - name: vault-server-tls
    mountPath: "/vault/userconfig/vault-server-tls/"
  standalone:
    enabled: true
    config: |
      ui = "true"
      
      listener "tcp" {
        address = "[::]:8200"
        cluster_address = "[::]:8201"
        tls_cert_file = "/vault/userconfig/vault-server-tls/vault.crt"
        tls_key_file  = "/vault/userconfig/vault-server-tls/vault.key"
        tls_client_ca_file = "/vault/userconfig/vault-server-tls/vault.ca"
        x_forwarded_for_reject_not_present = "false"
        x_forwarded_for_reject_not_authorized = "false"
      }
        
      storage "file" {
        path = "/vault/data"
      }
EOM
}


vaultcreateselfsignedcertificateforinstall () {
#Bash heredoc is sensitive to indentation so this function uses no indentation while remainder of script uses 2 spaces
cat <<EOM >csr.conf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = \$vaulturl
DNS.2 = \$vaulturl.vault
DNS.3 = \$vaulturl.vault.svc
DNS.4 = \$vaulturl.vault.svc.cluster.local
IP.1 = 127.0.0.1
EOM

openssl genrsa -out vault.key 2048
openssl req -new -key vault.key -subj "/O=system:nodes/CN=system:node:\$vaulturl.vault.svc" -out server.csr -config csr.conf

cat <<EOM >csr.yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: vault-csr
spec:
  signerName: kubernetes.io/kubelet-serving
  groups:
  - system:authenticated
  request: \$(cat server.csr | base64 | tr -d '\n')
  usages:
  - digital signature
  - key encipherment
  - server auth
EOM

kubectl --kubeconfig=k3s.yaml create -f csr.yaml

kubectl --kubeconfig=k3s.yaml certificate approve vault-csr

#disable logging to prevent secrets being recorded during vault unseal
set +xv


until [[ -n "\$vaultservercert" ]]; do
  vaultservercert=\$(kubectl --kubeconfig=k3s.yaml get csr vault-csr -o jsonpath='{.status.certificate}')
  echo "Waiting for certificate to be approved..."
  sleep 10
done

echo "\${vaultservercert}" | openssl base64 -d -A -out vault.crt

#re-enable logging
set -xv

kubectl --kubeconfig=k3s.yaml config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}' | base64 -d > vault.ca

kubectl --kubeconfig=k3s.yaml create namespace vault

kubectl --kubeconfig=k3s.yaml create secret generic vault-server-tls --namespace vault --from-file=vault.key --from-file=vault.crt --from-file=vault.ca
}

vaultconfigmapofgitlabca () {
kubectl --kubeconfig=k3s.yaml get secret gitlab-wildcard-tls-ca --namespace gitlab -ojsonpath='{.data.cfssl_ca}' | base64 --decode > "\$pemname"
kubectl --kubeconfig=k3s.yaml --namespace vault create configmap vault-ca-pemstore --from-file="\$pemname"
}

vaultinstallwithhelm () {
  helm repo add hashicorp https://helm.releases.hashicorp.com
  helm repo update

  kubectl --kubeconfig=k3s.yaml --namespace vault apply -f vaultingressroutetcp.yaml

  helm --kubeconfig=k3s.yaml upgrade --install vault hashicorp/vault --namespace vault -f vaultservervalues.yaml

  sleep 5

  until [[ -n "\$vaultserverpodname" ]]; do
    vaultserverpodname=\$(kubectl --kubeconfig=k3s.yaml get pods --selector='app.kubernetes.io/name=vault' -o jsonpath="{.items[0].metadata.name}" --namespace vault)
    echo "Getting name of Vault pod..."
    sleep 5
  done

  #status.phase=Running can also work when pod is crashed but we cannot use ready status as we have not init'd the vault yet.

  until [[ \$runningvault = *"\$vaultserverpodname"* ]]; do
    runningvault=\$(kubectl --kubeconfig=k3s.yaml get pods --selector='app.kubernetes.io/name=vault' --field-selector=status.phase=Running --namespace vault)
    sleep 10
  done
}

vaultafterinstallunseal () {
  #disable logging to prevent secrets being recorded during vault unseal
  set +xv
  
  kubectl --kubeconfig=k3s.yaml --namespace vault exec \$vaultserverpodname -- vault operator init > vaultunsealkeys.txt

  vaultserverunsealkey1=\$(grep 'Unseal Key 1'  vaultunsealkeys.txt | awk '{print \$NF}')
  vaultserverunsealkey2=\$(grep 'Unseal Key 2'  vaultunsealkeys.txt | awk '{print \$NF}')
  vaultserverunsealkey3=\$(grep 'Unseal Key 3'  vaultunsealkeys.txt | awk '{print \$NF}')
  vaultserverunsealkey4=\$(grep 'Unseal Key 4'  vaultunsealkeys.txt | awk '{print \$NF}')
  vaultserverunsealkey5=\$(grep 'Unseal Key 5'  vaultunsealkeys.txt | awk '{print \$NF}')
  vaultserverinitialroottoken=\$(grep 'Initial Root Token'  vaultunsealkeys.txt | awk '{print \$NF}')

  kubectl --kubeconfig=k3s.yaml --namespace vault exec -ti \$vaultserverpodname -- vault operator unseal \$vaultserverunsealkey1 > /dev/null

  kubectl --kubeconfig=k3s.yaml --namespace vault exec -ti \$vaultserverpodname -- vault operator unseal \$vaultserverunsealkey2 > /dev/null

  kubectl --kubeconfig=k3s.yaml --namespace vault exec -ti \$vaultserverpodname -- vault operator unseal \$vaultserverunsealkey3 > /dev/null

  kubectl --kubeconfig=k3s.yaml --namespace vault exec -ti \$vaultserverpodname -- vault login -no-print \$vaultserverinitialroottoken
  
  kubectl --kubeconfig=k3s.yaml --namespace vault exec -ti \$vaultserverpodname -- vault token lookup | grep policies

  #re-enable logging
  set -xv
  
  #vault needs to be init before it will pass readiness test
  #kubectl --kubeconfig=k3s.yaml wait --timeout=360s --for=condition=Ready statefulset/vault --namespace vault

  #kubectl --kubeconfig=k3s.yaml --namespace vault exec -ti \$vaultserverpodname -- vault operator seal
}

vaultconfigurejwtforgitlab () {

kubectl --kubeconfig=k3s.yaml --namespace vault exec -ti \$vaultserverpodname -- vault auth enable jwt
kubectl --kubeconfig=k3s.yaml --namespace vault exec -ti \$vaultserverpodname -- vault write auth/jwt/config jwks_url="https://\$fullgitlaburl/-/jwks" bound_issuer="\$fullgitlaburl" jwks_ca_pem=@/vault/userconfig/gitlab-ca
}

vaultcreatesecretsjwtforgitlabgroup () {
#Intended for LAN JWT to have access to only LAN vault.
kubectl --kubeconfig=k3s.yaml --namespace vault exec -ti \$vaultserverpodname -- vault secrets enable -version=2 -path=\$1 kv
kubectl --kubeconfig=k3s.yaml --namespace vault exec -i \$vaultserverpodname -- vault policy write \$1-readonly - <<EOM

path "\$1/*" {
  capabilities = [ "read" ]
}
EOM

kubectl --kubeconfig=k3s.yaml --namespace vault exec -i \$vaultserverpodname -- vault policy write \$1-fullaccess - <<EOM

path "\$1/*" {
  capabilities = ["create", "update", "read", "delete"]
}
EOM

gitlabnamespaceid=\$(curl --insecure --header "PRIVATE-TOKEN: \$gitlabtemppersonalaccesstoken" "https://\$fullgitlaburl/api/v4/namespaces/\$1" | grep -o -P '(?<="id":).*(?=,"name")')

kubectl --kubeconfig=k3s.yaml --namespace vault exec -i \$vaultserverpodname -- vault write auth/jwt/role/\$1readonly - <<EOM
{
  "role_type": "jwt",
  "policies": ["\$1-readonly"],
  "token_explicit_max_ttl": 60,
  "user_claim": "user_email",
  "bound_claims_type": "glob",
  "bound_claims": {
    "namespace_id": "\$gitlabnamespaceid"
  }
}
EOM

kubectl --kubeconfig=k3s.yaml --namespace vault exec -i \$vaultserverpodname -- vault write auth/jwt/role/\$1fullaccess - <<EOM
{
  "role_type": "jwt",
  "policies": ["\$1-fullaccess"],
  "token_explicit_max_ttl": 60,
  "user_claim": "user_email",
  "bound_claims_type": "glob",
  "bound_claims": {
    "namespace_id": "\$gitlabnamespaceid"
  }
}
EOM
}

vaultcreatesecretsjwtforgitlabgroupmgmt () {
#Intended for Management JWT to have access to Management and LAN vault.
kubectl --kubeconfig=k3s.yaml --namespace vault exec -ti \$vaultserverpodname -- vault secrets enable -version=2 -path=\$1 kv
kubectl --kubeconfig=k3s.yaml --namespace vault exec -i \$vaultserverpodname -- vault policy write \$1-readonly - <<EOM

path "\$1/*" {
  capabilities = [ "read" ]
}

path "\$2/*" {
  capabilities = [ "read" ]
}
EOM

kubectl --kubeconfig=k3s.yaml --namespace vault exec -i \$vaultserverpodname -- vault policy write \$1-fullaccess - <<EOM

path "\$1/*" {
  capabilities = ["create", "update", "read", "delete"]
}

path "\$2/*" {
  capabilities = ["create", "update", "read", "delete"]
}
EOM

gitlabnamespaceid=\$(curl --insecure --header "PRIVATE-TOKEN: \$gitlabtemppersonalaccesstoken" "https://\$fullgitlaburl/api/v4/namespaces/\$1" | grep -o -P '(?<="id":).*(?=,"name")')

kubectl --kubeconfig=k3s.yaml --namespace vault exec -i \$vaultserverpodname -- vault write auth/jwt/role/\$1readonly - <<EOM
{
  "role_type": "jwt",
  "policies": ["\$1-readonly"],
  "token_explicit_max_ttl": 60,
  "user_claim": "user_email",
  "bound_claims_type": "glob",
  "bound_claims": {
    "namespace_id": "\$gitlabnamespaceid"
  }
}
EOM

kubectl --kubeconfig=k3s.yaml --namespace vault exec -i \$vaultserverpodname -- vault write auth/jwt/role/\$1fullaccess - <<EOM
{
  "role_type": "jwt",
  "policies": ["\$1-fullaccess"],
  "token_explicit_max_ttl": 60,
  "user_claim": "user_email",
  "bound_claims_type": "glob",
  "bound_claims": {
    "namespace_id": "\$gitlabnamespaceid"
  }
}
EOM
}

vaultaddcerttorunner () {
#not used due to kubernetes runner entrypoint bug
runnernamespace=\$(kubectl --kubeconfig=k3s.yaml get namespaces | grep -o .*runner)

#disable logging to prevent secrets being recorded during vault unseal
set +xv

vaultcacert=\$(kubectl --kubeconfig=k3s.yaml config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}')
#re-enable logging
set -xv

cat << EOM > addvaultcerttorunner.yaml
data:
  \$vaulturl.ca: "\$vaultcacert"
EOM

kubectl  --kubeconfig=k3s.yaml patch secret gitlab-wildcard-tls-chain --namespace \$runnernamespace --patch-file addvaultcerttorunner.yaml

kubectl --kubeconfig=k3s.yaml --namespace \$runnernamespace set env deployment/gitlab-runner-gitlab-runner VAULT_CACERT="/home/gitlab-runner/.gitlab-runner/certs/\$vaulturl.ca"
}

vaultaddcerttorunner2 () {
#alt method not used due to kubernetes runner entrypoint bug
kubectl --kubeconfig=k3s.yaml config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}' | base64 -d > vault.\$mgmtdomain.ca
kubectl --kubeconfig=k3s.yaml create secret generic vault-ca --namespace \$runnernamespace --from-file=vault.ca

cat << EOM > addvaultcerttorunner.json
{
    "spec": {
        "template": {
            "spec": {
                "containers": [{
                    "name": "gitlab-runner-gitlab-runner",
                    "volumeMounts": [{
                        "mountPath": "/home/gitlab-runner",
                        "name": "vault-ca"
                    }]
                }],
                "volumes": [{
                    "name": "vault-ca",
                    "secret": {
                        "secretName": "vault-ca"
                    }
                }]
            }
        }
    }
}
EOM

kubectl  --kubeconfig=k3s.yaml patch deployment gitlab-runner-gitlab-runner --namespace \$runnernamespace --patch-file addvaultcerttorunner.json

kubectl --kubeconfig=k3s.yaml --namespace \$runnernamespace set env deployment/gitlab-runner-gitlab-runner VAULT_CACERT="/home/gitlab-runner/vault.\$mgmtdomain.ca"
}

gitlabcreatenewvariableundergroup () {
  gitlabgroupid=\$(curl --insecure --header "PRIVATE-TOKEN: \$gitlabtemppersonalaccesstoken" -X GET https://\$fullgitlaburl/api/v4/groups?search=\$2 | grep -o -P '(?<={"id":).*(?=,"web_url":)')
  #disable logging to prevent secrets being recorded during vault unseal
  set +xv
  #remove dots from filename as they are not allowed as variable key
  gitlabvariablekey=\$(echo "\${1//./}")
  
  gitlabvariablevalue=\$(cat \$1)
  
  curl --silent --insecure --request POST --header "PRIVATE-TOKEN: \$gitlabtemppersonalaccesstoken" "https://\$fullgitlaburl/api/v4/groups/\$gitlabgroupid/variables" --form "key=\$gitlabvariablekey" --form "value=\$gitlabvariablevalue" > /dev/null
  set -xv
}

gitlabcreatecicdlank3shostforprojectandgroup () {
#Bash heredoc is sensitive to indentation so this function uses no indentation while remainder of script uses 2 spaces
mkdir gitlabcustomprojects
mkdir gitlabcustomprojects/"\$2"
mkdir gitlabcustomprojects/"\$2"/"\$1"

cat << 'EOM' > gitlabcustomprojects/"\$2"/"\$1"/.gitlab-ci.yml
variables:
  VAULT_ADDR: "https://vault.$mgmtdomain"
  VAULT_SERVER_URL: "https://vault.$mgmtdomain"
  VAULT_CACERT: "/home/gitlab-runner/vault.$mgmtdomain"
  FULLACCESS: "fullaccess"
  VAULT_AUTH_ROLE: "\$CI_PROJECT_ROOT_NAMESPACE\$FULLACCESS"
  VAULT_SECRET_PATH1: "ProxmoxUser"
  VAULT_SECRET_KEY1: "root"
  VAULT_SECRET_PATH2: "ProxmoxUser"
  VAULT_SECRET_KEY2: "root"
  fullgitlaburl: "gitlab.$mgmtdomain"
  #change VAULT_SECRET_KEY1 variable as needed for custom projects
  #vaultca is a group CICD variable
  #vault kv put creates a secret, best used for recording outputs of a pipeline script. VAULT_AUTH_ROLE will need to be set to fullaccess instead of readonly.
  #If you wish to create a vault secret manually, using the vault web interface is recommended over a pre-filled gitlab variable as the secret may be recorded in gitlab logs.

createlank3shost:
  stage: build
  retry: 2
  script:
  - apt-get update
  - apt-get install gnupg2 -y
  - apt-get install lsb-release -y
  - apt-get install software-properties-common -y
  - curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
  - apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com \$(lsb_release -cs) main"
  - apt-get update
  - apt-get install vault -y
  - apt-get install --reinstall vault -y
  - curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
  - echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
  - apt-get update
  - apt-get install kubectl -y
  - apt-get install sshpass -y
  - apt-get install mkisofs -y
  - echo "\$vaultca" > "\$VAULT_CACERT"
  - export VAULT_TOKEN="\$(vault write -field=token auth/jwt/login role="\$VAULT_AUTH_ROLE" jwt=\$CI_JOB_JWT)"
  - vault kv get -field="\$VAULT_SECRET_KEY1" "\$CI_PROJECT_ROOT_NAMESPACE"/"\$VAULT_SECRET_PATH1" > proxmoxpass.txt
  - vault kv get -field=k3s.yaml "\$CI_PROJECT_ROOT_NAMESPACE"/MGMT-UbuntuK3S-1-Kubeconfig > mgmtk3s.yaml
  - source creategitlabpersonaltoken.sh
  - kubectl --kubeconfig=mgmtk3s.yaml get secret gitlab-wildcard-tls-chain --namespace gitlab -o yaml > gitlab-wildcard-tls-chain.yaml
  - mkdir configlank3shost
  - cp gitlab-wildcard-tls-chain.yaml configlank3shost/gitlab-wildcard-tls-chain.yaml
  - cp configlank3shost.sh configlank3shost/configlank3shost.sh
  - mkisofs -r -l -o configlank3shost.iso configlank3shost
  - sshpass -f proxmoxpass.txt scp -o StrictHostKeyChecking=no configlank3shost.iso root@pve1.$mgmtdomain:/var/lib/vz/template/iso/configlank3shost.iso
  - sshpass -f proxmoxpass.txt scp -o StrictHostKeyChecking=no createlank3shost.sh root@pve1.$mgmtdomain:~/createlank3shost.sh
  - sshpass -f proxmoxpass.txt ssh -o StrictHostKeyChecking=no root@pve1.$mgmtdomain 'bash createlank3shost.sh'
  - sshpass -f proxmoxpass.txt ssh -o StrictHostKeyChecking=no root@pve1.$mgmtdomain 'rm -f createlank3shost.sh'
  - lank3sname=\$(sshpass -f proxmoxpass.txt ssh -o StrictHostKeyChecking=no root@pve1.$mgmtdomain 'cat lank3snameexport.txt')
  - sshpass -f proxmoxpass.txt ssh -o StrictHostKeyChecking=no root@pve1.$mgmtdomain 'rm -f lank3snameexport.txt'
  - lank3sid=\$(sshpass -f proxmoxpass.txt ssh -o StrictHostKeyChecking=no root@pve1.$mgmtdomain 'cat lank3sidexport.txt')
  - sshpass -f proxmoxpass.txt ssh -o StrictHostKeyChecking=no root@pve1.$mgmtdomain 'rm -f lank3sidexport.txt'
  - sshpass -f proxmoxpass.txt ssh -o StrictHostKeyChecking=no root@pve1.$mgmtdomain qm set \$lank3sid --delete ide1
  - lank3spassword=\$(openssl rand -hex 12)
  - echo \$lank3spassword > "\$lank3sname"-ubuntu-password.txt
  - sshpass -f proxmoxpass.txt ssh -o StrictHostKeyChecking=no root@pve1.$mgmtdomain qm set \$lank3sid --cipassword "\$lank3spassword"
  - sshpass -f proxmoxpass.txt scp -o StrictHostKeyChecking=no root@pve1.$mgmtdomain:~/"\$lank3sname"-k3s.yaml "\$lank3sname"-k3s.yaml
  - export VAULT_TOKEN="\$(vault write -field=token auth/jwt/login role="\$VAULT_AUTH_ROLE" jwt=\$CI_JOB_JWT)"
  - vault kv put LAN/"\$lank3sname"-Kubeconfig k3s.yaml=@\$lank3sname-k3s.yaml
  - vault kv put LAN/"\$lank3sname"-ubuntu-password ubuntu=@\$lank3sname-ubuntu-password.txt
  - sshpass -f proxmoxpass.txt scp -o StrictHostKeyChecking=no "\$lank3sname"-ubuntu-password.txt root@pve1.$mgmtdomain:~/"\$lank3sname"-ubuntu-password.txt
  - sshpass -f proxmoxpass.txt ssh -o StrictHostKeyChecking=no root@pve1.$mgmtdomain chmod 600 "\$lank3sname"-ubuntu-password.txt
  - sshpass -f proxmoxpass.txt ssh -o StrictHostKeyChecking=no root@pve1.$mgmtdomain qm shutdown \$lank3sid --timeout 600
  - sshpass -f proxmoxpass.txt ssh -o StrictHostKeyChecking=no root@pve1.$mgmtdomain qm wait \$lank3sid
  - sshpass -f proxmoxpass.txt ssh -o StrictHostKeyChecking=no root@pve1.$mgmtdomain qm start \$lank3sid
  - sshpass -f proxmoxpass.txt ssh -o StrictHostKeyChecking=no root@pve1.$mgmtdomain 'rm -f /var/lib/vz/template/iso/configlank3shost.iso'
  - exclaim='!'
  - kubectl --kubeconfig=mgmtk3s.yaml --namespace gitlab exec -it "\$gitlabtoolboxpod" -- /srv/gitlab/bin/rails runner "token = PersonalAccessToken.find_by_token('\$gitlabtemppersonalaccesstoken'); token.revoke\$exclaim"
  - rm -f gitlab-wildcard-tls-chain.yaml
  - rm -f mgmtk3s.yaml
  - rm -f "\$lank3sname"-k3s.yaml
  - rm -f proxmoxpass.txt
  - rm -f "\$lank3sname"-ubuntu-password.txt
EOM

cat << 'EOM' > gitlabcustomprojects/"\$2"/"\$1"/creategitlabpersonaltoken.sh
#!/bin/bash
gitlabtoolboxpod=\$(kubectl --kubeconfig=mgmtk3s.yaml --namespace gitlab get pods -o name |  awk '{if (\$1 ~ "gitlab-toolbox-") print \$0}')
gitlabtoolboxpod=\${gitlabtoolboxpod#"pod/"}
gitlabtemppersonalaccesstoken=\$(openssl rand -hex 10)
kubectl --kubeconfig=mgmtk3s.yaml --namespace gitlab exec -it "\$gitlabtoolboxpod" -- /srv/gitlab/bin/rails runner "token = User.find_by_username('root').personal_access_tokens.create(scopes: [:api, :read_user, :read_api, :read_repository, :write_repository, :read_registry, :write_registry, :sudo], name: 'GitOpsBoxtemptoken'); token.set_token('\$gitlabtemppersonalaccesstoken'); token.save;"
gitlabgrouprunnertoken=\$(curl --insecure --header "PRIVATE-TOKEN: \$gitlabtemppersonalaccesstoken" "https://\$fullgitlaburl/api/v4/groups/LAN" | grep -o -P '(?<="runners_token":").*(?=","prevent_sharing_groups_outside_hierarchy":)')
sed -i 's/gitlabgrouprunnertokenblank/'\$gitlabgrouprunnertoken'/g' configlank3shost.sh
EOM

cat << 'EOM' > gitlabcustomprojects/"\$2"/"\$1"/createlank3shost.sh
#!/bin/bash
set -xv
lank3shostmemory=$lank3shostmemory
lank3shostcpucores=$lank3shostcpucores
lank3sdisksize=$lank3sdisksize
lanipaddress=$pfsenselanipaddress
lank3siprangestart=$lank3siprangestart
lansubnet=$lansubnet
landomain=$landomain
mgmtdomain=$mgmtdomain
#find next empty VM ID for lank3s use
lank3sid=\$(pvesh get /cluster/nextid)
#find empty ip for VM
lank3siprangestartfirstthreeoctets=\$(echo $lank3siprangestart | cut -d . -f 1-3)
lank3siprangestartlastoctet=\$(echo $lank3siprangestart | cut -d . -f 4)
#find empty name for VM
vmnumber=1
lank3sname="LAN-UbuntuK3S-"\$vmnumber
vmnamesearch=\$(qm list | grep "\$lank3sname")
until [[ -z "\${vmnamesearch}" ]];
do
  vmnumber=\$((vmnumber+1))
  lank3siprangestartlastoctet=\$((lank3siprangestartlastoctet+1))
  lank3sname="LAN-UbuntuK3S-"\$vmnumber
  vmnamesearch=\$(qm list | grep "\$lank3sname")
done

lank3sip="\$lank3siprangestartfirstthreeoctets"."\$lank3siprangestartlastoctet"

#find ubuntuminimalimg
ubuntuminimalimg=\$(find /var/lib/vz/template/iso -name "ubuntu-*-minimal-cloudimg-amd64.img")

#create vm
qm create "\$lank3sid" --name "\$lank3sname" --memory "$lank3shostmemory" --cores "$lank3shostcpucores" --net0 virtio,bridge=vmbr1,firewall=1 --ostype l26 --onboot 1 --serial0 socket --vga serial0 --description "LAN kubernetes host built from minimal Ubuntu server and K3S for GitOpsBox. Hosts Code Server as an example of a deployed application. SSH access is disabled but can be enabled through Proxmox console using cloudinit. Kubeconfig file is found in vault under LAN\ \$lank3sname-kubeconfig. Password for ubuntu user is found in vault under LAN\ \$lank3sname-ubuntu-password. Code Server is accessible via code.$landomain. Password is found in vault under LAN\code-server-password . Root permission is disabled on code terminal. Code server has segregated access to gitlab LAN group and projects as an alternative to running git and IDE on a LAN network device. Access to code server is segregated to the LAN network.  Poor quality console via serial is due to minimal ubuntu server not including video drivers."

qm importdisk \$lank3sid \$ubuntuminimalimg local-lvm -format qcow2

qm set \$lank3sid --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-\$lank3sid-disk-0

qm set \$lank3sid --ide2 local-lvm:cloudinit --bootdisk scsi0 --boot c

qm resize \$lank3sid scsi0 $lank3sdisksize

qm set \$lank3sid --ide1 local:iso/configlank3shost.iso,media=cdrom

qm set \$lank3sid --ipconfig0 ip="\$lank3sip"/"\$lansubnet",gw="\$lanipaddress"

qm set \$lank3sid --nameserver "\$lanipaddress"

qm set \$lank3sid --searchdomain $landomain

qm set \$lank3sid --cipassword "temppass"
#set -xv

qm start \$lank3sid

echo \$lank3sname | tee lank3snameexport.txt
echo \$lank3sid | tee lank3sidexport.txt

sleep 90

/usr/bin/expect <(cat << EOT
set timeout 600
spawn qm terminal \$lank3sid
expect "starting serial terminal on interface serial0 (press Ctrl+O to exit)"
send -- "\r"
expect "\$lank3sname login:"
send -- "ubuntu\r"
expect "Password: "
send -- "temppass\r"
expect "ubuntu@\$lank3sname:~"
send -- "sudo mkdir /media/cdrom0\r"
expect "ubuntu@\$lank3sname:~"
send -- "sudo mount /dev/sr0 /media/cdrom0\r"
expect "ubuntu@\$lank3sname:~"
send -- "cp /media/cdrom0/configlank3shost.sh ~/configlank3shost.sh\r"
expect "ubuntu@\$lank3sname:~"
send -- "bash ~/configlank3shost.sh\r"
expect "ubuntu@\$lank3sname:~"
send -- "sudo umount /media/cdrom0\r"
expect "ubuntu@\$lank3sname:~"
send -- "sudo rm -rf /media/cdrom0\r"
expect "ubuntu@\$lank3sname:~"
send -- "rm -f ~/configlank3shost.sh\r"
expect "ubuntu@\$lank3sname:~"
send -- "exit\r"
expect "logout"
send -- "\x0F"
expect eof
EOT
)

sleep 180

exec 1>\$lank3sname-capture.log

/usr/bin/expect <(cat << EOT
set timeout 15
spawn qm terminal \$lank3sid
expect "starting serial terminal on interface serial0 (press Ctrl+O to exit)"
send -- "\r"
expect "\$lank3sname login:"
send -- "ubuntu\r"
expect "Password: "
send -- "temppass\r"
expect "ubuntu@\$lank3sname:~"
send -- "cat k3s.yaml\r"
expect "ubuntu@\$lank3sname:~"
send -- "rm -f k3s.yaml\r"
expect "ubuntu@\$lank3sname:~"
send -- "exit\r"
expect "logout"
send -- "\x0F"
expect eof
EOT
)

sed -n '/apiVersion: v1/,/ubuntu@LAN-UbuntuK3S/{ /ubuntu@LAN-UbuntuK3S/!p }' \$lank3sname-capture.log > \$lank3sname-k3s.yaml
sed -i 's/127.0.0.1/'\$lank3sip'/g' \$lank3sname-k3s.yaml
chmod 600 \$lank3sname-k3s.yaml
rm -f \$lank3sname-capture.log
EOM

cat << 'EOM' > gitlabcustomprojects/"\$2"/"\$1"/configlank3shost.sh
#!/bin/bash
fullgitlaburl=gitlab.$mgmtdomain
runnergroupname=LAN
gitlabgrouprunnertoken=gitlabgrouprunnertokenblank
lank3scorednsip=\$(echo $lank3sserviceiprangestart | cut -d . -f 1-3 | sed "s/\$/.10/g")
set -xv
#exit if internet not available
wget --timeout 10 --spider https://ubuntu.com
if [ "\$?" != "0" ]; then exit 1; fi

cat << EOT > config.yaml
cluster-cidr: $lank3spodiprangestart/$lank3spodsubnetmaskbits
service-cidr: $lank3sserviceiprangestart/$lank3sservicesubnetmaskbits
cluster-dns: \$lank3scorednsip
resolv-conf: /run/systemd/resolve/resolv.conf
EOT

sudo mkdir --parents /etc/rancher/k3s/
sudo mv config.yaml /etc/rancher/k3s/config.yaml
sudo chown 0:0 /etc/rancher/k3s/config.yaml
sudo chmod 0644 /etc/rancher/k3s/config.yaml

curl -sfL https://get.k3s.io | sh -

sleep 150

sudo kubectl --kubeconfig=/etc/rancher/k3s/k3s.yaml wait --timeout=120s --for=condition=available deployment/traefik --namespace kube-system
#helm
sudo apt-get -o DPkg::Lock::Timeout=600 update
sleep 10
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt -o DPkg::Lock::Timeout=600 install -y apt-transport-https
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get -o DPkg::Lock::Timeout=600 update
sudo apt-get -o DPkg::Lock::Timeout=600 install -y helm
sudo apt-get -o DPkg::Lock::Timeout=600 update
sudo apt-get -o DPkg::Lock::Timeout=600 install -y acpid
sudo apt-get -o DPkg::Lock::Timeout=600 update
sudo apt-get -o DPkg::Lock::Timeout=600 install -y docker.io
sudo apt-get -o DPkg::Lock::Timeout=600 upgrade
sudo cp --no-preserve=all /etc/rancher/k3s/k3s.yaml ~/k3s.yaml

#Create runner
lowercasegroupname=\$(echo "\${runnergroupname,,}")

sudo kubectl create namespace \$lowercasegroupname-runner

set +xv

echo "\$(cat /media/cdrom0/gitlab-wildcard-tls-chain.yaml)" | sed 's/namespace: .*/namespace: '"\$lowercasegroupname"'-runner/' | sudo kubectl apply -f - > /dev/null &

sudo kubectl create secret generic \$lowercasegroupname-runner --namespace \$lowercasegroupname-runner --from-literal=runner-registration-token=\$gitlabgrouprunnertoken --from-literal=runner-token=""

set -xv

sudo helm repo add gitlab https://charts.gitlab.io/

sudo helm repo update

sudo helm upgrade --debug --kubeconfig=/etc/rancher/k3s/k3s.yaml --install gitlab-runner gitlab/gitlab-runner --namespace \$lowercasegroupname-runner --set certsSecretName=gitlab-wildcard-tls-chain --set gitlabUrl=https://"\$fullgitlaburl" --set runners.secret=\$lowercasegroupname-runner --set image=gitlab/gitlab-runner:latest --set securityContext.runAsUser=999 --set securityContext.fsGroup=999 --set rbac.create=true --set runners.locked=false --set podAnnotations.gitlab.com/prometheus_scrape="true" --set podAnnotations.gitlab.com/prometheus_port=9252 --set "runners.config=[[runners]]
  [runners.kubernetes]
  image = \"gitlab/gitlab-runner:latest\""

EOM
}

gitlabcreatecicdlank3sagentforprojectandgroup () {
#Unused as KAgent's kubernetes integration and GitOps pull approach not used for one time push deployment
#Bash heredoc is sensitive to indentation so this function uses no indentation while remainder of script uses 2 spaces
mkdir gitlabcustomprojects
mkdir gitlabcustomprojects/"\$2"
mkdir gitlabcustomprojects/"\$2"/"\$1"

cat << 'EOM' > gitlabcustomprojects/"\$2"/"\$1"/.gitlab-ci.yml
variables:
  VAULT_ADDR: "https://vault.$mgmtdomain"
  VAULT_SERVER_URL: "https://vault.$mgmtdomain"
  VAULT_CACERT: "/home/gitlab-runner/vault.$mgmtdomain"
  READONLY: "readonly"
  VAULT_AUTH_ROLE: "\$CI_PROJECT_ROOT_NAMESPACE\$READONLY"
  VAULT_SECRET_PATH1: "ProxmoxUser"
  VAULT_SECRET_KEY1: "root"
  fullgitlaburl: "gitlab.$mgmtdomain"

createagent:
  stage: build
  script:
  - apt-get update
  - apt-get install gnupg2 -y
  - apt-get install lsb-release -y
  - apt-get install software-properties-common -y
  - curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
  - apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com \$(lsb_release -cs) main"
  - apt-get update
  - apt-get install vault -y
  - apt-get install --reinstall -y vault
  - apt-get install sshpass -y
  - apt-get install mkisofs -y
  - curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
  - echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
  - apt-get update
  - apt-get install -y kubectl
  - echo "\$vaultca" > "\$VAULT_CACERT"
  - export VAULT_TOKEN="\$(vault write -field=token auth/jwt/login role="\$VAULT_AUTH_ROLE" jwt=\$CI_JOB_JWT)"
  - proxmoxpass=\$(vault kv get -field="\$VAULT_SECRET_KEY1" "\$CI_PROJECT_ROOT_NAMESPACE"/"\$VAULT_SECRET_PATH1")
  - echo \$proxmoxpass | tee proxmoxpass.txt >/dev/null
  - vault kv get -field=k3s.yaml "\$CI_PROJECT_ROOT_NAMESPACE"/MGMT-UbuntuK3S-1-Kubeconfig > mgmtk3s.yaml
  - source startagent.sh
  - lank3sid=102
  - lank3sname=LAN-UbuntuK3S-1
  - sed -i 's/agenttokenblank/'\$agenttoken'/g' configagent.sh
  - sed -i 's/projectnameblank/'\$projectname'/g' configagent.sh
  - sed -i 's/pemnameblank/'\$pemname'/g' configagent.sh
  - mkdir lanagent
  - cp configagent.sh lanagent/configagent.sh
  - cp \$pemname lanagent/\$pemname
  - mkisofs -r -l -o configagent.iso lanagent
  - sshpass -f proxmoxpass.txt scp -o StrictHostKeyChecking=no configagent.iso root@pve1.$mgmtdomain:/var/lib/vz/template/iso/configagent.iso
  - sed -i 's/lank3sidblank/'\$lank3sid'/g' createagent.sh
  - sed -i 's/lank3snameblank/'\$lank3sname'/g' createagent.sh
  - sed -i 's/pemnameblank/'\$pemname'/g' createagent.sh
  - sshpass -f proxmoxpass.txt scp -o StrictHostKeyChecking=no createagent.sh root@pve1.$mgmtdomain:~/createagent.sh
  - sshpass -f proxmoxpass.txt ssh -o StrictHostKeyChecking=no root@pve1.$mgmtdomain 'bash createagent.sh'
  - sshpass -f proxmoxpass.txt ssh -o StrictHostKeyChecking=no root@pve1.$mgmtdomain 'rm -f /var/lib/vz/template/iso/configagent.iso'
  #escape exclamation mark from bash so that it can be used in ruby console 
  - exclaim='!'
  - kubectl --kubeconfig=mgmtk3s.yaml --namespace gitlab exec -it "\$gitlabtoolboxpod" -- /srv/gitlab/bin/rails runner "token = PersonalAccessToken.find_by_token('\$gitlabtemppersonalaccesstoken'); token.revoke\$exclaim"
  - rm -f \$pemname
  - rm -f mgmtk3s.yaml
EOM

cat << 'EOM' > gitlabcustomprojects/"\$2"/"\$1"/createagent.sh
#!/bin/bash
lank3sid=lank3sidblank
lank3sname=lank3snameblank
pemname=pemnameblank

qm set \$lank3sid --ide1 local:iso/configagent.iso,media=cdrom
qm shutdown \$lank3sid --timeout 600
qm wait \$lank3sid
qm start \$lank3sid
sleep 60


/usr/bin/expect <(cat << EOT
set timeout 600
spawn qm terminal \$lank3sid
expect "starting serial terminal on interface serial0 (press Ctrl+O to exit)"
send -- "\r"
expect "\$lank3sname login:"
send -- "ubuntu\r"
expect "Password: "
send -- "temppass\r"
expect "ubuntu@\$lank3sname:~"
send -- "sudo mkdir /media/cdrom0\r"
expect "ubuntu@\$lank3sname:~"
send -- "sudo mount /dev/sr0 /media/cdrom0\r"
expect "ubuntu@\$lank3sname:~"
send -- "cp /media/cdrom0/configagent.sh ~/configagent.sh\r"
expect "ubuntu@\$lank3sname:~"
send -- "sudo cp /media/cdrom0/\$pemname ~/\$pemname\r"
expect "ubuntu@\$lank3sname:~"
send -- "bash ~/configagent.sh\r"
expect "ubuntu@\$lank3sname:~"
send -- "sudo umount /media/cdrom0\r"
expect "ubuntu@\$lank3sname:~"
send -- "sudo rm -rf /media/cdrom0\r"
expect "ubuntu@\$lank3sname:~"
send -- "rm -f ~/configagent.sh\r"
expect "ubuntu@\$lank3sname:~"
send -- "exit\r"
expect "logout"
send -- "\x0F"
expect eof
EOT
)

qm set \$lank3sid --delete ide1
rm -f /var/lib/vz/template/iso/configagent.iso
rm -f createagent.sh
EOM

cat << 'EOM' > gitlabcustomprojects/"\$2"/"\$1"/configagent.sh
#!/bin/bash
mgmtdomain=$mgmtdomain
fullgitlaburl=gitlab.$mgmtdomain
agenttoken=agenttokenblank
projectname=projectnameblank
kasaddress=kas.$mgmtdomain
pemname=pemnameblank

lowercasereponame=\$(echo "\${projectname,,}")

sudo apt-get install docker.io -y

sudo kubectl create namespace \$lowercasereponame

sleep 10

sudo kubectl --namespace \$lowercasereponame create configmap \$lowercasereponame-ca-pemstore --from-file="\$pemname"

sudo docker run --pull=always --rm registry.gitlab.com/gitlab-org/cluster-integration/gitlab-agent/cli:stable generate --name-prefix \$lowercasereponame --agent-token=\$agenttoken --kas-address=wss://\$kasaddress --agent-version stable --namespace \$lowercasereponame | tee agent.yaml >/dev/null

volumemountinsertline1=\$(sed -n /'volumeMounts:'/= agent.yaml)
volumemountinsertline=\$((volumemountinsertline1+1))
sed -i ''"\$volumemountinsertline"'i\          subPath: '"\$pemname"'\' agent.yaml
sed -i ''"\$volumemountinsertline"'i\          name: ca-pemstore-volume\' agent.yaml
sed -i ''"\$volumemountinsertline"'i\        - mountPath: /etc/ssl/certs/'"\$pemname"'\' agent.yaml

volumesinsertline1=\$(sed -n /'volumes:'/= agent.yaml)
volumesinsertline=\$((volumesinsertline1+1))
sed -i ''"\$volumesinsertline"'i\            path: '"\$pemname"'\' agent.yaml
sed -i ''"\$volumesinsertline"'i\          - key: '"\$pemname"'\' agent.yaml
sed -i ''"\$volumesinsertline"'i\          items:\' agent.yaml
sed -i ''"\$volumesinsertline"'i\          name: '"\$lowercasereponame"'-ca-pemstore\' agent.yaml
sed -i ''"\$volumesinsertline"'i\        configMap:\' agent.yaml
sed -i ''"\$volumesinsertline"'i\      - name: ca-pemstore-volume\' agent.yaml

sudo kubectl apply -f agent.yaml
sudo rm -f agent.yaml
EOM

cat << 'EOM' > gitlabcustomprojects/"\$2"/"\$1"/startagent.sh
#!/bin/bash
#projectname must have no spaces
projectname=CodeServer1
projectgroup=LAN
landomain=$landomain
fullgitlaburl=gitlab.$mgmtdomain
pemname="gitlab.$mgmtdomain.ca.pem"

gitlabtoolboxpod=\$(kubectl --kubeconfig=mgmtk3s.yaml --namespace gitlab get pods -o name |  awk '{if (\$1 ~ "gitlab-toolbox-") print \$0}')

gitlabtoolboxpod=\${gitlabtoolboxpod#"pod/"}
gitlabtemppersonalaccesstoken=\$(openssl rand -hex 10)

kubectl --kubeconfig=mgmtk3s.yaml --namespace gitlab exec -it "\$gitlabtoolboxpod" -- /srv/gitlab/bin/rails runner "token = User.find_by_username('root').personal_access_tokens.create(scopes: [:api, :read_user, :read_api, :read_repository, :write_repository, :read_registry, :write_registry, :sudo], name: 'GitOpsBoxtemptoken'); token.set_token('\$gitlabtemppersonalaccesstoken'); token.save;"

kubectl --kubeconfig=mgmtk3s.yaml get secret gitlab-wildcard-tls-ca --namespace gitlab -ojsonpath='{.data.cfssl_ca}' | base64 --decode > "\$pemname"

#run in mgmt for accesstoken and pemname file. if these are provided as secrets in LAN Vault then this repo could be run under LAN
gitlabprojectid=\$(curl --insecure --header "PRIVATE-TOKEN: \$gitlabtemppersonalaccesstoken" -X GET https://\$fullgitlaburl/api/v4/projects/\$projectgroup%2F\$projectname | grep -o -P '(?<={"id":).*(?=,"description":)')

lowercasereponame=\$(echo "\${projectname,,}")

#create config file for agent under project
curl --insecure --header "PRIVATE-TOKEN: \$gitlabtemppersonalaccesstoken" -X POST --data branch="main" --data content="" --data commit_message="GitOpsBox project creation" "https://\$fullgitlaburl/api/v4/projects/\$gitlabprojectid/repository/files/%2Egitlab%2Fagents%2F\$lowercasereponame-agent%2Fconfig%2Eyaml"

graphqlcreateclusteragent=\$(cat << EOT
mutation createAgent {
  createClusterAgent(input: { projectPath: \"\$projectgroup/\$projectname\", name: \"\$lowercasereponame-agent\" }) {
    clusterAgent {
      id
      name
    }
    errors
  }
}
EOT
)

graphqlcreateclusteragent="\$(echo \$graphqlcreateclusteragent)"

createclusteragent=\$(curl --insecure --header "Authorization: Bearer \$gitlabtemppersonalaccesstoken" --header "Content-Type: application/json" -X POST -d "{ \"query\": \"\$graphqlcreateclusteragent\"}" "https://\$fullgitlaburl/api/graphql")

clusteragentgid=\$(echo "\$createclusteragent" | grep -o -P '(?<=id":").*(?=","name)')

gitlabagentnametoken=\$lowercasereponame"-agenttoken"

graphqlclusteragenttokencreate=\$(cat  << EOT
mutation createToken {
  clusterAgentTokenCreate(input: { clusterAgentId: \"\$clusteragentgid\", name: \"\$gitlabagentnametoken\" }) {
    secret
    token {
      createdAt
      id
    }
    errors
  }
}
EOT
)

graphqlclusteragenttokencreate="\$(echo \$graphqlclusteragenttokencreate)"

createagenttoken=\$(curl --insecure --header "Authorization: Bearer \$gitlabtemppersonalaccesstoken" --header "Content-Type: application/json" -X POST -d "{ \"query\": \"\$graphqlclusteragenttokencreate\"}" "https://\$fullgitlaburl/api/graphql")

agenttoken=\$(echo "\$createagenttoken" | grep -o -P '(?<=secret":").*(?=","token":)')
EOM
}

gitlabcreatecicdlancodeserverforprojectandgroup () {
#Bash heredoc is sensitive to indentation so this function uses no indentation while remainder of script uses 2 spaces
mkdir gitlabcustomprojects
mkdir gitlabcustomprojects/"\$2"
mkdir gitlabcustomprojects/"\$2"/"\$1"

cat << 'EOM' > gitlabcustomprojects/"\$2"/"\$1"/.gitlab-ci.yml
variables:
  VAULT_ADDR: "https://vault.$mgmtdomain"
  VAULT_SERVER_URL: "https://vault.$mgmtdomain"
  VAULT_CACERT: "/home/gitlab-runner/vault.$mgmtdomain"
  FULLACCESS: "fullaccess"
  VAULT_AUTH_ROLE: "\$CI_PROJECT_ROOT_NAMESPACE\$FULLACCESS"
  mgmtdomain: "$mgmtdomain"
  fullgitlaburl: "gitlab.$mgmtdomain"
  codeurl: "code.$landomain"
  pemname: "gitlab.$mgmtdomain.ca.pem"
  removesudofromcodeuser: "yes"

createcodeserver:
  stage: build
  when: delayed
  start_in: 30 minutes
  retry: 2
  script:
  - apt-get update
  - apt-get install gnupg2 -y
  - apt-get install lsb-release -y
  - apt-get install software-properties-common -y
  - curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
  - apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com \$(lsb_release -cs) main"
  - apt-get update
  - apt-get install vault -y
  - apt-get install --reinstall -y vault
  - curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
  - echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
  - apt-get update
  - apt-get install -y kubectl
  - apt-get -o DPkg::Lock::Timeout=600 update
  - sleep 10
  - curl https://baltocdn.com/helm/signing.asc | apt-key add -
  - apt -o DPkg::Lock::Timeout=600 install -y apt-transport-https
  - echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
  - apt-get -o DPkg::Lock::Timeout=600 update
  - apt-get -o DPkg::Lock::Timeout=600 install -y helm
  - apt-get -o DPkg::Lock::Timeout=600 update
  - echo "\$vaultca" > "\$VAULT_CACERT"
  - export VAULT_TOKEN="\$(vault write -field=token auth/jwt/login role="\$VAULT_AUTH_ROLE" jwt=\$CI_JOB_JWT)"
  - vault kv get -field=k3s.yaml "\$CI_PROJECT_ROOT_NAMESPACE"/LAN-UbuntuK3S-1-Kubeconfig > lank3s.yaml
  - vault kv get -field=\$pemname "\$CI_PROJECT_ROOT_NAMESPACE"/Gitlab-CA > \$pemname
  - git clone https://github.com/coder/code-server
  - openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout \$codeurl.key -out \$codeurl.crt -subj "/CN=\$codeurl"
  - kubectl --kubeconfig=lank3s.yaml create namespace codeserver
  - kubectl --kubeconfig=lank3s.yaml create secret tls \$codeurl --key \$codeurl.key --cert \$codeurl.crt --namespace codeserver
  - |
    cat << EOT > settings.json
    {
    "workbench.enableExperiments": false,
    "workbench.settings.enableNaturalLanguageSearch": false,
    "telemetry.telemetryLevel": "off"
    }
    EOT
  - |
    cat << EOT > codeservervalues.yaml
    ingress:
      enabled: true
      hosts:
      - host: \$codeurl
        paths:
          - /
      tls:
        - secretName: \$codeurl
          hosts:
            - \$codeurl
    extraVars:
      - name: DISABLE_TELEMETRY
        value: "true"
      - name: EXTENSIONS_GALLERY
        value: '{"serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery", "cacheUrl": "https://vscode.blob.core.windows.net/gallery/index", "itemUrl": "https://marketplace.visualstudio.com/items", "controlUrl": "", "recommendationsUrl": ""}'
    extraArgs:
      - --disable-telemetry
    EOT
  - helm --kubeconfig=lank3s.yaml upgrade --install code-server code-server/ci/helm-chart --namespace codeserver -f codeservervalues.yaml
  - kubectl --kubeconfig=lank3s.yaml wait --timeout=3600s --for=condition=available deployment/code-server --namespace codeserver
  - codeserverpodname=\$(kubectl --kubeconfig=lank3s.yaml get pods -o jsonpath="{.items[0].metadata.name}" --namespace codeserver)
  - kubectl --kubeconfig=lank3s.yaml --namespace codeserver cp settings.json \$codeserverpodname:/home/coder/.local/share/code-server/User/settings.json
  - kubectl --kubeconfig=lank3s.yaml --namespace codeserver cp \$pemname \$codeserverpodname:/tmp/\$pemname
  - kubectl --kubeconfig=lank3s.yaml --namespace codeserver exec -it "\$codeserverpodname" -- sudo mv /tmp/\$pemname /etc/ssl/certs/\$pemname
  #remove sudo from coder user, root account is disabled from password login so root access is disabled in this pod
  - if [[ "\$removesudofromcodeuser" = "yes" ]]; then kubectl --kubeconfig=lank3s.yaml --namespace codeserver exec -it "\$codeserverpodname" -- sudo rm -f /etc/sudoers.d/nopasswd; fi
  - rm -f codeservervalues.yaml
  - rm -f settings.json
  - rm -rf code-server
  - rm -f \$codeurl.key
  - rm -f \$codeurl.crt
  - rm -f \$pemname
  - kubectl --kubeconfig=lank3s.yaml get secret --namespace codeserver code-server -o jsonpath="{.data.password}" | base64 --decode > codepassword.txt
  - export VAULT_TOKEN="\$(vault write -field=token auth/jwt/login role="\$VAULT_AUTH_ROLE" jwt=\$CI_JOB_JWT)"
  - vault kv put "\$CI_PROJECT_ROOT_NAMESPACE"/code-server-password password=@codepassword.txt
  - rm -f codepassword.txt
EOM
}

gitlabcreatecicdnewrepowithagentforprojectandgroup () {
#Bash heredoc is sensitive to indentation so this function uses no indentation while remainder of script uses 2 spaces
mkdir gitlabcustomprojects
mkdir gitlabcustomprojects/"\$2"
mkdir gitlabcustomprojects/"\$2"/"\$1"

cat << 'EOM' > gitlabcustomprojects/"\$2"/"\$1"/.gitlab-ci.yml
#Run this pipeline manually and provide new project name and existing group to create a new project with agent.
workflow:
  rules:
    - if: '\$CI_PIPELINE_SOURCE == "web"'
variables:
  VAULT_ADDR: "https://vault.$mgmtdomain"
  VAULT_SERVER_URL: "https://vault.$mgmtdomain"
  VAULT_CACERT: "/home/gitlab-runner/vault.$mgmtdomain"
  READONLY: "readonly"
  VAULT_AUTH_ROLE: "\$CI_PROJECT_ROOT_NAMESPACE\$READONLY"
  VAULT_SECRET_PATH1: "ProxmoxUser"
  VAULT_SECRET_KEY1: "root"
  fullgitlaburl: "gitlab.$mgmtdomain"
  mgmtdomain: "$mgmtdomain"
  pemname: "gitlab.$mgmtdomain.ca.pem"
  NEWPROJECTNAME:
    value: "newproject"
    description: "Name for new project/repository to be created under the LAN group. Do not use spaces in project name."
  NEWPROJECTGROUP:
    value: "LANorManagement"
    description: "Name for existing group for new project to be created under. Default groups are LAN or Management."  

createprojectwithagent:
  stage: build
  script:
  - apt-get update
  - apt-get install gnupg2 -y
  - apt-get install lsb-release -y
  - apt-get install software-properties-common -y
  - curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
  - apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com \$(lsb_release -cs) main"
  - apt-get update
  - apt-get install vault -y
  - apt-get install --reinstall -y vault
  - apt-get install sshpass -y
  - apt-get install mkisofs -y
  - curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
  - echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
  - apt-get update
  - apt-get install -y kubectl
  - echo "\$vaultca" > "\$VAULT_CACERT"
  - export VAULT_TOKEN="\$(vault write -field=token auth/jwt/login role="\$VAULT_AUTH_ROLE" jwt=\$CI_JOB_JWT)"
  - vault kv get -field=k3s.yaml "\$CI_PROJECT_ROOT_NAMESPACE"/MGMT-UbuntuK3S-1-Kubeconfig > mgmtk3s.yaml
  - vault kv get -field="\$VAULT_SECRET_KEY1" "\$CI_PROJECT_ROOT_NAMESPACE"/"\$VAULT_SECRET_PATH1" > proxmoxpass.txt
  - if [[ "\$NEWPROJECTGROUP" = "LAN" ]]; then lank3spass=\$(vault kv get -field=ubuntu LAN/LAN-UbuntuK3S-1-ubuntu-password); fi
  - if [[ "\$NEWPROJECTGROUP" = "LAN" ]]; then vault kv get -field=\$pemname LAN/Gitlab-CA > \$pemname; fi
  - source startagent.sh
  - if [[ "\$NEWPROJECTGROUP" = "LAN" ]]; then sed -i 's/agenttokenblank/'\$agenttoken'/g' configagentlan.sh; fi
  - if [[ "\$NEWPROJECTGROUP" = "LAN" ]]; then sed -i 's/projectnameblank/'\$NEWPROJECTNAME'/g' configagentlan.sh; fi
  - if [[ "\$NEWPROJECTGROUP" = "LAN" ]]; then mkdir lanagent; fi
  - if [[ "\$NEWPROJECTGROUP" = "LAN" ]]; then cp configagentlan.sh lanagent/configagentlan.sh; fi
  - if [[ "\$NEWPROJECTGROUP" = "LAN" ]]; then cp \$pemname lanagent/\$pemname; fi
  - if [[ "\$NEWPROJECTGROUP" = "LAN" ]]; then mkisofs -r -o configagent.iso lanagent; fi
  - if [[ "\$NEWPROJECTGROUP" = "LAN" ]]; then sshpass -f proxmoxpass.txt scp -o StrictHostKeyChecking=no configagent.iso root@pve1.$mgmtdomain:/var/lib/vz/template/iso/configagent.iso; fi
  - set +xv
  - if [[ "\$NEWPROJECTGROUP" = "LAN" ]]; then sed -i 's/lank3spassblank/'\$lank3spass'/g' createagentlan.sh; fi
  - set -xv
  - if [[ "\$NEWPROJECTGROUP" = "LAN" ]]; then sshpass -f proxmoxpass.txt scp -o StrictHostKeyChecking=no createagentlan.sh root@pve1.$mgmtdomain:~/createagentlan.sh; fi
  - if [[ "\$NEWPROJECTGROUP" = "LAN" ]]; then sshpass -f proxmoxpass.txt ssh -o StrictHostKeyChecking=no root@pve1.$mgmtdomain 'bash createagentlan.sh'; fi
  - if [[ "\$NEWPROJECTGROUP" = "LAN" ]]; then sshpass -f proxmoxpass.txt ssh -o StrictHostKeyChecking=no root@pve1.$mgmtdomain 'rm -f /var/lib/vz/template/iso/configagent.iso'; fi
  - if [[ "\$NEWPROJECTGROUP" = "Management" ]]; then sed -i 's/projectnameblank/'\$NEWPROJECTNAME'/g' configagentmgmt.sh; fi
  - if [[ "\$NEWPROJECTGROUP" = "Management" ]]; then sed -i 's/agenttokenblank/'\$agenttoken'/g' configagentmgmt.sh; fi
  - if [[ "\$NEWPROJECTGROUP" = "Management" ]]; then sshpass -f proxmoxpass.txt scp -o StrictHostKeyChecking=no createagentmgmt.sh root@pve1.$mgmtdomain:~/createagentmgmt.sh; fi
  - if [[ "\$NEWPROJECTGROUP" = "Management" ]]; then sshpass -f proxmoxpass.txt scp -o StrictHostKeyChecking=no configagentmgmt.sh root@pve1.$mgmtdomain:~/configagentmgmt.sh; fi
  - if [[ "\$NEWPROJECTGROUP" = "Management" ]]; then sshpass -f proxmoxpass.txt ssh -o StrictHostKeyChecking=no root@pve1.$mgmtdomain 'bash createagentmgmt.sh'; fi
  #escape exclamation mark from bash so that it can be used in ruby console 
  - exclaim='!'
  - kubectl --kubeconfig=mgmtk3s.yaml --namespace gitlab exec -it "\$gitlabtoolboxpod" -- /srv/gitlab/bin/rails runner "token = PersonalAccessToken.find_by_token('\$gitlabtemppersonalaccesstoken'); token.revoke\$exclaim"
  - rm -f mgmtk3s.yaml
  - rm -f proxmoxpass.txt
EOM

cat << 'EOM' > gitlabcustomprojects/"\$2"/"\$1"/createagentlan.sh
#!/bin/bash
lank3sname=LAN-UbuntuK3S-1
pemname="gitlab.$mgmtdomain.ca.pem"
lank3spass=lank3spassblank

lank3sid=\$(qm list | grep LAN-UbuntuK3S-1 | grep -Eo '[0-9]{1,}' | head -1)

qm set \$lank3sid --ide1 local:iso/configagent.iso,media=cdrom
qm shutdown \$lank3sid --timeout 600
qm wait \$lank3sid
qm start \$lank3sid
sleep 60

/usr/bin/expect <(cat << EOT
set timeout 600
spawn qm terminal \$lank3sid
expect "starting serial terminal on interface serial0 (press Ctrl+O to exit)"
send -- "\r"
expect "\$lank3sname login:"
send -- "ubuntu\r"
expect "Password: "
send -- "\$lank3spass\r"
expect "ubuntu@\$lank3sname:~"
send -- "sudo mkdir /media/cdrom0\r"
expect "ubuntu@\$lank3sname:~"
send -- "sudo mount /dev/sr0 /media/cdrom0\r"
expect "ubuntu@\$lank3sname:~"
send -- "cp /media/cdrom0/configagentlan.sh ~/configagentlan.sh\r"
expect "ubuntu@\$lank3sname:~"
send -- "bash ~/configagentlan.sh\r"
expect "ubuntu@\$lank3sname:~"
send -- "sudo umount /media/cdrom0\r"
expect "ubuntu@\$lank3sname:~"
send -- "sudo rm -rf /media/cdrom0\r"
expect "ubuntu@\$lank3sname:~"
send -- "exit\r"
expect "logout"
send -- "\x0F"
expect eof
EOT
)

qm set \$lank3sid --delete ide1
rm -f /var/lib/vz/template/iso/configagent.iso
rm -f createagentlan.sh
EOM

cat << 'EOM' > gitlabcustomprojects/"\$2"/"\$1"/configagentlan.sh
#!/bin/bash
mgmtdomain=$mgmtdomain
fullgitlaburl=gitlab.$mgmtdomain
agenttoken=agenttokenblank
projectname=projectnameblank
kasaddress=kas.$mgmtdomain
pemname=gitlab.$mgmtdomain.ca.pem

lowercasereponame=\$(echo "\${projectname,,}")

sudo kubectl create namespace \$lowercasereponame

sudo cp /media/cdrom0/\$pemname ~/\$pemname

sleep 10

sudo kubectl --namespace \$lowercasereponame create configmap \$lowercasereponame-ca-pemstore --from-file="\$pemname"

sudo docker run --pull=always --rm registry.gitlab.com/gitlab-org/cluster-integration/gitlab-agent/cli:stable generate --name-prefix \$lowercasereponame --agent-token=\$agenttoken --kas-address=wss://\$kasaddress --agent-version stable --namespace \$lowercasereponame | tee agent.yaml >/dev/null

volumemountinsertline1=\$(sed -n /'volumeMounts:'/= agent.yaml)
volumemountinsertline=\$((volumemountinsertline1+1))
sed -i ''"\$volumemountinsertline"'i\          subPath: '"\$pemname"'\' agent.yaml
sed -i ''"\$volumemountinsertline"'i\          name: ca-pemstore-volume\' agent.yaml
sed -i ''"\$volumemountinsertline"'i\        - mountPath: /etc/ssl/certs/'"\$pemname"'\' agent.yaml

volumesinsertline1=\$(sed -n /'volumes:'/= agent.yaml)
volumesinsertline=\$((volumesinsertline1+1))
sed -i ''"\$volumesinsertline"'i\            path: '"\$pemname"'\' agent.yaml
sed -i ''"\$volumesinsertline"'i\          - key: '"\$pemname"'\' agent.yaml
sed -i ''"\$volumesinsertline"'i\          items:\' agent.yaml
sed -i ''"\$volumesinsertline"'i\          name: '"\$lowercasereponame"'-ca-pemstore\' agent.yaml
sed -i ''"\$volumesinsertline"'i\        configMap:\' agent.yaml
sed -i ''"\$volumesinsertline"'i\      - name: ca-pemstore-volume\' agent.yaml

sudo kubectl apply -f agent.yaml
sudo rm -f agent.yaml
rm -f \$pemname
rm -f configagentlan.sh
EOM


cat << 'EOM' > gitlabcustomprojects/"\$2"/"\$1"/createagentmgmt.sh
#!/bin/bash
#findqmid
mgmtk3sid=\$(qm list | grep MGMT-UbuntuK3S-1 | grep -Eo '[0-9]{1,}' | head -1)
#findVMip
mgmtk3sip=\$(qm config \$mgmtk3sid | grep ipconfig0 | grep -o -P '(?<=ip=).*(?=/)')

scp -o StrictHostKeyChecking=no configagentmgmt.sh ubuntu@\$mgmtk3sip:~/configagentmgmt.sh

ssh -o StrictHostKeyChecking=no ubuntu@\$mgmtk3sip /bin/bash << EOT
bash "configagentmgmt.sh"
exit
EOT

rm -f configagentmgmt.sh
rm -f createagentmgmt.sh
EOM

cat << 'EOM' > gitlabcustomprojects/"\$2"/"\$1"/configagentmgmt.sh
#!/bin/bash
kasaddress=kas.$mgmtdomain
projectname=projectnameblank
agenttoken=agenttokenblank
pemname=gitlab.$mgmtdomain.ca.pem

lowercasereponame=\$(echo "\${projectname,,}")

sudo kubectl create namespace \$lowercasereponame

sleep 10

sudo kubectl get secret gitlab-wildcard-tls-ca --namespace gitlab -ojsonpath='{.data.cfssl_ca}' | base64 --decode > "\$pemname"

sudo kubectl --namespace \$lowercasereponame create configmap \$lowercasereponame-ca-pemstore --from-file="\$pemname"

sudo docker run --pull=always --rm registry.gitlab.com/gitlab-org/cluster-integration/gitlab-agent/cli:stable generate --name-prefix \$lowercasereponame --agent-token=\$agenttoken --kas-address=wss://\$kasaddress --agent-version stable --namespace \$lowercasereponame | tee agent.yaml >/dev/null

volumemountinsertline1=\$(sed -n /'volumeMounts:'/= agent.yaml)
volumemountinsertline=\$((volumemountinsertline1+1))
sed -i ''"\$volumemountinsertline"'i\          subPath: '"\$pemname"'\' agent.yaml
sed -i ''"\$volumemountinsertline"'i\          name: ca-pemstore-volume\' agent.yaml
sed -i ''"\$volumemountinsertline"'i\        - mountPath: /etc/ssl/certs/'"\$pemname"'\' agent.yaml

volumesinsertline1=\$(sed -n /'volumes:'/= agent.yaml)
volumesinsertline=\$((volumesinsertline1+1))
sed -i ''"\$volumesinsertline"'i\            path: '"\$pemname"'\' agent.yaml
sed -i ''"\$volumesinsertline"'i\          - key: '"\$pemname"'\' agent.yaml
sed -i ''"\$volumesinsertline"'i\          items:\' agent.yaml
sed -i ''"\$volumesinsertline"'i\          name: '"\$lowercasereponame"'-ca-pemstore\' agent.yaml
sed -i ''"\$volumesinsertline"'i\        configMap:\' agent.yaml
sed -i ''"\$volumesinsertline"'i\      - name: ca-pemstore-volume\' agent.yaml

sudo kubectl apply -f agent.yaml
rm -f agent.yaml
rm -f \$pemname
rm -f configagentmgmt.sh
EOM

cat << 'EOM' > gitlabcustomprojects/"\$2"/"\$1"/startagent.sh
#!/bin/bash
mgmtdomain=$mgmtdomain
fullgitlaburl=gitlab.$mgmtdomain
set -xv

gitlabtoolboxpod=\$(kubectl --kubeconfig=mgmtk3s.yaml --namespace gitlab get pods -o name |  awk '{if (\$1 ~ "gitlab-toolbox-") print \$0}')

gitlabtoolboxpod=\${gitlabtoolboxpod#"pod/"}
gitlabtemppersonalaccesstoken=\$(openssl rand -hex 10)

kubectl --kubeconfig=mgmtk3s.yaml --namespace gitlab exec -it "\$gitlabtoolboxpod" -- /srv/gitlab/bin/rails runner "token = User.find_by_username('root').personal_access_tokens.create(scopes: [:api, :read_user, :read_api, :read_repository, :write_repository, :read_registry, :write_registry, :sudo], name: 'GitOpsBoxtemptoken'); token.set_token('\$gitlabtemppersonalaccesstoken'); token.save;"

kubectl --kubeconfig=mgmtk3s.yaml get secret gitlab-wildcard-tls-ca --namespace gitlab -ojsonpath='{.data.cfssl_ca}' | base64 --decode > "\$pemname"

gitlabgroupid=\$(curl --insecure --header "PRIVATE-TOKEN: \$gitlabtemppersonalaccesstoken" -X GET https://\$fullgitlaburl/api/v4/groups?search=\$NEWPROJECTGROUP | grep -o -P '(?<={"id":).*(?=,"web_url":)')

curl --silent --insecure --header "PRIVATE-TOKEN: \$gitlabtemppersonalaccesstoken" -X POST "https://\$fullgitlaburl/api/v4/projects?name=\$NEWPROJECTNAME&namespace_id=\$gitlabgroupid&initialize_with_readme=true" > /dev/null

gitlabprojectid=\$(curl --insecure --header "PRIVATE-TOKEN: \$gitlabtemppersonalaccesstoken" -X GET https://\$fullgitlaburl/api/v4/projects/\$NEWPROJECTGROUP%2F\$NEWPROJECTNAME | grep -o -P '(?<={"id":).*(?=,"description":)')

lowercasereponame=\$(echo "\${NEWPROJECTNAME,,}")

#create config file for agent under project
curl --insecure --header "PRIVATE-TOKEN: \$gitlabtemppersonalaccesstoken" -X POST --data branch="main" --data content="" --data commit_message="GitOpsBox project creation" "https://\$fullgitlaburl/api/v4/projects/\$gitlabprojectid/repository/files/%2Egitlab%2Fagents%2F\$lowercasereponame-agent%2Fconfig%2Eyaml"

graphqlcreateclusteragent=\$(cat << EOT
mutation createAgent {
  createClusterAgent(input: { projectPath: \"\$NEWPROJECTGROUP/\$NEWPROJECTNAME\", name: \"\$lowercasereponame-agent\" }) {
    clusterAgent {
      id
      name
    }
    errors
  }
}
EOT
)

graphqlcreateclusteragent="\$(echo \$graphqlcreateclusteragent)"

createclusteragent=\$(curl --insecure --header "Authorization: Bearer \$gitlabtemppersonalaccesstoken" --header "Content-Type: application/json" -X POST -d "{ \"query\": \"\$graphqlcreateclusteragent\"}" "https://\$fullgitlaburl/api/graphql")

clusteragentgid=\$(echo "\$createclusteragent" | grep -o -P '(?<=id":").*(?=","name)')

gitlabagentnametoken=\$lowercasereponame"-agenttoken"

graphqlclusteragenttokencreate=\$(cat  << EOT
mutation createToken {
  clusterAgentTokenCreate(input: { clusterAgentId: \"\$clusteragentgid\", name: \"\$gitlabagentnametoken\" }) {
    secret
    token {
      createdAt
      id
    }
    errors
  }
}
EOT
)

graphqlclusteragenttokencreate="\$(echo \$graphqlclusteragenttokencreate)"

createagenttoken=\$(curl --insecure --header "Authorization: Bearer \$gitlabtemppersonalaccesstoken" --header "Content-Type: application/json" -X POST -d "{ \"query\": \"\$graphqlclusteragenttokencreate\"}" "https://\$fullgitlaburl/api/graphql")

agenttoken=\$(echo "\$createagenttoken" | grep -o -P '(?<=secret":").*(?=","token":)')
EOM
}

gitlabdisableautodevopsforprojectundergroup () {
curl --insecure --header "PRIVATE-TOKEN: \$gitlabtemppersonalaccesstoken" -X PUT --data "auto_devops_enabled=false" --url "https://\$fullgitlaburl/api/v4/projects/\$2%2F\$1"
}

vaultcreateforgitlabgroupsecretkeyvalue () {
#1GitlabGroup or VaultEngine
#2Path of secret
#3Key1
#4Value1 or @filename
kubectl --kubeconfig=k3s.yaml --namespace vault exec -ti \$vaultserverpodname -- vault kv put "\$1"/"\$2" "\$3"="\$4"
}

vaultcreateforgitlabgroupsecretfile () {
#1GitlabGroup or VaultEngine
#2Path of secret
#3Key1
#4Value1 or @filename
set +xv
if [[ \$4 == "k3s.yaml" ]] ; then sed -i 's/127.0.0.1/$mgmtk3siprangestart/g' \$4; fi
vaultfile=\$(cat \$4)
kubectl --kubeconfig=k3s.yaml --namespace vault exec -ti \$vaultserverpodname -- vault kv put "\$1"/"\$2" "\$3"="\$vaultfile"
set -xv
}

vaulttidyup () {
  sudo rm -f vaultservervalues.yaml
  sudo rm -f csr.conf
  sudo rm -f csr.yaml
  sudo rm -f server.csr
  sudo rm -f vault.key
  sudo rm -f vault.crt
  sudo rm -f vault.ca
  sudo rm -f vaultingressroutetcp.yaml
  sudo rm -f \$pemname
  sudo rm -f addvaultcerttorunner.yaml
}

main "\$@"
EOF

sudo mv configmgmtk3s.sh temppvebase/etc/cron.d/createvm/configmgmtk3s.sh
fi
}

createpveinterfaces() {
#Bash heredoc is sensitive to indentation so this function uses no indentation while remainder of script uses 2 spaces
cat > interfaces <<ENDOFFILE
# network interface settings; autogenerated
# Please do NOT modify this file directly, unless you know what
# you're doing.
#
# If you want to manage parts of the network configuration manually,
# please utilize the 'source' or 'source-directory' directives to do
# so.
# PVE will preserve these directives, but will NOT read its network
# configuration from sourced files, so do not attempt to move any of
# the PVE managed interfaces into external files!

auto lo
iface lo inet loopback

auto $waninterfacecard
iface $waninterfacecard inet manual

auto $laninterfacecard
iface $laninterfacecard inet manual

auto $mgmtinterfacecard
iface $mgmtinterfacecard inet manual

auto vmbr0
iface vmbr0 inet manual
        bridge-ports $waninterfacecard
        bridge-stp off
        bridge-fd 0
#WAN

auto vmbr1
iface vmbr1 inet manual
        bridge-ports $laninterfacecard
        bridge-stp off
        bridge-fd 0
        bridge-vlan-aware yes
        bridge-vids 2-4094
#LAN

auto vmbr2.$mgmtvlan
iface vmbr2.$mgmtvlan inet static
        address $pvemgmtipaddress
        netmask $mgmtsubnet
        gateway $pfsensemgmtipaddress

auto vmbr2
iface vmbr2 inet manual
        bridge-ports $mgmtinterfacecard
        bridge-stp off
        bridge-fd 0
        bridge-vlan-aware yes
        bridge-vids 2-4094
#MGMT
ENDOFFILE
}

modifyinterfacesvlan() {
  #Modify interfaces file for vLAN configuration
  if [ -z "$mgmtvlan" ]
    then
      echo "vLAN is not defined, removing vLAN config in interfaces file." >&3
      pvevlan_start_line=$(sed -n /'auto vmbr2.'/= interfaces)
      pvevlan_end_line=$(sed -n /'        gateway '"$pfsensemgmtipaddress"''/= interfaces)
      pvevlan_end_line2=$(($pvevlan_end_line+1))
      sed -i ''"$pvevlan_start_line"','"$pvevlan_end_line2"'d' interfaces
      pvevmbr2_start_line=$(sed -n /'iface vmbr2 inet manual'/= interfaces)
      pvevmbr2_insert_line=$(($pvevmbr2_start_line+1))
      sed -i ''"$pvevmbr2_insert_line"'i\        gateway '"$pfsensemgmtipaddress"'\' interfaces
      sed -i ''"$pvevmbr2_insert_line"'i\        netmask '"$mgmtsubnet"'\' interfaces
      sed -i ''"$pvevmbr2_insert_line"'i\        address '"$pvemgmtipaddress"'\' interfaces
      sed -i ' s/iface vmbr2 inet manual/iface vmbr2 inet static/g' interfaces  
    else
      echo "vLAN is defined, preserving vlan config in interfaces file." >&3
  fi

  sudo mv interfaces temppvebase/etc/network/interfaces
}

remasterpveiso() {
  #Remaster squashfs
  echo "Remastering Proxmox iso..." >&3
  sudo rm tempiso/pve-installer.squashfs
  sudo mksquashfs temppveinstall tempiso/pve-installer.squashfs -comp xz -quiet >&3
  sudo rm tempiso/pve-base.squashfs
  sudo mksquashfs temppvebase tempiso/pve-base.squashfs -comp xz -quiet >&3
  #remaster iso
  dd if=$latestpveiso bs=512 count=1 of=proxmox.mbr
  isodate=$(date +"%Y_%m_%d_%H%M")
  finalisoname=$(date +"%Y_%m_%d_%H%M""_GitOpsBox_"$latestpveiso)
  xorriso -as mkisofs -o $finalisoname -r -V 'PVE' --grub2-mbr proxmox.mbr --protective-msdos-label -efi-boot-part --efi-boot-image -c '/boot/boot.cat' -b '/boot/grub/i386-pc/eltorito.img' -no-emul-boot -boot-load-size 4 -boot-info-table --grub2-boot-info --efi-boot '/efi.img' -eltorito-alt-boot -hfsplus -apm-block-size 2048 -e /System/Library/CoreServices/boot.efi -no-emul-boot tempiso/ >&3
  #cleanup
  sudo rm -r tempiso
  sudo rm -r pfconfig
  sudo rm -r temppveinstall
  sudo rm -r temppvebase
  sudo rm tempurllist*.txt
  sudo rm proxinstall
  sudo rm proxmox.mbr
  sudo rm pfconfig.iso
  sudo rm customoptions.txt
  sudo rm disablesidwan.txt
  sudo rm "$latestpfsiso"
  sudo rm wget-log

  if [ "$deletebaseiso" = "yes" ]; then
    echo "Deleting base iso's" >&3
    sudo rm "$latestpveiso"
    sudo rm "$latestpfsisogz"
  fi
}

promptusbcreation() {
  echo "################################################################################" >&3
  echo "$finalisoname created." >&3
  echo "1. Identify USB drive to format and copy iso" >&3
  echo "2. Launch Disks utility to manually create the USB with restore disk image option (Recommended)" >&3
  echo "Any other key will exit." >&3
  read -s -n1 doit15
  case $doit15 in
    1) ;;
    2) sudo /usr/bin/gnome-disks --restore-disk-image="$finalisoname" & exit ;;
    *) exit ;;
  esac
  devicename=$(sudo fdisk --list -o device | tail -1)
  shortdevicename=$(echo $devicename | sed 's/[0-9]\+$//')
  echo >&3
  echo "************IDENTIFIED USB************" >&3
  sudo fdisk "$shortdevicename" --list >&3
  echo "************IDENTIFIED USB************" >&3
  echo >&3
  echo "1. Wipe and create bootable drive on $shortdevicename." >&3
  echo "2. Launch Disks utility to manually create the USB with restore disk image option (Recommended)" >&3
  echo "Any other key will exit." >&3
  read -s -n1 doit16
  case $doit16 in
    1) ;;
    2) sudo /usr/bin/gnome-disks --restore-disk-image="$finalisoname" & exit ;;
    *) exit ;;
  esac
  sudo umount "$shortdevicename"?*
  echo "Writing iso to $shortdevicename" >&3
  sudo dd bs=512 if="$finalisoname" of="$shortdevicename" status=progress oflag=sync >&3
}

main "$@"
