plan tf::provision(String $tf_path) {
  $localhost = get_targets('localhost')

  # Create and manage infrastructure
  run_script("tf/tf_apply.sh", $localhost, 'arguments' => [$tf_path])
  $ip_string = run_command("cd ${$tf_path} && terraform output public_ips", $localhost).map |$r| { $r['stdout'] }
  $ips = Array($ip_string).map |$ip| { $ip.strip }

  # Turn IPs into Bolt targets, and add to inventory
  $targets = $ips.map |$ip| {
    Target.new("${$ip}").add_to_group('terraform')
  }

  # Deploy website
  run_task('puppet_agent::install', $targets, '_run_as' => 'root')

  apply($targets) {
    include apache
    apache::vhost { 'vhost.example.com':
      port    => '80',
      docroot => '/var/www/site',
    }

    file { '/var/www/site/site.html':
      ensure => 'file',
      source => "file:///../files/site.html"
    }
  }

  # Or diagnose issues across your terraform infrastructure
  run_command("uptime", $targets)
}