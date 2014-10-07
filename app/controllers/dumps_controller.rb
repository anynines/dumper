require 'cf-app-utils'
require 'pg_dumper'
require 'fog'
#require 'sidekiq/api'


class DumpsController < ApplicationController

  before_action :get_file, only: [:download, :delete]

  def index
    @dumps = PostgreDumpWorker.dumps
  end

  def download
    redirect_to @file.temp_signed_url(240, "GET")
  end

  def delete
    @file.destroy
    flash[:notice] = "Dump #{@file.key} deleted."
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

  def get_file
    filename = params[:filename] + '.' + params[:format]
    @file = PostgreDumpWorker.dumps.get(filename)

    if params[:filename].blank? || !@file
      flash[:error] = "#{filename} not found."
      redirect_to dumps_path
    end
  end

end
