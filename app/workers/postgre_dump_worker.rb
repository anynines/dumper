class PostgreDumpWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  class << self

    def default_path
      Rails.application.root + "dumps"
    end

    def dumps(path = nil)
      path ||= default_path

      Dir.entries(path).map { |filename|
        filename if is_valid_dump? filename
      }.compact
    end

    def is_valid_service?(service_name)
      service = CF::App::Service.find_by_name(service_name)
      (service && service['label'].match(/^postgresql(-.*)?$/))
    end

    def is_valid_dump?(filename)
      ext = File.extname(filename)
      valid_extensions = ['.sql']
      valid_extensions.any? { |check_ext| ext.include?(check_ext) }
    end

  end

  def perform(service_name, filename = nil)
    @service = CF::App::Service.find_by_name(service_name)

    logger.info "PostgreSQL dump for..."
    logger.info "#{service_name} #{@service.inspect}"

    unless self.class.is_valid_service?(service_name)
      logger.error "Invalid service => abort"
      return
    end

    @credentials = @service['credentials']

    filename ||= service_name + '_' + Time.now.strftime("%Y%m%d%H%M%S") + '.sql'
    @output_path = PostgreDumpWorker.default_path + filename

    logger.info "Dump into #{filename}..."

    dump = PgDumper.new(@credentials['name'])
    dump.clean!
    dump.auth = { 'host' => @credentials['host'], 'port' => @credentials['port'], 'username' => @credentials['username'], 'password' => @credentials['password'] }
    dump.output = @output_path
    dump.run
  end
end
