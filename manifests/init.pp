# This class installs the Elastic topbeat tool/service
#
# @example
# class { 'topbeat':
#   input   => {
#     period => '15',
#     procs  => ['.*'],
#     stats  => {
#       system     => true,
#       proc       => false,
#       filesystem => true,
#     },
#   },
#   outputs => {
#     'logstash' => {
#       'hosts' => [
#         'localhost:5044',
#       ],
#     },
#   },
# }
#
# @param package_ensure [String] The ensure parameter for the topbeat package (default: present)
# @param manage_repo [Boolean] Whether or not the upstream (elastic) repo should be configured or not (default: true)
# @param service_ensure [String] The ensure parameter on the topbeat service (default: running)
# @param service_enable [String] The enable parameter on the topbeat service (default: true)
# @param config_file_mode [String] The unix permissions mode set on configuration files (default: 0644)
# @param input [Hash] Will be converted to YAML for the input section of the configuration file (see documentation)(default: {})
# @param output [Hash] Will be converted to YAML for the required outputs section of the configuration (see documentation, and above)
# @param shipper [Hash] Will be converted to YAML to create the optional shipper section of the topbeat config (see documentation)
# @param logging [Hash] Will be converted to YAML to create the optional logging section of the topbeat config (see documentation)
# @param conf_template [String] The configuration template to use to generate the main topbeat.yml config file
# @param download_url [String] The URL of the zip file that should be downloaded to install topbeat (windows only)
# @param install_dir [String] Where topbeat should be installed (windows only)
# @param tmp_dir [String] Where topbeat should be temporarily downloaded to so it can be installed (windows only)
class topbeat (
  $package_ensure   = $topbeat::params::package_ensure,
  $manage_repo      = $topbeat::params::manage_repo,
  $service_ensure   = $topbeat::params::service_ensure,
  $service_enable   = $topbeat::params::service_enable,
  $config_file_mode = $topbeat::params::config_file_mode,
  $input            = $topbeat::params::input,
  $output           = $topbeat::params::output,
  $shipper          = $topbeat::params::shipper,
  $logging          = $topbeat::params::logging,
  $run_options      = $topbeat::params::run_options,
  $conf_template    = $topbeat::params::conf_template,
  $download_url     = $topbeat::params::download_url,
  $install_dir      = $topbeat::params::install_dir,
  $tmp_dir          = $topbeat::params::tmp_dir,
) inherits topbeat::params {

  $kernel_fail_message = "${::kernel} is not supported by topbeat."

  validate_bool($manage_repo)
  validate_hash($input, $output, $logging, $run_options)
  validate_string($package_ensure, $service_ensure, $config_file_mode, $conf_template)
  validate_string($download_url, $install_dir, $tmp_dir)

  if $package_ensure == '1.0.0-beta4' or $package_ensure == '1.0.0-rc1' {
    fail('Topbeat versions 1.0.0-rc1 and before are unsupported because they don\'t parse normal YAML headers')
  }

  anchor { 'topbeat::begin': } ->
  class { 'topbeat::install': } ->
  class { 'topbeat::config': } ->
  class { 'topbeat::service': } ->
  anchor { 'topbeat::end': }
}
