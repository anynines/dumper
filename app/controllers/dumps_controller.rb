require 'cf-app-utils'
require 'pg_dumper'

class DumpsController < ApplicationController

  def index

  end

  def new
    @services = CF::App::Service.find_all_by_label('postgresql')
  end

  def schedule
    service_name = params[:service_name]

    PostgreDumpWorker.perform_async(service_name)

    flash[:notice] = "Dump of #{service_name} started..."

    redirect_to new_dump_path
  end

end
