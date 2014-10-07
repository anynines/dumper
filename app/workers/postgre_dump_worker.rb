require 'fog'
require 'pg_dumper'

class PostgreDumpWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  class << self

    def directory_key
      "postgre"
    end

    def label
      "PostgreSQL"
    end

    def service_label
      /^postgresql(-.*)?$/
    end

    def dumper_class
      PgDumper
    end

    def services
      CF::App::Service.find_all_by_label('postgresql')
    end

    def storage
      @@storage ||= Fog::Storage.new($swift_config)
    end

    def directory
      self.storage.directories.create(:key => directory_key)
      self.storage.directories.get(directory_key)
    end

    def dumps(path = nil)
      self.directory.files
    end

    def get_dump(filename)
      self.dumps.get(filename)
    end

    def is_valid_service?(service_name)
      service = CF::App::Service.find_by_name(service_name)
      (service && service['label'].match(self.service_label))
    end

  end

  def perform(service_name, filename = nil)
    @service = CF::App::Service.find_by_name(service_name)

    logger.info "#{self.class.label} dump for #{service_name}"

    unless self.class.is_valid_service?(service_name)
      logger.error "Invalid service => abort"
      return
    end

    @credentials = @service['credentials']

    filename ||= service_name + '_' + Time.now.strftime("%Y%m%d%H%M%S") + '.sql'

    logger.info "Dump into #{filename}..."

    @output_path = Rails.application.root + "dumps" + filename

    dump = self.class.dumper_class.new(@credentials['name'])
    dump.clean!
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
