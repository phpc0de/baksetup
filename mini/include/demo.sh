#!/bin/bash


DEMO() {
  pushd ${oneinstack_dir}/src > /dev/null
  if [ ! -e ${wwwroot_dir}/default/index.html ]; then 
    /bin/cp ${oneinstack_dir}/config/index.html ${wwwroot_dir}/default
    /bin/cp ${oneinstack_dir}/config/ocp.php  ${wwwroot_dir}/default
  fi

  chown -R ${run_user}.${run_group} ${wwwroot_dir}/default
  [ -e /bin/systemctl ] && systemctl daemon-reload
  popd > /dev/null
}
