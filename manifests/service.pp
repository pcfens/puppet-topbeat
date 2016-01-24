class topbeat::service {
  service { 'topbeat':
    ensure => $topbeat::service_ensure,
    enable => $topbeat::service_enable,
  }
}
