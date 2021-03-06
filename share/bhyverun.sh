#!/bin/sh

[ ! -f "${1}" ] && exit 0
. ${1}

detach=
[ "${2}" = "-d" ] && detach="-d"

[ -f /tmp/bhyvestop.${jname}.lock ] && rm -f /tmp/bhyvestop.${jname}.lock

while [ ! -f /tmp/bhyvestop.${jname}.lock  ]; do

	if [ "${boot_from_grub}" = "1" ]; then
		echo "Booting from: ${vm_boot}"
		# Bhyveload
		case "${vm_boot}" in
			"cd")
				echo "Boot from CD"
				echo "DEBUG: $grub_iso_cmd"
				eval "$grub_iso_cmd"
				;;
			"hdd")
				echo "Boot from HDD"
				echo "DEBUG: ${grub_boot_cmd}"
				eval "$grub_boot_cmd"
				;;
			*)
				echo "Booting from HDD"
				eval "$grub_boot_cmd"
				;;
		esac
	else
		echo "DEBUG: $bhyveload_cmd"
		eval "$bhyveload_cmd"
	fi

	echo "[debug] /usr/sbin/bhyve ${bhyve_flags} -c ${vm_cpus} -m ${vm_ram} -A -H -P ${hostbridge_args} ${passthr} ${lpc_args} ${virtiornd_args} ${nic_args} ${dsk_args} ${cd_args} -l com1,stdio ${jname};"

	/sbin/ifconfig ${mytap} up
	/usr/bin/lockf -s -t0 /tmp/bhyveload.${jname}.lock /usr/sbin/bhyve ${bhyve_flags} -c ${vm_cpus} -m ${vm_ram} -A -H -P ${hostbridge_args} ${passthr} ${lpc_args} ${virtiornd_args} ${nic_args} ${dsk_args} ${cd_args} -l com1,stdio ${jname} || touch /tmp/bhyvestop.${jname}.lock
#	/usr/sbin/bhyvectl --get-vmcs-exit-reason --vm ${jname} >> /tmp/reason.txt
#	/usr/sbin/bhyvectl --get-vmcs-exit-ctls --vm ${jname} >> /tmp/reason.txt
#	/usr/sbin/bhyvectl --get-vmcs-exit-qualification --vm ${jname} >> /tmp/reason.txt
#	/usr/sbin/bhyvectl --get-vmcs-exit-interruption-info --vm ${jname} >> /tmp/reason.txt
#	/usr/sbin/bhyvectl --get-vmcs-exit-interruption-error --vm ${jname} >> /tmp/reason.txt
done

rm -f /tmp/bhyvestop.${jname}.lock
/usr/local/bin/cbsd bstop ${jname}
/sbin/ifconfig ${mytap} destroy
exit ${bhyve_exit}
