#!/bin/bash
# Author:  Alpha Eva <kaneawk AT gmail.com>


checkDownload() {
  mirrorLink=http://127.0.0.1/src
  pushd ${oneinstack_dir}/src > /dev/null
  # icu
  if ! command -v icu-config >/dev/null 2>&1 || icu-config --version | grep '^3.' || [ "${Ubuntu_ver}" == "20" ]; then
    echo "Download icu..."
    src_url=https://github.com/unicode-org/icu/releases/download/release-${icu4c_ver}-${icu4c_ver2}/icu4c-${icu4c_ver}_${icu4c_ver2}-src.tgz && Download_src
  fi

  # General system utils
  if [[ ${tomcat_option} =~ ^[1-4]$ ]] || [[ ${apache_option} =~ ^[1-2]$ ]] || [[ ${php_option} =~ ^[1-9]$ ]]; then
    #echo "Download openSSL..."
    #src_url=https://github.com/openssl/openssl/archive/OpenSSL_${openssl_ver}.tar.gz && Download_src
    #echo "Download cacert.pem..."
    #src_url=https://curl.haxx.se/ca/cacert.pem && Download_src
  fi

  # jemalloc
  if [[ ${nginx_option} =~ ^[1-3]$ ]] || [[ "${db_option}" =~ ^[1-9]$|^1[0-3]$ ]]; then
    echo "Download jemalloc..."
    src_url=https://github.com/jemalloc/jemalloc/releases/download/${jemalloc_ver}/jemalloc-${jemalloc_ver}.tar.bz2 && Download_src
  fi

  # openssl1.1
  if [[ ${nginx_option} =~ ^[1-3]$ ]]; then
      echo "Download openSSL1.1..."
      src_url=https://github.com/openssl/openssl/archive/OpenSSL_${openssl11_ver}.tar.gz && Download_src
  fi

  # nginx
  case "${nginx_option}" in
    1)
      echo "Download nginx..."
      src_url=https://github.com/nginx/nginx/archive/release-${nginx_ver}.tar.gz  && Download_src
      ;;
  esac

  # pcre
  if [[ "${nginx_option}" =~ ^[1-3]$ || ${apache_option} == '1' ]]; then
    echo "Download pcre..."
    src_url=https://ftp.pcre.org/pub/pcre/pcre-${pcre_ver}.tar.gz && Download_src
  fi




  if [[ "${db_option}" =~ ^[1-9]$|^1[0-5]$ ]]; then
    if [[ "${db_option}" =~ ^[1,2,5,6,7,9]$|^10$ ]] && [ "${dbinstallmethod}" == "2" ]; then
      [[ "${db_option}" =~ ^[2,5,6,7]$|^10$ ]] && boost_ver=${boost_oldver}
      [[ "${db_option}" =~ ^9$ ]] && boost_ver=${boost_percona_ver}
      echo "Download boost..."
      DOWN_ADDR_BOOST=http://downloads.sourceforge.net/project/boost/boost/${boost_ver}
      boostVersion2=$(echo ${boost_ver} | awk -F. '{print $1"_"$2"_"$3}')
      src_url=${DOWN_ADDR_BOOST}/boost_${boostVersion2}.tar.gz && Download_src
    fi

    case "${db_option}" in
      2)
        # MySQL 5.7
        if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
        else
          DOWN_ADDR_MYSQL=https://cdn.mysql.com/Downloads/MySQL-5.7
          DOWN_ADDR_MYSQL_BK=http://mysql.he.net/Downloads/MySQL-5.7
        fi

        if [ "${dbinstallmethod}" == '1' ]; then
          echo "Download MySQL 5.7 binary package..."
          FILE_NAME=mysql-${mysql57_ver}-linux-glibc2.12-${SYS_BIT_b}.tar.gz
        elif [ "${dbinstallmethod}" == '2' ]; then
          echo "Download MySQL 5.7 source package..."
          FILE_NAME=mysql-${mysql57_ver}.tar.gz
        fi
        # start download
        src_url=${DOWN_ADDR_MYSQL}/${FILE_NAME} && Download_src
        src_url=${DOWN_ADDR_MYSQL}/${FILE_NAME}.md5 && Download_src
        # verifying download
        MYSQL_TAR_MD5=$(awk '{print $1}' ${FILE_NAME}.md5)
        [ -z "${MYSQL_TAR_MD5}" ] && MYSQL_TAR_MD5=$(curl -s ${DOWN_ADDR_MYSQL_BK}/${FILE_NAME}.md5 | grep ${FILE_NAME} | awk '{print $1}')
        tryDlCount=0
        while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${MYSQL_TAR_MD5}" ]; do
          echo "$(md5sum ${FILE_NAME} | awk '{print $1}')" >> errorMD5.txt
          tryDlCount="6"
          #wget -c ${DOWN_ADDR_MYSQL_BK}/${FILE_NAME};sleep 1
          #let "tryDlCount++"
          #[ "$(md5sum ${FILE_NAME} | awk '{print $1}')" == "${MYSQL_TAR_MD5}" -o "${tryDlCount}" == '6' ] && break || continue
        done
        if [ "${tryDlCount}" == '6' ]; then
          echo "${CFAILURE}${FILE_NAME} download failed, Please contact the author! ${CEND}"
          kill -9 $$
        fi
        ;;
      3)
        # MySQL 5.6
        if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
        else
          DOWN_ADDR_MYSQL=http://cdn.mysql.com/Downloads/MySQL-5.6
          DOWN_ADDR_MYSQL_BK=http://mysql.he.net/Downloads/MySQL-5.6
        fi

        if [ "${dbinstallmethod}" == '1' ]; then
          echo "Download MySQL 5.6 binary package..."
          FILE_NAME=mysql-${mysql56_ver}-linux-glibc2.12-${SYS_BIT_b}.tar.gz
        elif [ "${dbinstallmethod}" == '2' ]; then
          echo "Download MySQL 5.6 source package..."
          FILE_NAME=mysql-${mysql56_ver}.tar.gz
        fi
        # start download
        src_url=${DOWN_ADDR_MYSQL}/${FILE_NAME} && Download_src
        src_url=${DOWN_ADDR_MYSQL}/${FILE_NAME}.md5 && Download_src
        # verifying download
        MYSQL_TAR_MD5=$(awk '{print $1}' ${FILE_NAME}.md5)
        [ -z "${MYSQL_TAR_MD5}" ] && MYSQL_TAR_MD5=$(curl -s ${DOWN_ADDR_MYSQL_BK}/${FILE_NAME}.md5 | grep ${FILE_NAME} | awk '{print $1}')
        tryDlCount=0
        while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${MYSQL_TAR_MD5}" ]; do
          echo "$(md5sum ${FILE_NAME} | awk '{print $1}')" >> errorMD5.txt
          tryDlCount="6"
          #wget -c --no-check-certificate ${DOWN_ADDR_MYSQL_BK}/${FILE_NAME};sleep 1
          #let "tryDlCount++"
          #[ "$(md5sum ${FILE_NAME} | awk '{print $1}')" == "${MYSQL_TAR_MD5}" -o "${tryDlCount}" == '6' ] && break || continue
        done
        if [ "${tryDlCount}" == '6' ]; then
          echo "${CFAILURE}${FILE_NAME} download failed, Please contact the author! ${CEND}"
          kill -9 $$
        fi
        ;;

      15)
        # MongoDB
        echo "Download MongoDB binary package..."
        FILE_NAME=mongodb-linux-${SYS_BIT_b}-${mongodb_ver}.tgz
        if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
        else
          DOWN_ADDR_MongoDB=https://fastdl.mongodb.org/linux
        fi
        src_url=${DOWN_ADDR_MongoDB}/${FILE_NAME} && Download_src
        src_url=${DOWN_ADDR_MongoDB}/${FILE_NAME}.md5 && Download_src
        MongoDB_TAR_MD5=$(awk '{print $1}' ${FILE_NAME}.md5)
        [ -z "${MongoDB_TAR_MD5}" ] && MongoDB_TAR_MD5=$(curl -s ${DOWN_ADDR_MongoDB}/${FILE_NAME}.md5 | grep ${FILE_NAME} | awk '{print $1}')
        tryDlCount=0
        while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${MongoDB_TAR_MD5}" ]; do
          wget -c ${DOWN_ADDR_MongoDB}/${FILE_NAME};sleep 1
          let "tryDlCount++"
          [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" == "${MongoDB_TAR_MD5}" -o "${tryDlCount}" == '6' ] && break || continue
        done
        if [ "${tryDlCount}" == '6' ]; then
          echo "${CFAILURE}${FILE_NAME} download failed, Please contact the author! ${CEND}"
          kill -9 $$
        fi
        ;;
    esac
  fi

  # PHP
  if [[ "${php_option}" =~ ^[1-9]$ ]]; then
    echo "PHP common..."
    src_url=https://ftp.gnu.org/pub/gnu/libiconv/libiconv-${libiconv_ver}.tar.gz && Download_src
    src_url=https://curl.haxx.se/download/curl-${curl_ver}.tar.gz && Download_src
    src_url=https://downloads.sourceforge.net/project/mhash/mhash/${mhash_ver}/mhash-${mhash_ver}.tar.gz && Download_src
    src_url=https://downloads.sourceforge.net/project/mcrypt/Libmcrypt/${libmcrypt_ver}/libmcrypt-${libmcrypt_ver}.tar.gz && Download_src
    src_url=https://downloads.sourceforge.net/project/mcrypt/MCrypt/${mcrypt_ver}/mcrypt-${mcrypt_ver}.tar.gz && Download_src
    src_url=https://download.savannah.gnu.org/releases/freetype/freetype-${freetype_ver}.tar.gz && Download_src
  fi

  case "${php_option}" in
    5)
      src_url=https://secure.php.net/distributions/php-${php70_ver}.tar.gz && Download_src
      ;;
    6)
      src_url=https://secure.php.net/distributions/php-${php71_ver}.tar.gz && Download_src
      ;;
    7)
      src_url=https://secure.php.net/distributions/php-${php72_ver}.tar.gz && Download_src
      src_url=https://github.com/P-H-C/phc-winner-argon2/archive/${argon2_ver}.tar.gz && Download_src
      src_url=https://github.com/jedisct1/libsodium/releases/download/${libsodium_ver}-RELEASE/libsodium-${libsodium_ver}.tar.gz && Download_src
      ;;
    8)
      src_url=https://secure.php.net/distributions/php-${php73_ver}.tar.gz && Download_src
      src_url=https://github.com/P-H-C/phc-winner-argon2/archive/${argon2_ver}.tar.gz && Download_src
      src_url=https://github.com/jedisct1/libsodium/releases/download/${libsodium_ver}-RELEASE/libsodium-${libsodium_ver}.tar.gz && Download_src
      ;;
    9)
      src_url=https://secure.php.net/distributions/php-${php74_ver}.tar.gz && Download_src
      src_url=https://github.com/P-H-C/phc-winner-argon2/archive/${argon2_ver}.tar.gz && Download_src
      src_url=https://github.com/jedisct1/libsodium/releases/download/${libsodium_ver}-RELEASE/libsodium-${libsodium_ver}.tar.gz && Download_src
      src_url=https://github.com/nih-at/libzip/releases/download/v${libzip_ver}/libzip-${libzip_ver}.tar.gz && Download_src
      ;;
  esac

  # PHP OPCache
  case "${phpcache_option}" in
    1)
      if [[ "${php_option}" =~ ^[1-2]$ ]]; then
        # php 5.3 5.4
        echo "Download Zend OPCache..."
        src_url=https://pecl.php.net/get/zendopcache-${zendopcache_ver}.tgz && Download_src
      fi
      ;;
    2)
      if [[ "${php_option}" =~ ^[1-4]$ ]]; then
        # php 5.3 5.4 5.5 5.6
        echo "Download xcache..."
        src_url=https://xcache.lighttpd.net/pub/Releases/${xcache_ver}/xcache-${xcache_ver}.tar.gz && Download_src
      fi
      ;;
    3)
      # php 5.3 ~ 7.4
      echo "Download apcu..."
      if [[ "${php_option}" =~ ^[1-4]$ ]]; then
        src_url=https://pecl.php.net/get/apcu-${apcu_oldver}.tgz && Download_src
      else
        src_url=https://pecl.php.net/get/apcu-${apcu_ver}.tgz && Download_src
      fi
      ;;
    4)
      # php 5.3 5.4
      if [ "${php_option}" == '1' ]; then
        echo "Download eaccelerator 0.9..."
        src_url=https://github.com/downloads/eaccelerator/eaccelerator/eaccelerator-${eaccelerator_ver}.tar.bz2 && Download_src
      elif [ "${php_option}" == '2' ]; then
        echo "Download eaccelerator 1.0 dev..."
        src_url=https://github.com/eaccelerator/eaccelerator/tarball/master && Download_src
      fi
      ;;
  esac

  # ioncube
  if [ "${pecl_ioncube}" == '1' ]; then
    echo "Download ioncube..."
    src_url=https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_${SYS_BIT_d}.tar.gz && Download_src
  fi



  # imageMagick
  if [ "${pecl_imagick}" == '1' ]; then
    echo "Download ImageMagick..."
    src_url=https://github.com/ImageMagick/ImageMagick/archive/${imagemagick_ver}.tar.gz && Download_src
    echo "Download imagick..."
    src_url=https://pecl.php.net/get/imagick-${imagick_ver}.tgz && Download_src
  fi

  # graphicsmagick
  if [ "${pecl_gmagick}" == '1' ]; then
    echo "Download graphicsmagick..."
    src_url=http://downloads.sourceforge.net/project/graphicsmagick/graphicsmagick/${graphicsmagick_ver}/GraphicsMagick-${graphicsmagick_ver}.tar.gz && Download_src
    if [[ "${php_option}" =~ ^[1-4]$ ]]; then
      echo "Download gmagick for php..."
      src_url=https://pecl.php.net/get/gmagick-${gmagick_oldver}.tgz && Download_src
    else
      echo "Download gmagick for php 7.x..."
      src_url=https://pecl.php.net/get/gmagick-${gmagick_ver}.tgz && Download_src
    fi
  fi

  # redis-server
  if [ "${redis_flag}" == 'y' ]; then
    echo "Download redis-server..."
    src_url=http://download.redis.io/releases/redis-${redis_ver}.tar.gz && Download_src
    if [ "${PM}" == 'yum' ]; then
      echo "Download start-stop-daemon.c for CentOS..."
      src_url=https://raw.githubusercontent.com/daleobrien/start-stop-daemon/master/start-stop-daemon.c && Download_src
    fi
  fi

  # pecl_redis
  if [ "${pecl_redis}" == '1' ]; then
    if [[ "${php_option}" =~ ^[1-4]$ ]]; then
      echo "Download pecl_redis for php..."
      src_url=https://pecl.php.net/get/redis-${pecl_redis_oldver}.tgz && Download_src
    else
      echo "Download pecl_redis for php 7.x..."
      src_url=https://pecl.php.net/get/redis-${pecl_redis_ver}.tgz && Download_src
    fi
  fi

  # memcached-server
  if [ "${memcached_flag}" == 'y' ]; then
    echo "Download memcached-server..."
    DOWN_ADDR=https://www.memcached.org/files
    src_url=${DOWN_ADDR}/memcached-${memcached_ver}.tar.gz && Download_src
  fi

  # pecl_memcached
  if [ "${pecl_memcached}" == '1' ]; then
    echo "Download libmemcached..."
    src_url=https://launchpad.net/libmemcached/1.0/${libmemcached_ver}/+download/libmemcached-${libmemcached_ver}.tar.gz && Download_src
    if [[ "${php_option}" =~ ^[1-4]$ ]]; then
      echo "Download pecl_memcached for php..."
      src_url=https://pecl.php.net/get/memcached-${pecl_memcached_oldver}.tgz && Download_src
    else
      echo "Download pecl_memcached for php 7.x..."
      src_url=https://pecl.php.net/get/memcached-${pecl_memcached_ver}.tgz && Download_src
    fi
  fi

  # memcached-server pecl_memcached pecl_memcache
  if [ "${pecl_memcache}" == '1' ]; then
    if [[ "${php_option}" =~ ^[1-4]$ ]]; then
      echo "Download pecl_memcache for php..."
      src_url=https://pecl.php.net/get/memcache-${pecl_memcache_oldver}.tgz && Download_src
    else
      echo "Download pecl_memcache for php 7.x..."
      # src_url=https://codeload.github.com/websupport-sk/pecl-memcache/zip/php7 && Download_src
      src_url=https://pecl.php.net/get/memcache-${pecl_memcache_ver}.tgz && Download_src
    fi
  fi

  # pecl_mongodb
  if [ "${pecl_mongodb}" == '1' ]; then
    echo "Download pecl mongo for php..."
    src_url=https://pecl.php.net/get/mongo-${pecl_mongo_ver}.tgz && Download_src
    echo "Download pecl mongodb for php..."
    src_url=https://pecl.php.net/get/mongodb-${pecl_mongodb_ver}.tgz && Download_src
  fi

  # pureftpd
  if [ "${pureftpd_flag}" == 'y' ]; then
    echo "Download pureftpd..."
    src_url=https://github.com/jedisct1/pure-ftpd/releases/download/${pureftpd_ver}/pure-ftpd-${pureftpd_ver}.tar.gz && Download_src
  fi
//read
  # phpMyAdmin
  if [ "${phpmyadmin_flag}" == 'y' ]; then
    echo "Download phpMyAdmin..."
    if [[ "${php_option}" =~ ^[1-2]$ ]]; then
      src_url=https://files.phpmyadmin.net/phpMyAdmin/${phpmyadmin_oldver}/phpMyAdmin-${phpmyadmin_oldver}-all-languages.tar.gz && Download_src
    else
      src_url=https://files.phpmyadmin.net/phpMyAdmin/${phpmyadmin_ver}/phpMyAdmin-${phpmyadmin_ver}-all-languages.tar.gz && Download_src
    fi
  fi

  # others
  if [ "${downloadDepsSrc}" == '1' ]; then
    if [ "${PM}" == 'yum' ]; then
      echo "Download htop for CentOS..."
      src_url=https://github.com/htop-dev/htop/archive/${htop_ver}.tar.gz && Download_src
    fi


  fi

  popd > /dev/null
}
