require 'pg_dumper'

class MyDumper < PgDumper

  def schema_only!
    add_args "--no-data"
  end

  def create!
    add_args "-a"
  end

  def clean!
    add_args "-c"
  end

  def data_only!
    add_args "-d"
  end

  def compress! level=9
    add_args '-C'
  end

  def verbose!
    @stderr = nil
    add_args "-v"
  end

  def pretty!
  end

  def skip_owner!
  end

  def connection= opts
    add_args('-P', opts['port']) if opts['port']
    add_args('-h', opts['host']) if opts['host']
    add_args('-u', opts['username']) if opts['username']
    add_args('-p', opts['password']) if opts['password']
  end

  def execute(cmd, options)
    system(cmd, options)
  end

  def command
    Escape.shell_command([binary, args, database, "> #{output}"].flatten).to_s
  end

  def args
    @args
  end

  def find_executable
    [ENV['MY_DUMP'], %x{which mysqldump}.strip].each do |my|
      return my if my && File.exists?(my)
    end
    nil
  end

end
