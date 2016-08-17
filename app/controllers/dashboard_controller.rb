# frozen_string_literal: true
class DashboardController < ApplicationController
  def index
    public_action
    @provider_roles = filter_dashboard_roles
    @provided_attributes =
      @subject.provided_attributes.includes(
        permitted_attribute: [:provider, :available_attribute]
      )
  end

  private

  def filter_dashboard_roles
    @subject.roles.select { |role| web_role?(role) }.group_by(&:provider)
  end

  def web_role?(role)
    subject.permits?("providers:#{role.provider.id}:read")
  end
end
