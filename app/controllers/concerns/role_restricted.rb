module RoleRestricted
  extend ActiveSupport::Concern

  class_methods do
    def restrict_to_role(role)
      before_action { authorize_role!(role) }
    end
  end

  private

  def authorize_role!(role)
    return if current_user.has_role?(role)

    redirect_to after_sign_in_path_for(current_user), alert: "Vous n'avez pas accès à cette page."
  end
end
