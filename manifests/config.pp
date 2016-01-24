class topbeat::config {
  $topbeat_config = {
    'input'      => $topbeat::input,
    'output'     => $topbeat::output,
    'shipper'    => $topbeat::shipper,
    'logging'    => $topbeat::logging,
    'runoptions' => $topbeat::run_options,
  }

  case $::kernel {
    'Linux'   : {
      file {'topbeat.yml':
        ensure  => file,
        path    => '/etc/topbeat/topbeat.yml',
        content => template("${module_name}/topbeat.yml.erb"),
        owner   => 'root',
        group   => 'root',
        mode    => $topbeat::config_file_mode,
        notify  => Service['topbeat'],
      }
    } # end Linux

    'Windows' : {
      file {'topbeat.yml':
        ensure  => file,
        path    => 'C:/Program Files/Topbeat/topbeat.yml',
        content => template("${module_name}/topbeat.yml.erb"),
        notify  => Service['topbeat'],
      }
    } # end Windows

    default : {
      fail($topbeat::kernel_fail_message)
    }
  }
}
