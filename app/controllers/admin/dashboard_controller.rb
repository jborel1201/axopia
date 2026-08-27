module Admin
  class DashboardController < ApplicationController
    include RoleRestricted
    restrict_to_role UserRoles::ADMIN

    def index
    end
  end
end
