require 'my_dumper'

class MysqlDumpWorker < PostgreDumpWorker

  class << self

    def directory_key
      "mysql"
    end

    def label
      "MySQL"
    end

    def service_label
      /^mysql(-.*)?$/
    end

    def dumper_class
      MyDumper
    end

    def services
      CF::App::Service.find_all_by_label('mysql')
    end

  end

end
