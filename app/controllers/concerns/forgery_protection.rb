module ForgeryProtection
  extend ActiveSupport::Concern

  included do
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery

    def handle_unverified_request
      unless @api_request # @locodelassembly please check this out, this disables CSRF for API requests that are delete/delete
        respond_to do |format|
          format.html do
            flash[:notice] = "Your last request could not be fulfilled. Please retry."
            redirect_to '/'
          end
          format.json { render body: '{ "success": false }', status: :unprocessable_entity }
        end
      end
    end

  end
end
