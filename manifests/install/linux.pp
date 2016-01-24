class topbeat::install::linux {
  package {'topbeat':
    ensure => $topbeat::package_ensure,
  }
}
