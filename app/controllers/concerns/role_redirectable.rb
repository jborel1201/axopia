module RoleRedirectable
  extend ActiveSupport::Concern

  # Priorité décroissante : si un utilisateur cumule plusieurs rôles, le premier
  # rôle trouvé dans cette liste détermine son espace par défaut.
  ROLE_ROOT_PATHS = {
    UserRoles::ADMIN        => :admin_root_path,
    UserRoles::GESTIONNAIRE => :gestionnaire_root_path,
    UserRoles::FORMATEUR    => :formateur_root_path,
    UserRoles::OPCO         => :opco_root_path,
    UserRoles::STAGIAIRE    => :stagiaire_root_path
  }.freeze

  def after_sign_in_path_for(resource)
    return super unless resource.is_a?(User)

    _role, path_helper = ROLE_ROOT_PATHS.find { |role, _| resource.has_role?(role) }
    path_helper ? send(path_helper) : super
  end
end
