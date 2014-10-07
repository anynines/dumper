class MysqlDumpsController < PostgreDumpsController

  protected

  def worker_class
    MysqlDumpWorker
  end

end
