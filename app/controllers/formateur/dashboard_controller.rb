module Formateur
  class DashboardController < ApplicationController
    include RoleRestricted
    restrict_to_role UserRoles::FORMATEUR

    def index
    end
  end
end
