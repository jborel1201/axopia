module Stagiaire
  class DashboardController < ApplicationController
    include RoleRestricted
    restrict_to_role UserRoles::STAGIAIRE

    def index
    end
  end
end
