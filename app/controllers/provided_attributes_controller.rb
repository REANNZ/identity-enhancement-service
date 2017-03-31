# frozen_string_literal: true

class ProvidedAttributesController < ApplicationController
  NotPermitted = Class.new(StandardError)
  private_constant :NotPermitted
  rescue_from NotPermitted, with: :bad_request

  before_action { @provider = Provider.find(params[:provider_id]) }

  def index
    check_access!("providers:#{@provider.id}:attributes:list")
    @objects = Subject.all
    @provided_attributes = ProvidedAttribute.for_provider(@provider)
  end

  def select_subject
    check_access!("providers:#{@provider.id}:attributes:create")
    @filter = params[:filter]
    @objects = Subject.filter(@filter).order(:name)
                      .paginate(page: params[:page])
  end

  def new
    check_access!("providers:#{@provider.id}:attributes:create")
    @object = find_subject
    @provisioned_subject = @object.provision(@provider)
    @invitation = @object.invitation unless @object.complete?

    @provided_attributes = @object.provided_attributes.for_provider(@provider)
    @permitted_attributes = available_permitted_attributes(@provided_attributes)
  end

  def create
    check_access!("providers:#{@provider.id}:attributes:create")

    @provided_attribute = create_provided_attribute
    flash[:success] = creation_message(@provided_attribute)

    redirect_from_create_or_destroy(@provided_attribute.subject)
  end

  def destroy
    check_access!("providers:#{@provider.id}:attributes:delete")

    @provided_attribute = delete_provided_attribute
    flash[:success] = deletion_message(@provided_attribute)

    redirect_from_create_or_destroy(@provided_attribute.subject)
  end

  private

  def redirect_from_create_or_destroy(subject)
    if requested_enhancement
      return redirect_to [@provider, requested_enhancement]
    end

    redirect_to [:new, @provider, :provided_attribute, subject_id: subject.id]
  end

  def permitted_attribute
    id = provided_attribute_params[:permitted_attribute_id]
    @permitted_attribute ||= @provider.permitted_attributes.find(id)
  rescue ActiveRecord::RecordNotFound
    raise NotPermitted
  end

  def attribute_attrs
    attribute = permitted_attribute.available_attribute
    { name: attribute.name, value: attribute.value }
  end

  def provided_attribute_params
    params.require(:provided_attribute)
          .permit(:subject_id, :permitted_attribute_id, :public)
  end

  def creation_message(provided_attribute)
    "Provided attribute with name #{provided_attribute.name} and value " \
      "#{provided_attribute.value} to #{provided_attribute.subject.name}"
  end

  def deletion_message(provided_attribute)
    "Removed attribute with name #{provided_attribute.name} and value " \
      "#{provided_attribute.value} from #{provided_attribute.subject.name}"
  end

  def create_provided_attribute
    ProvidedAttribute.transaction do
      enhancement_attrs = { actioned: true, actioned_by: subject }
      enhancement_attrs[:audit_comment] =
        'Automatically actioned by providing an attribute'

      requested_enhancement.try(:update_attributes!, enhancement_attrs)

      attrs = provided_attribute_params.merge(attribute_attrs)
      attrs[:audit_comment] = 'Provided attribute via web interface'
      permitted_attribute.provided_attributes.create!(attrs)
                         .tap { |attr| attr.subject.provision(@provider) }
    end
  end

  def delete_provided_attribute
    scope = ProvidedAttribute.for_provider(@provider)

    scope.find(params[:id]).tap do |provided_attribute|
      provided_attribute.audit_comment = 'Revoked attribute via web interface'
      provided_attribute.destroy!
    end
  end

  def available_permitted_attributes(provided_attributes)
    ids = provided_attributes.map(&:permitted_attribute_id)
    @provider.permitted_attributes.reject { |a| ids.include?(a.id) }
  end

  def find_subject
    return Subject.find(params[:subject_id]) if params[:subject_id]

    requested_enhancement.subject
  end

  def requested_enhancement
    return nil unless params[:requested_enhancement_id]
    @requested_enhancement ||=
      RequestedEnhancement.find(params[:requested_enhancement_id])
  end
end
