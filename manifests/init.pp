class host_ad_info {
  file { '/usr/local/bin/host_ad_info.sh':
    ensure => file,
    source => 'puppet:///modules/host_ad_info/host_ad_info.sh',
    mode => '0755',
  }
  cron { 'host_ad_info':
    command => '/usr/local/bin/host_ad_info.sh',
    user => 'root',
    hour => 1,
    minute => 0,
  }
  package { "openldap-clients":
    ensure => "present",
  }
}
