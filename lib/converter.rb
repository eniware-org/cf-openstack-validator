class Converter

  def self.openstack_defaults
    {
      "default_key_name" => "cf-validator",
      "default_security_groups" => ["default"],
      "wait_resource_poll_interval" => 5,
      "ignore_server_availability_zone" => false,
      "endpoint_type" => "publicURL",
      "state_timeout" => 300,
      "stemcell_public_visibility" => false,
      "boot_from_volume" => false,
      "use_dhcp" => true,
      "human_readable_vm_names" => true
    }
  end

  def self.cpi_config(openstack_params, registry_port)
    {
      "cloud" => {
        "plugin" => "openstack",
        "properties" => {
          "openstack" => openstack_defaults.merge(openstack_params),
          "registry" => {
            "endpoint" => "http://localhost:#{registry_port}",
            "user" => "fake",
            "password" => "fake"
          }
        }
      }
    }
  end

  def self.to_cpi_json(openstack_config)
    registry_port = NetworkHelper.next_free_ephemeral_port

    cpi_config(openstack_config, registry_port)
  end

  private

  NO_OP = -> (*args) { args }

  PARAM_CONVERTERS = {
    'auth_url' => ->(key, value) {[key, "#{value}/auth/tokens"]},
    'password' => ->(_, value) {['api_key', value]}
  }

  def self.convert(openstack_params)
    openstack_params.map do |key, value|
      PARAM_CONVERTERS.fetch(key, NO_OP).call(key, value)
    end.to_h
  end
end