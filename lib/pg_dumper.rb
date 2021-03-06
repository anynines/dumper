require 'pg_dumper/vendor/escape'

class PgDumper

  attr_reader :database
  attr_reader :output

  def initialize database, binary = nil
    @database = database or raise "no database given"
    @args = []
    @options = {}
    @password = ''
    @binary = binary
  end

  def run(mode = :silent)
    raise "ERROR: pg_dump executable not found" unless binary

    options = {}

    case mode
    when :silent
      options[:out] = "/dev/null"
    end

    execute command, options
  end

  def command
    Escape.shell_command([binary, args, database].flatten).to_s
  end

  def schema_only!
    add_args "-s"
  end

  def create!
    add_args "-C"
  end

  def clean!
    add_args "-c"
  end

  def data_only!
    add_args "-a", '--disable-triggers'
    add_args '-T', 'schema_migrations'
  end

  def compress! level=9
    add_args '-Z', level if level
  end

  def verbose!
    @stderr = nil
    add_args "-v"
  end

  def pretty!
    add_args '--column-inserts'
  end

  def skip_owner!
    add_args '--no-owner'
  end

  def silent!
    # FIXME: this is not windows friendly
    # try to use same solution as Bundler::NULL
    @stderr = "/dev/null"
  end

  def skip_privileges!
    add_args '--no-acl'
  end

  def connection= opts
    add_args('--port', opts['port']) if opts['port']
    add_args('-h', opts['host']) if opts['host']
    add_args('-U', opts['username']) if opts['username']
    @password = opts['password'] if opts['password']
  end
  alias :auth= :connection=

  def output= filename
    @output = filename
  end

  def output?
    !!@output
  end

  def output
    if File.respond_to?(:path)
      File.path(@output)
    elsif @output.respond_to?(:to_path)
      @output.to_path
    else
      @output
    end
  end

  def args
    if output?
      @args.dup.push('-f', output)
    else
      @args
    end
  end

  private

  def binary
    @binary ||= find_executable
  end

  def execute(cmd, options)
    full_cmd = "export PGPASSWORD=#{@password}\n" + cmd + "\nunset PGPASSWORD"

    #puts [full_cmd, options].inspect

    system(full_cmd, options)
  end

  def find_executable
    [ENV['PG_DUMP'], %x{which pg_dump}.strip].each do |pg|
      return pg if pg && File.exists?(pg)
    end
    nil
  end

  def add_args(*args)
    @args.push *args.map!(&:to_s)
    @args.uniq!
  end

  def stdout
    @stdout || $stdout
  end

  def stderr
    @stderr || $stderr
  end

end
