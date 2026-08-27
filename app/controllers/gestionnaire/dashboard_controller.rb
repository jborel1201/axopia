module Gestionnaire
  class DashboardController < ApplicationController
    include RoleRestricted
    restrict_to_role UserRoles::GESTIONNAIRE

    def index
    end
  end
end
