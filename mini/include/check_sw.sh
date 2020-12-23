#!/bin/bash
# Author:  Alpha Eva <kaneawk AT gmail.com>



installDepsCentOS() {
  [ -e '/etc/yum.conf' ] && sed -i 's@^exclude@#exclude@' /etc/yum.conf
  # Uninstall the conflicting packages
  echo "${CMSG}Removing the conflicting packages...${CEND}"
  [ -z "`grep -w epel /etc/yum.repos.d/*.repo`" ] && yum -y install epel-release

  if [ "${CentOS_ver}" == '7' ]; then
    yum -y groupremove "Basic Web Server" "MySQL Database server" "MySQL Database client"
    systemctl stop firewalld && systemctl mask firewalld.service
  elif [ "${CentOS_ver}" == '6' ]; then
    yum -y groupremove "FTP Server" "PostgreSQL Database client" "PostgreSQL Database server" "MySQL Database server" "MySQL Database client" "Web Server"
  fi

  if [ ${CentOS_ver} -ge 7 >/dev/null 2>&1 ] && [ "${iptables_flag}" == 'y' ]; then
    yum -y install iptables-services
    systemctl enable iptables.service
    systemctl enable ip6tables.service
  fi

  echo "${CMSG}Installing dependencies packages...${CEND}"
  # Install needed packages
  pkgList="deltarpm gcc gcc-c++ make cmake autoconf libjpeg libjpeg-devel libjpeg-turbo libjpeg-turbo-devel libpng libpng-devel libxml2 libxml2-devel zlib zlib-devel libzip libzip-devel glibc glibc-devel krb5-devel libc-client libc-client-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel libaio numactl numactl-libs readline-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5-devel libidn libidn-devel openssl openssl-devel net-tools libxslt-devel libicu-devel libevent-devel libtool libtool-ltdl bison gd-devel vim-enhanced pcre-devel libmcrypt libmcrypt-devel mhash mhash-devel mcrypt zip unzip ntpdate sqlite-devel sysstat patch bc expect expat-devel oniguruma oniguruma-devel libtirpc-devel nss rsync rsyslog git lsof lrzsz psmisc wget which libatomic tmux"
  for Package in ${pkgList}; do
    yum -y install ${Package}
  done

  yum -y update bash openssl glibc
}



installDepsBySrc() {
  pushd ${oneinstack_dir}/src > /dev/null
  if [ "${OS}" == 'CentOS' ]; then
    # install htop
    if ! command -v htop >/dev/null 2>&1; then
      tar xzf htop-${htop_ver}.tar.gz
      pushd htop-${htop_ver} > /dev/null
      ./configure
      make -j ${THREAD} && make install
      popd > /dev/null
      rm -rf htop-${htop_ver}
    fi
  else
    echo "No need to install software from source packages."
  fi

  if ! command -v icu-config > /dev/null 2>&1 || icu-config --version | grep '^3.' || [ "${Ubuntu_ver}" == "20" ]; then
    tar xzf icu4c-${icu4c_ver}-src.tgz
    pushd icu/source > /dev/null
    ./configure --prefix=/usr/local
    make -j ${THREAD} && make install
    popd > /dev/null
    rm -rf icu
  fi

  if command -v lsof >/dev/null 2>&1; then
    echo 'already initialize' > ~/.oneinstack
  else
    echo "${CFAILURE}${PM} config error parsing file failed${CEND}"
    kill -9 $$
  fi

  popd > /dev/null
}
