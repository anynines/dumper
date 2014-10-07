if ENV['VCAP_SERVICES']
  $vcap_services ||= JSON.parse(ENV['VCAP_SERVICES'])
  swift_service_name = $vcap_services.keys.find { |svc| svc =~ /swift/i }
  swift_service = $vcap_services[swift_service_name].first
  $swift_config = {
      :provider => 'HP',
      :hp_access_key => swift_service['credentials']["user_name"],
      :hp_secret_key => swift_service['credentials']["password"],
      :hp_tenant_id => swift_service['credentials']["tenant_id"],
      :hp_auth_uri => swift_service['credentials']["authentication_uri"],
      :hp_use_upass_auth_style => true,
      :hp_avl_zone => swift_service['credentials']["availability_zone"],
      :hp_auth_version =>  swift_service['credentials']["authentication_version"].to_sym,
      :os_account_meta_temp_url_key => swift_service['credentials']["account_meta_key"]
  }
else
  $swift_config = {
  }
end