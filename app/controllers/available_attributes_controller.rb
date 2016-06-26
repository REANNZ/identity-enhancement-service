class AvailableAttributesController < ApplicationController
  def index
    check_access!('admin:attributes:list')
    @attributes = AvailableAttribute.all
  end

  def new
    check_access!('admin:attributes:create')
    @attribute = AvailableAttribute.new
  end

  def create
    check_access!('admin:attributes:create')
    audit_attrs = { audit_comment: 'Created attribute from admin interface' }
    @attribute =
      AvailableAttribute.new(audit_attrs.merge(available_attribute_params))

    unless @attribute.save
      return form_error('new', 'Unable to create attribute', @attribute)
    end

    flash[:success] = "Created attribute with name: #{@attribute.name} and " \
                      "value #{@attribute.value}"

    redirect_to available_attributes_path
  end

  def edit
    check_access!('admin:attributes:update')
    @attribute = AvailableAttribute.find(params[:id])
  end

  def update
    check_access!('admin:attributes:update')

    @attribute = AvailableAttribute.find(params[:id])
    unless update_available_attribute(@attribute)
      return form_error('edit', 'Unable to save attribute', @attribute)
    end

    flash[:success] = "Updated attribute with name: #{@attribute.name} and " \
                      "value: #{@attribute.value}"

    redirect_to(available_attributes_path)
  end

  def show
    check_access!('admin:attributes:read')
    @attribute = AvailableAttribute.find(params[:id])
  end

  def destroy
    check_access!('admin:attributes:delete')
    @attribute = AvailableAttribute.find(params[:id])
    @attribute.audit_comment = 'Deleted attribute from admin interface'
    if @attribute.destroy
      flash[:success] = "Deleted attribute with name: #{@attribute.name} and " \
                        "value: #{@attribute.value}"
    else
      flash[:error] = 'Unable to delete an available attribute while in use'
    end

    redirect_to available_attributes_path
  end

  def audits
    check_access!('admin:attributes:audit')
    if params[:id]
      @attribute = AvailableAttribute.find(params[:id])
      @audits = @attribute.audits.all
    else
      @audits = AvailableAttribute.audits.all
    end
  end

  private

  def available_attribute_params
    params.require(:available_attribute).permit(:name, :value, :description)
  end

  def update_available_attribute(attribute)
    audit_attrs = { audit_comment: 'Edited attribute from admin interface' }
    attribute.update_attributes(audit_attrs.merge(available_attribute_params))
  end
end
