require 'cf-app-utils'
require 'pg_dumper'
require 'sidekiq/api'

class DumpsController < ApplicationController

  before_action :get_path, only: [:download, :delete]

  def index
    @dumps = PostgreDumpWorker.dumps
  end

  def download
    send_file @path
  end

  def delete
    File.delete(@path)
    flash[:notice] = "Dump #{params[:filename]} deleted."
    redirect_to dumps_path
  end

  def new
    @services = CF::App::Service.find_all_by_label('postgresql')
  end

  def schedule
    service_name = params[:service_name]

    PostgreDumpWorker.perform_async(service_name)

    flash[:notice] = "Dump of #{service_name} started, this can take several minutes."

    redirect_to new_dump_path
  end

  private

  def get_path
    filename = params[:filename] + '.' + params[:format]
    @path = PostgreDumpWorker.default_path + filename

    if params[:filename].blank? || !PostgreDumpWorker.is_valid_dump?(filename)|| !File.exist?(path)
      flash[:error] = "#{filename} not found."
      redirect_to dumps_path
    end
  end

end
