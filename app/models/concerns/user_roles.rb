module UserRoles
  ADMIN         = "admin"
  GESTIONNAIRE  = "gestionnaire"
  FORMATEUR     = "formateur"
  STAGIAIRE     = "stagiaire"
  OPCO          = "opco"

  ALL = [ ADMIN, GESTIONNAIRE, FORMATEUR, STAGIAIRE, OPCO ].freeze

  def self.options_for_select
    ALL.map { |r| [ I18n.t("roles.#{r}"), r ] }
  end
end
