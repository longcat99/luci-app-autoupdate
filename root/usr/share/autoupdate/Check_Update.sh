#!/bin/bash
# https://github.com/Hyy2001X/AutoBuild-Actions
# AutoBuild Module by Hyy2001

rm -f /tmp/cloud_version
if [ ! -f /bin/AutoUpdate.sh ];then
	echo "未检测到 /bin/AutoUpdate.sh" > /tmp/cloud_version
	exit
fi
CURRENT_COMP1="$(awk 'NR==5' /etc/openwrt_info)"
CURRENT_COMP2="$(awk 'NR==6' /etc/openwrt_info)"
CURRENT_DEVICE="$(awk 'NR==3' /etc/openwrt_info)"
[[ -z "${CURRENT_DEVICE}" ]] && CURRENT_DEVICE="$(jsonfilter -e '@.model.id' < "/etc/board.json" | tr ',' '_')"
Github="$(awk 'NR==2' /etc/openwrt_info)"
[[ -z "${Github}" ]] && exit
Author="${Github##*com/}"
Github_Tags="https://api.github.com/repos/${Author}/releases/tags/update_Firmware"
wget -q ${Github_Tags} -O - > /tmp/Github_Tags
Firmware_Type="$(awk 'NR==4' /etc/openwrt_info)"
case ${CURRENT_DEVICE} in
x86-64)
	if [ -d /sys/firmware/efi ];then
		Firmware_SFX="-UEFI.${Firmware_Type}"
		BOOT_Type="-UEFI"
	else
		Firmware_SFX="-Legacy.${Firmware_Type}"
		BOOT_Type="-Legacy"
	fi
;;
*)
	Firmware_SFX=".${Firmware_Type}"
	BOOT_Type=""
;;
esac
GET_FullVersion=$(cat /tmp/beta_Tags | egrep -o "${CURRENT_COMP1}-${CURRENT_COMP2}-${CURRENT_Device}-[0-9]+.[0-9]+.[0-9]+.[0-9]+.[a-z]+.[a-z]+" | awk 'END {print}')
GET_Ver="${GET_FullVersion#*${CURRENT_COMP1}-}"
Cloud_Version="${GET_Ver}"
CURRENT_Version="$(awk 'NR==1' /etc/openwrt_info)"
if [[ ! -z "${Cloud_Version}" ]];then
	if [[ "${CURRENT_Version}" == "${Cloud_Version}" ]];then
		Checked_Type="已是最新"
	else
		Checked_Type="可更新"
	fi
	echo "${Cloud_Version}${BOOT_Type} [${Checked_Type}]" > /tmp/cloud_version
else
	echo "未知" > /tmp/cloud_version
fi
exit
