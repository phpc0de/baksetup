#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
strB="linuxeye"
strA="oneinstack"
Download_src() {
  if [[ ${src_url} =~ $strA ]] || if [[ ${src_url} =~ $strB ]]
  then
    echo "\n${src_url}" >> error.txt
  else
    echo "\n${src_url}" >> info.txt
    [ -s "${src_url##*/}" ] && echo "[${CMSG}${src_url##*/}${CEND}] found" || { wget --limit-rate=10M -4 --tries=6 -c  ${src_url}; sleep 1; }
    if [ ! -e "${src_url##*/}" ]; then
      echo "\n${src_url}" >> failed.txt
      echo "${CFAILURE}Auto download failed! You can manually download ${src_url} into the oneinstack/src directory.${CEND}"
      kill -9 $$
    fi
  fi
   

}
