class PermittedAttributesController < ApplicationController
  before_action { @provider = Provider.find(params[:provider_id]) }

  def index
    check_access!('admin:permitted_attributes:list')
    @permitted_attributes = @provider.permitted_attributes.all
    already_assigned = @permitted_attributes.map(&:available_attribute)
    @available_attributes = AvailableAttribute.all - already_assigned
  end

  def create
    check_access!('admin:permitted_attributes:create')
    audit_attrs = { audit_comment: 'Added via admin interface' }
    record = @provider.permitted_attributes
                      .create!(permitted_attribute_params.merge(audit_attrs))

    flash[:success] = creation_message(record)

    redirect_to provider_permitted_attributes_path(@provider)
  end

  def destroy
    check_access!('admin:permitted_attributes:delete')
    @permitted_attribute = @provider.permitted_attributes.find(params[:id])
    @permitted_attribute.audit_comment = 'Removed via admin interface'
    @permitted_attribute.destroy!

    flash[:success] = deletion_message(@permitted_attribute)

    redirect_to provider_permitted_attributes_path(@provider)
  end

  private

  def permitted_attribute_params
    params.require(:permitted_attribute).permit(:available_attribute_id)
  end

  def creation_message(permitted_attribute)
    attr = permitted_attribute.available_attribute
    flash[:success] = "Added permitted attribute to #{@provider.name} with " \
                      "name: #{attr.name} and value #{attr.value}"
  end

  def deletion_message(permitted_attribute)
    attr = permitted_attribute.available_attribute
    flash[:success] = "Removed permitted attribute from #{@provider.name} " \
                      "with name: #{attr.name} and value #{attr.value}"
  end
end
