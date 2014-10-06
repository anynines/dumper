class PostgreDumpWorker
  include Sidekiq::Worker

  def perform(service_name, filename = nil)
    @service = CF::App::Service.find_by_name(service_name)

    raise "ERROR: SERVICE #{service_name} NOT FOUND" unless @service

    @credentials = @service['credentials']

    filename ||= service_name + '_' + Time.now.strftime("%Y%m%d%H%M%S") + '.sql'
    @output_path = PgDumper.default_path + filename

    dump = PgDumper.new(@credentials['name'])
    dump.clean!
    dump.auth = { 'host' => @credentials['host'], 'port' => @credentials['port'], 'username' => @credentials['username'], 'password' => @credentials['password'] }
    dump.output = @output_path
    dump.verbose!

    dump.run
  end
end
