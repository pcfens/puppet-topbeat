class topbeat::install {
  case $::kernel {
    'Linux':   {
      contain topbeat::install::linux
      if $::topbeat::manage_repo {
        contain topbeat::repo
        Class['topbeat::repo'] -> Class['topbeat::install::linux']
      }
    }
    'Windows': {
      contain topbeat::install::windows
    }
    default:   {
      fail($topbeat::kernel_fail_message)
    }
  }
}
