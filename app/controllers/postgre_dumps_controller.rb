require 'cf-app-utils'
require 'fog'

class PostgreDumpsController < ApplicationController

  before_action :get_file, only: [:download, :delete]

  def index
    @dumps = self.worker_class.dumps
    @services = self.worker_class.services
  end

  def download
    redirect_to @file.temp_signed_url(240, "GET")
  end

  def delete
    @file.destroy
    flash[:notice] = "Dump #{@file.key} deleted."
    redirect_to action: :index
  end

  def schedule
    service_name = params[:service_name]

    self.worker_class.perform_async(service_name)

    flash[:notice] = "Dump of #{service_name} started, this can take several minutes."

    redirect_to action: :index
  end

  protected

  def worker_class
    PostgreDumpWorker
  end

  private

  def get_file
    filename = params[:filename] + '.' + params[:format]
    @file = self.worker_class.get_dump(filename)

    if params[:filename].blank? || !@file
      flash[:error] = "#{filename} not found."
      redirect_to dumps_path
    end
  end

end
