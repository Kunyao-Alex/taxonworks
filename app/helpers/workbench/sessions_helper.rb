# These are *controller* methods.
module Workbench::SessionsHelper

  # User methods
  def sessions_signed_in?
    !sessions_current_user.nil?
  end

  def sessions_current_user=(user)
    @sessions_current_user = user
  end

  def sessions_current_user
    @sessions_current_user ||= User.find_by(remember_token: User.encrypt(cookies[:remember_token]))
  end

  alias_method :current_user, :sessions_current_user

  def sessions_current_user_id
    sessions_current_user ? sessions_current_user.id : nil
  end

  def sessions_sign_in(user, request)
    remember_token = User.secure_random_token
    cookies.permanent[:remember_token] = remember_token

    user.update_columns(
      remember_token: User.encrypt(remember_token),
      sign_in_count: (user.sign_in_count + 1), 
      last_sign_in_at: user.current_sign_in_at,
      current_sign_in_at: Time.now,
      last_sign_in_ip: user.current_sign_in_ip, 
      current_sign_in_ip: request.ip
    )

    self.sessions_current_user = user
  end

  def sessions_sign_out
    self.sessions_current_user = nil
    sessions_clear_selected_project
    cookies.delete(:remember_token)
  end

  # Project methods
  def sessions_project_selected?
    !sessions_current_project_id.nil?
  end

  def sessions_current_project_id=(project_id)
    session[:project_id] = project_id
  end

  def sessions_current_project_id
    session[:project_id]
  end

  def sessions_current_project
   return nil unless sessions_current_project_id
   if @sessions_current_project.nil? || @sessions_current_project.id != sessions_current_project_id  
     @sessions_current_project = Project.find(sessions_current_project_id)
   end
     @sessions_current_project
  end

  def sessions_select_project(project)
   self.sessions_current_project_id = project.id 
   sessions_current_project
  end

  def sessions_clear_selected_project
    session[:project_id] = nil
  end

  # Authorization methods
  def is_administrator?
    sessions_signed_in? && sessions_current_user.is_administrator?
  end 

  # Can be optimized to just look at ProjectMembers likely
  def is_project_administrator?
    sessions_signed_in? && sessions_project_selected? && 
    sessions_current_project.project_members.exists?(is_project_administrator: true, user_id: sessions_current_user_id) 
  end 

  def is_superuser?
    sessions_signed_in? && ( is_administrator? || is_project_administrator? )
  end 

  def is_project_member?(user, project)
    project.project_members.include?(user) 
  end

  def authorize_project_selection(user, project)
    project.project_members.where(user: user, project: project) 
  end

  def require_sign_in
    redirect_to root_url, notice: "Please sign in." unless sessions_signed_in?
  end

  def require_project_selection
    redirect_to root_url, notice: "Please select a project." unless sessions_current_project
  end

  def require_sign_in_and_project_selection
    redirect_to root_url, notice: "Whoa there, sign in and select a project first." unless sessions_signed_in? && sessions_project_selected?
  end

  def require_administrator_sign_in
    redirect_to root_url, notice: "Please sign in as an administrator." unless is_administrator? 
  end

  def require_project_administrator_sign_in
    redirect_to root_url, notice: "Please sign in as a project administrator." unless is_project_administrator? 
  end

  def require_superuser_sign_in
    redirect_to root_url, notice: "Please sign in as a project administrator or administrator." unless is_superuser?
  end

  # TODO: make this a non-controller method
  def session_header_links
    [
      project_settings_link, 
      administration_link,
      link_to('Account', sessions_current_user),
      link_to('Sign out', signout_path, method: :delete)
    ]
  end

  # @param [String]
  # @param [String]
  def favorite_page_link(kind, name)
    if favorites?(kind, name)
      link_to('Unfavorite page', unfavorite_page_path(kind: kind, name: name), method: :post, remote: true, id: 'unfavorite_link', title: 'Remove to favorite')
    else
      link_to('Favorite page', favorite_page_path(kind: kind, name: name), method: :post, remote: true, id: 'favorite_link', title: 'Add to favorite.')
    end
  end

  def has_hub_favorites?
    sessions_current_user.hub_favorites[sessions_current_project_id.to_s] ? true : false
  end

  # @param [String]
  # @param [String]
  def favorites?(kind, name)
    has_hub_favorites? && sessions_current_user.hub_favorites[sessions_current_project_id.to_s][kind].include?(name)
  end

  def project_settings_link
    (sessions_project_selected? && is_superuser?) ? link_to('Project', project_path(sessions_current_project)) : nil
  end

  def administration_link
    sessions_current_user.is_administrator? ? link_to('Administration', administration_path) : nil
  end


end
