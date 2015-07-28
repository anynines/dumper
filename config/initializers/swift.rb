if ENV['VCAP_SERVICES']
  $vcap_services ||= JSON.parse(ENV['VCAP_SERVICES'])
  swift_service_name = $vcap_services.keys.find { |svc| svc =~ /swift/i }
  swift_service = $vcap_services[swift_service_name].first
  $swift_config = {
      :provider => 'OpenStack',
      :openstack_auth_url => "#{swift_service['credentials']["authentication_uri"]}tokens",
      :openstack_username => swift_service['credentials']["user_name"],
      :openstack_api_key => swift_service['credentials']["password"]
  }
else
  $swift_config = {
  }
end
