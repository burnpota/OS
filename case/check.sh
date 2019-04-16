#!/bin/bash

# VAR
VENDOR=`dmidecode  -t1 | grep -i "Product Name"`
RELEASE=`cat /etc/redhat-release  | awk '{print $7}' | awk -F. '{print $1}'`
KERNEL_CMDLINE=`cat /proc/cmdline`
GENERATION=`dmidecode -t1 | grep -i product | awk '{print $NF}'`
PRODUCT=`dmidecode -t1 | grep -i product | awk -F: '{print $2}' | awk '{print $1}'`
TOTALMEM=`cat /proc/meminfo | grep -i MemTotal | awk '{print $2}'`
UNAME_MAJOR=`uname -r | awk -F \- '{print $2}' | awk -F \. '{print $1}'`
UNMAE_MINOR=`uname -r | awk -F \- '{print $2}' | awk -F \. '{print $2}'`
UNAME_EUS=`uname -r | awk -F \- '{print $2}' | awk -F \. '{print $3}'`

   if [ $RELEASE == "6" ]
   then
      service_db=("kdump" "ntpd" "rpcbind" "multipathd" "netfs" "nfsd")

      update_patch_db=(\
      "yum-utils-1.1.30-42.el6_10.noarch" \
      "procps-3.2.8-45.el6_9.3.x86_64" \
      "patch-2.6-8.el6_9.x86_64" \
      "microcode_ctl-1.17-25.4.el6_9.x86_64" \
      "librelp-1.2.7-3.el6_9.1.x86_64")

      current_patch_db=(\
      "^yum-utils-1" \
      "^procps-3" \
      "^patch-2" \
      "^microcode_ctl-1" \
      "^librelp-1")

   #   excute_file_db=(\
   #   "ntpq -p" \
   #   "hwclock -r")
   
   # RHEL6
      # service_db=("kdump" "ntpd" "rpcbind" "multipathd" "netfs") #netfs는 상태결과가 안뜸

      # update_patch_db=(\
      # "yum-utils-1.1.30-42.el6_10.noarch" \
      # "procps-3.2.8-45.el6_9.3.x86_64" \
      # "patch-2.6-8.el6_9.x86_64" \
      # "microcode_ctl-1.17-25.4.el6_9.x86_64"
      # "librelp-1.2.7-3.el6_9.1.x86_64")


      # current_patch_db=(\
      # "^yum-utils-1" \
      # "^procps-3" \q
      # "^patch-2"
      # "^microcode_ctl-1"
      # "^librelp-1")

      service_length=${#service_db[@]}

      update_length=${#update_patch_db[@]}

      current_length=${#current_patch_db[@]}
   elif [ $RELEASE == "7" ]
   then
   # RHEL7
      service_db=("kdump" "ntpd" "rpcbind.socket" "multipathd")

      update_patch_db=(\
      "systemd-219-62.el7_6.5.x86_64" \
      "polkit-0.112-18.el7_6.1.x86_64" \
      "yum-utils-1.1.31-50.el7.noarch" \
      "procps-ng-3.3.10-17.el7_5.2.x86_64" \
      "patch-2.7.1-10.el7_5.x86_64" \
      "rsyslog-8.24.0-16.el7_5.4.x86_64" \
      "librelp-1.2.12-1.el7_5.1.x86_64")

      current_patch_db=(\
      "^systemd-2" \
      "^polkit-0" \
      "^yum-utils-1" \
      "^procps-ng-3" \
      "^patch-2" \
      "^rsyslog-8" \
      "^librelp-1")

      service_length=${#service_db[@]}

      update_length=${#update_patch_db[@]}

      current_length=${#current_patch_db[@]}


   #   excute_file_db=(\
   #   "ntpq -p" \
   #   "hwclock -r")

      service_length=${#service_db[@]}

      update_length=${#update_patch_db[@]}

      current_length=${#current_patch_db[@]}
   else
      echo ""
   fi
      
# PHYSICAL
   kernel_physical_parameter=(\
   "nmi_watchdog=0" \
   "transparent_hugepage=never" \
   "elevator=deadline")
   
# VMWARE
   kernel_vmware_parameter=(\
   "nmi_watchdog=0" \
   "transparent_hugepage=never" \
   "elevator=noop" \
   "rdblacklist=vmw_vsock_vmci_transport,vsock,vmw_vmci")
   


# Addon Grub Check
   #0  "crashkernel=512M" 
   #1   "crashkernel=256M"
   #2   "rdloaddriver=smartpqi"
   #3   "rdloaddriver=qla2xxx"
   #4   "rdloaddriver=lpfc"
   #5   "rdloaddriver=hpsa"
   #6   "spectre_v2=off nopti"
   
   kernel_addon_parameter=(\
   "crashkernel=512M" \
   "crashkernel=256M" \
   "rdloaddriver=smartpqi" \
   "rdloaddriver=qla2xxx" \
   "rdloaddriver=lpfc" \
   "rdloaddriver=hpsa" \
   "spectre_v2=off nopti")
   
   excute_file_db=(\
   "ntpq -p" \
   "hwclock -r" \
   "date"
   "uptime")

   kernel_physical_parameter_length=${#kernel_physical_parameter[@]}
   
   kernel_vmware_parameter_length=${#kernel_vmware_parameter[@]}
   
   kernel_addon_parameter_length=${#kernel_addon_parameter[@]}

   excute_length=${#excute_file_db[@]}


# GLOBAL FUNCTION
   addon_kernel_check_if(){
      if [[ $KERNEL_CMDLINE =~ "${kernel_addon_parameter[$1]}" ]]
         then
               echo -e -n "S\t"
               echo ${kernel_addon_parameter[$1]}
         else
               echo -e -n "F\t"
               echo ${kernel_addon_parameter[$1]}
         fi
   }
   physical_kernel_check(){
#      echo $VENDOR
      array_count=0
      while [ $array_count != $kernel_physical_parameter_length ]
      do
            if [[ $KERNEL_CMDLINE =~ "${kernel_physical_parameter[$array_count]}" ]]
            then
                  echo -e -n "S\t"
                  echo ${kernel_physical_parameter[$array_count]}
            else
                  echo -e -n "F\t"
                  echo ${kernel_physical_parameter[$array_count]}
            fi
            array_count=$((array_count+1))
      done
   }
   vmware_kernel_check(){
      array_count=0
      while [ $array_count != $kernel_vmware_parameter_length ]
      do
            if [[ $KERNEL_CMDLINE =~ "${kernel_vmware_parameter[$array_count]}" ]]
            then
                  echo -e -n "S\t"
                  echo ${kernel_vmware_parameter[$array_count]}
            else
                  echo -e -n "F\t"
                  echo ${kernel_vmware_parameter[$array_count]}
            fi
            array_count=$((array_count+1))
      done
   }
# Addon Grub Check
   #0  "crashkernel=512M" 
   #1   "crashkernel=256M"
   #2   "rdloaddriver=smartpqi"
   #3   "rdloaddriver=qla2xxx"
   #4   "rdloaddriver=lpfc"
   #5   "rdloaddriver=hpsa" 
   #6   "spectre_v2=off nopti"
   
   kernel_check(){
      menu8
      echo $VENDOR
      if [ $PRODUCT == "ProLiant" ]
      then
         if [ $GENERATION == "G10" ]
         then
            addon_kernel_check_if 2
            addon_kernel_check_if 3         
         else [ $GENERATION != "G10" ]
            addon_kernel_check_if 5
            addon_kernel_check_if 3         
         fi
         if [ $TOTALMEM -gt 1000000000 ]
         then
            addon_kernel_check_if 0   
         else
            addon_kernel_check_if 1
         fi
         if [ ${UNAME_MAJOR} -ge 693 ] && [ ${UNMAE_MINOR} -ge 21 ] && [ ${UNAME_EUS} -ge 1 ]
         then
            addon_kernel_check_if 6
         else
            echo -e -n "NI\t"
            echo "No need to apply spectre"
         fi
         physical_kernel_check
         
      elif [ $PRODUCT == "VMware" ]
      then
         if [ $TOTALMEM -gt 1000000000 ]
         then
            addon_kernel_check_if 0   
         else
            addon_kernel_check_if 1
         fi
         vmware_kernel_check
      else
         echo ""
      fi
   }
   
   menu() {
      echo -e "# Service Check\t"
   }
   menu1(){
      echo -e -n "Result\t"
      echo -e -n "Current Version\t\t"
      echo "Update Version"
   }
   menu2(){
      echo -e "# Pactch Check"
   }
   menu3(){
      echo -e "# Mount Check"
   }
   menu4(){
      echo -e "# Uptime Check"
   }
   menu5(){
      echo -e "# Multipath Check"
   }
   menu6(){
      echo -e "# Messages Check"
   }
   menu7(){
      echo -e "# Tinker Check"
   }
   menu8(){
      echo -e "# Kernel Check"
   }
   menu9(){
      echo -e "# Time Check"
   }
   uptime_check() {
      menu4
      uptime_status=`uptime | awk -F \, '{print $1}'`
      echo $uptime_status
   }
   mount_check() {
      menu3
      df_count=`df -T | egrep '(xfs|ext4|ext3|nfs)' | wc -l`
      fstab_count=`cat /etc/fstab |grep -v "#" | egrep '(xfs|ext4|ext3|nfs)' | wc -l`
      echo -e -n "df_count\t"
      echo -e "$df_count"
      echo -e -n "fstab_count\t"
      echo -e "$fstab_count"
   }
   multipath_check(){
      menu5
      product=`dmidecode -t1 | grep -i product | awk -F: '{print $2}' | awk '{print $1}'`
      if [ $product == "VMware" ]
      then
         echo "VMware System"
      else
         echo "Physical System"
         multipath -ll | grep sd | awk '{print $3, $5, $7}'
      fi

   }
   log_check(){
      menu6
      cat /var/log/messages | grep "`date | awk '{print $2}'`" | egrep '(err|warn|fail|crit)' | more
   }
   press_any_key(){
      read -s -n1 -p "Press any key...." keypress
      echo ""
   }
   tinker_check(){
      menu7
      TINKER_PANIC="tinker panic 0"
      TINKER_CONFIG=`cat /etc/ntp.conf | head -4`
      if [[ $TINKER_CONFIG =~ $TINKER_PANIC ]]
      then
         echo -e -n "S\t"
         echo $TINKER_PANIC
      else
         echo -e -n "F\t"
         echo $TINKER_PANIC
      fi
   }
   
   excute_check(){
      array_count=0
      menu9
      while [ $array_count != $excute_length ]
      do
         echo -e -n $array_count"."
         echo -e ${excute_file_db[$array_count]\t}
         ${excute_file_db[$array_count]}
         array_count=$((array_count+1))
         echo ""
      done
   }
   current_patch_check(){
      array_count=0
      while [ $array_count != $update_length ]
      do
         name=${current_patch_db[$array_count]}
         current_patch=`rpm -qa | grep ${name}`
            if [ $current_patch ]
            then
               echo $current_patch >> /tmp/patch.txt
            else
               echo "Service_does_not_exist" >> /tmp/patch.txt
            fi
         array_count=$((array_count+1))
      done
   }
   patch_complite() {
      array_count=0
      menu2
      menu1
      for i in `cat /tmp/patch.txt`
      do
         update_patch=${update_patch_db[$array_count]}
         if [ $i = $update_patch ]
         then
            echo -e -n "S\t"
            echo -e -n "$i\t\t"
            echo $update_patch
         elif [ $i = "Service_does_not_exist" ]
         then
            echo -e -n "NI\t"
            echo -e -n "Service does not exist\t\t"
            echo $update_patch
         else
            echo -e -n "F\t"
            echo -e -n "$i\t\t"
            echo $update_patch
      fi
         array_count=$((array_count+1))
      done
   }

######################################################
######################################################   
######################################################   
######################################################   
######################################################   
######################################################   
######################################################   
######################################################   
######################################################   
######################################################   

# ONLY RHEL7    
if [ $RELEASE == 7 ]
then
   LANG=C
   rm -rf /tmp/patch.txt
   
   service_check(){
      array_count=0
      menu
      while [ $array_count != $service_length ]
      do
         echo -n -e "${service_db[$array_count]}\t"
         systemctl is-active ${service_db[$array_count]}
         array_count=$((array_count+1))
      done
   }

   current_patch_check
   echo ""
   patch_complite
   echo ""
   kernel_check
   echo ""
   tinker_check
   echo ""
   service_check
   echo ""
   excute_check
   mount_check
   echo ""
#   uptime_check
#   echo ""
   multipath_check
   echo ""
   press_any_key
   log_check
######################################################   
######################################################   
######################################################   
######################################################   
######################################################   
######################################################   
######################################################   
######################################################   
######################################################   
######################################################   
# ONLY RHEL6
elif [ $RELEASE == 6 ]
then
   LANG=C
   rm -rf /tmp/patch.txt


#   excute_length=${#excute_file_db[@]}
   service_check() {
      array_count=0
      menu
      while [ $array_count != $service_length ]
      do
         SERVICE_STATUS=`/sbin/service ${service_db[$array_count]} status `
         echo "$SERVICE_STATUS"
         array_count=$((array_count+1))
      done
   }

   current_patch_check
   echo ""
   patch_complite
   echo ""
   kernel_check
   echo ""
   service_check
   echo ""
   tinker_check
   echo ""
   excute_check
   uptime_check
   echo ""
   mount_check
   echo ""
   multipath_check
   echo ""
   echo ""
   press_any_key
   log_check
else
   exit 0
fi

