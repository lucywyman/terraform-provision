plan terraform_provision(String $tf_path) {
  $localhost = get_targets('localhost')

  # Create and manage infrastructure
  run_script("terraform_provision/tf_apply.sh", $localhost, 'arguments' => [$tf_path])
  $ip_string = run_command("cd ${$tf_path} && terraform output public_ips", $localhost).map |$r| { $r['stdout'] }
  $ips = Array($ip_string).map |$ip| { $ip.strip }

  # Turn IPs into Bolt targets, and add to inventory
  $targets = $ips.map |$ip| {
    Target.new("${$ip}").add_to_group('terraform')
  }

  # Deploy website
  apply_prep($targets)

  apply($targets, _run_as => 'root') {
    include apache

    file { '/var/www/html/index.html':
      ensure => 'file',
      # TODO
      source => "puppet:///modules/terraform_provision/site.html"
    }
  }

  return $ips
  # Or diagnose issues across your terraform infrastructure
  run_command("uptime", $targets)
}