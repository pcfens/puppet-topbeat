class topbeat::install::windows {
  $filename = regsubst($topbeat::download_url, '^https.*\/([^\/]+)\.[^.].*', '\1')
  $foldername = 'Topbeat'

  file { $topbeat::tmp_dir:
    ensure => directory
  }

  file { $topbeat::install_dir:
    ensure => directory
  }

  remote_file {"${topbeat::tmp_dir}/${filename}.zip":
    ensure      => present,
    source      => $topbeat::download_url,
    require     => File[$topbeat::tmp_dir],
    verify_peer => false,
  }

  exec { "unzip ${filename}":
    command  => "\$sh=New-Object -COM Shell.Application;\$sh.namespace((Convert-Path '${topbeat::install_dir}')).Copyhere(\$sh.namespace((Convert-Path '${topbeat::tmp_dir}/${filename}.zip')).items(), 16)",
    creates  => "${topbeat::install_dir}/Topbeat",
    provider => powershell,
    require  => [
      File[$topbeat::install_dir],
      Remote_file["${topbeat::tmp_dir}/${filename}.zip"],
    ],
  }

  exec { 'rename folder':
    command  => "Rename-Item '${topbeat::install_dir}/${filename}' Topbeat",
    creates  => "${topbeat::install_dir}/Topbeat",
    provider => powershell,
    require  => Exec["unzip ${filename}"],
  }

  exec { "install ${filename}":
    cwd      => "${topbeat::install_dir}/Topbeat",
    command  => './install-service-topbeat.ps1',
    onlyif   => 'if(Get-WmiObject -Class Win32_Service -Filter "Name=\'topbeat\'") { exit 1 } else {exit 0 }',
    provider =>  powershell,
    require  => Exec['rename folder'],
  }
}
