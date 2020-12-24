#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>


if [ -e "/usr/bin/yum" ]; then
  PM=yum
  command -v lsb_release >/dev/null 2>&1 || { yum -y install redhat-lsb-core; clear; }
fi

command -v lsb_release >/dev/null 2>&1 || { echo "${CFAILURE}${PM} source failed! ${CEND}"; kill -9 $$; }

# Get OS Version
if [ -e /etc/redhat-release ]; then
  OS=CentOS
  CentOS_ver=$(lsb_release -sr | awk -F. '{print $1}')
  [ "$(lsb_release -is)" == 'Fedora' ] && [ ${CentOS_ver} -ge 19 >/dev/null 2>&1 ] && { CentOS_ver=7; Fedora_ver=$(lsb_release -rs); }
elif [ -n "$(grep 'Amazon Linux' /etc/issue)" -o -n "$(grep 'Amazon Linux' /etc/os-release)" ]; then
  OS=CentOS
  CentOS_ver=7
fi

# Check OS Version
if [ ${CentOS_ver} -lt 6 >/dev/null 2>&1 ]; then
  echo "${CFAILURE}Does not support this OS, Please install CentOS 6+,Debian 8+,Ubuntu 14+ ${CEND}"
  kill -9 $$
fi

command -v gcc > /dev/null 2>&1 || $PM -y install gcc
gcc_ver=$(gcc -dumpversion | awk -F. '{print $1}')

[ ${gcc_ver} -lt 5 >/dev/null 2>&1 ] && redis_ver=${redis_oldver}

if uname -m | grep -Eqi "arm|aarch64"; then
  armplatform="y"
  if uname -m | grep -Eqi "armv7"; then
    TARGET_ARCH="armv7"
  elif uname -m | grep -Eqi "armv8"; then
    TARGET_ARCH="arm64"
  elif uname -m | grep -Eqi "aarch64"; then
    TARGET_ARCH="aarch64"
  else
    TARGET_ARCH="unknown"
  fi
fi

if [ "$(uname -r | awk -F- '{print $3}' 2>/dev/null)" == "Microsoft" ]; then
  Wsl=true
fi

if [ "$(getconf WORD_BIT)" == "32" ] && [ "$(getconf LONG_BIT)" == "64" ]; then
  OS_BIT=64
  SYS_BIT_j=x64 #jdk
  SYS_BIT_a=x86_64 #mariadb
  SYS_BIT_b=x86_64 #mariadb
  SYS_BIT_c=x86_64 #ZendGuardLoader
  SYS_BIT_d=x86-64 #ioncube
  [ "${TARGET_ARCH}" == 'aarch64' ] && { SYS_BIT_c=aarch64; SYS_BIT_d=aarch64; }
else
  OS_BIT=32
  SYS_BIT_j=i586
  SYS_BIT_a=x86
  SYS_BIT_b=i686
  SYS_BIT_c=i386
  SYS_BIT_d=x86
  [ "${TARGET_ARCH}" == 'armv7' ] && { SYS_BIT_c=armhf; SYS_BIT_d=armv7l; }
fi

THREAD=$(grep 'processor' /proc/cpuinfo | sort -u | wc -l)


if [[ "${CentOS_ver}" =~ ^[6-7]$ ]] && [ "$(lsb_release -is)" != 'Fedora' ]; then
  sslLibVer=ssl101
elif [ ${Fedora_ver} -ge 27 >/dev/null 2>&1 ]; then
  sslLibVer=ssl102
else
  sslLibVer=unknown
fi
