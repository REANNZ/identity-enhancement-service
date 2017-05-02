# frozen_string_literal: true

class PermissionsController < ApplicationController
  before_action do
    @provider = Provider.find(params[:provider_id])
    @role = @provider.roles.find(params[:role_id])
  end

  def index
    check_access!('admin:roles:read')
    @permissions = @role.permissions.all
    @new_permission = @role.permissions.build
  end

  def create
    check_access!('admin:roles:update')

    audit_attrs = { audit_comment: 'Added permission via admin interface' }
    permission = @role.permissions.new(permission_params.merge(audit_attrs))

    if permission.save
      flash[:success] = "Added permission: #{permission.value}"
    else
      flash[:error] = "Unable to add permission: #{permission.value}\n\n" \
                      "Please check the permission isn't already in this role."
    end

    redirect_to(provider_role_permissions_path(@provider, @role))
  end

  def destroy
    check_access!('admin:roles:update')

    @permission = @role.permissions.find(params[:id])
    @permission.audit_comment = 'Removed permission via admin interface'
    @permission.destroy!

    flash[:success] = "Removed permission: #{@permission.value}"
    redirect_to(provider_role_permissions_path(@provider, @role))
  end

  private

  def permission_params
    params.require(:permission).permit(:value)
  end
end
