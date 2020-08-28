#!/bin/sh

port=42112
fraza="baobab-128"
host="${1}"
fw_file="${2}"

[ -z "${host}" -o -z "${fw_file}" ] && {
	echo "Usage: ${0} [ ip_addr, path_to_file ]"
	exit 2
}

[ -f ${fw_file} ] || {
	echo "File ${fw_file} does not exist!"
	exit 2
}

str=$(echo "${fraza}" | nc ${host} ${port} -q 1 2>/dev/null)
[ "${str}" = "${fraza}" ] && {
	sleep 1
	cat ${fw_file} | nc ${host} ${port} -q 1 2>/dev/null && echo "FW NC Done"
	sleep 1
	loc_md5s=$(md5sum ${fw_file} | sed 's/ .*//')
	rem_md5s=$(echo "${loc_md5s}" | nc ${host} ${port} -q 1 2>/dev/null)
	if [ "${rem_md5s}" = "${loc_md5s}" ]; then
			echo "MD5 sum check is OK"
			echo "All ops is done!"
		else
			echo "MD5 sum mismatch detected!"
			echo "${rem_md5s}"
			echo "${loc_md5s}"
		fi
}
