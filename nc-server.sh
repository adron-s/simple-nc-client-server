#!/bin/sh

port=42112
fraza="baobab-128"
res_file=${1}

[ -z "${res_file}" ] && {
	echo "Usage: ${0} [ path_to_res_file ]"
	exit 1
}

while [ 1 ]; do
	echo "Waiting for connections and ${fraza}"
	str=$(echo "${fraza}" | nc -l -p ${port} -q 1 2>/dev/null)
	[ "${str}" = "${fraza}" ] && {
		echo "${fraza} Done. Doing NC"
		nc -l -p ${port} -w 5 -q 1 2>/dev/null > ${res_file} && echo "NC Done."
		loc_md5s=$(md5sum ${res_file} | sed 's/ .*//')
		rem_md5s=$(echo "${loc_md5s}" | nc -l -p ${port} -w 5 -q 1 2>/dev/null)
		if [ "${rem_md5s}" = "${loc_md5s}" ]; then
			echo "MD5 sum check is OK"
			echo "All ops is done!"
			du -h ${res_file}
		else
			echo "MD5 sum mismatch detected!"
			echo "${rem_md5s}"
			echo "${loc_md5s}"
		fi
	}
done
