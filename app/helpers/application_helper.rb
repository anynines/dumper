module ApplicationHelper

  def download_path(filename)
    if params[:controller] == 'mysql_dumps'
      download_mysql_dumps_path(filename)
    else
      download_postgre_dumps_path(filename)
    end
  end

  def delete_path(filename)
    if params[:controller] == 'mysql_dumps'
      delete_mysql_dumps_path(filename)
    else
      delete_postgre_dumps_path(filename)
    end
  end

  def schedule_path(service_name)
    if params[:controller] == 'mysql_dumps'
      schedule_mysql_dumps_path(service_name)
    else
      schedule_postgre_dumps_path(service_name)
    end
  end

end
