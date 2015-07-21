require 'fog'

class PostgreDumpWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  class << self

    def directory_key
      "dumps"
    end

    def storage
      @@storage ||= Fog::Storage.new($swift_config)
    end

    def directory
      storage.directories.create(:key => directory_key)
      storage.directories.get(directory_key)
    end

    def dumps(path = nil)
      directory.files
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

    logger.info "PostgreSQL dump for #{service_name}"

    unless self.class.is_valid_service?(service_name)
      logger.error "Invalid service => abort"
      return
    end

    @credentials = @service['credentials']

    filename ||= service_name + '_' + Time.now.strftime("%Y%m%d%H%M%S") + '.sql'

    logger.info "Dump into #{filename}..."

    @output_path = Rails.application.root + "dumps" + filename

    dump = PgDumper.new(@credentials['name'])
    #dump.clean!
    dump.skip_owner!
    dump.skip_privileges!
    dump.auth = { 'host' => @credentials['host'], 'port' => @credentials['port'], 'username' => @credentials['username'], 'password' => @credentials['password'] }
    dump.output = @output_path

    if dump.run
      logger.info "Dump completed!"

      @directory = self.class.directory

      if @directory
        logger.info "Uploading dump to swift..."

        @directory.files.create(
            :key    => filename,
            :body   => File.open(@output_path),
        )

        logger.info "Upload completed!"
      else
        logger.error "Swift is not available."
      end

      File.delete(@output_path)
    else
      logger.error "Dump failed!"
    end
  end
end
