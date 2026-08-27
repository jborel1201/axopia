module Opco
  class DashboardController < ApplicationController
    include RoleRestricted
    restrict_to_role UserRoles::OPCO

    def index
    end
  end
end
