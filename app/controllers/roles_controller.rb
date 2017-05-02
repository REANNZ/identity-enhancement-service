# frozen_string_literal: true

class RolesController < ApplicationController
  before_action { @provider = Provider.find(params[:provider_id]) }

  def index
    check_access!("providers:#{@provider.id}:roles:list")
    @roles = @provider.roles.all
  end

  def new
    check_access!('admin:roles:create')
    @role = @provider.roles.new
  end

  def create
    check_access!('admin:roles:create')
    audit_attrs = { audit_comment: 'Created from providers interface' }
    @role = @provider.roles.create!(role_params.merge(audit_attrs))

    flash[:success] = "Created role #{@role.name} at #{@provider.name}"

    redirect_to([@provider, :roles])
  end

  def edit
    check_access!('admin:roles:update')
    @role = @provider.roles.find(params[:id])
  end

  def update
    check_access!('admin:roles:update')
    audit_attrs = { audit_comment: 'Updated from providers interface' }
    @role = @provider.roles.find(params[:id])
    @role.update_attributes!(role_params.merge(audit_attrs))

    flash[:success] = "Updated role #{@role.name} at #{@provider.name}"

    redirect_to([@provider, :roles])
  end

  def show
    check_access!("providers:#{@provider.id}:roles:read")
    @role = @provider.roles.find(params[:id])
  end

  def destroy
    check_access!('admin:roles:delete')
    @role = @provider.roles.find(params[:id])
    @role.audit_comment = 'Deleted from providers interface'
    @role.destroy!

    flash[:success] = "Deleted role #{@role.name} from #{@provider.name}"

    redirect_to([@provider, :roles])
  end

  private

  def role_params
    params.require(:role).permit(:name)
  end
end
