class AssetsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def show
    path = params[:path]
    # Add file extension based on the request format
    if request.format.css?
      path += ".css"
    elsif request.format.js?
      path += ".js"
    end

    file_path = Rails.root.join("app/assets/builds", path)

    if File.exist?(file_path)
      content_type = case File.extname(file_path)
      when ".css"
                      "text/css"
      when ".js"
                      "application/javascript"
      when ".map"
                      "application/json"
      else
                      "text/plain"
      end

      send_file file_path, type: content_type, disposition: "inline"
    else
      head :not_found
    end
  end
end
