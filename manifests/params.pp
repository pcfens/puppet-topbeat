class topbeat::params {
  $package_ensure = present
  $manage_repo    = true
  $service_ensure = running
  $service_enable = true
  $config_file_mode = '0644'
  $purge_conf_dir = true
  $input          = {}
  $output         = {}
  $shipper        = {}
  $logging        = {}
  $run_options    = {}
  $conf_template  = "${module_name}/topbeat.yml.erb"

  case $::kernel {
    'Linux'   : {

      # These parameters are ignored if/until tarball installs are supported in Linux
      $tmp_dir         = '/tmp'
      $install_dir     = undef
      $download_url    = undef
    }

    'Windows' : {
      $download_url    = 'https://download.elastic.co/beats/topbeat/topbeat-1.0.1-windows.zip'
      $install_dir     = 'C:/Program Files'
      $tmp_dir         = 'C:/Temp'
    }

    default : {
      fail($topbeat::kernel_fail_message)
    }
  }
}
