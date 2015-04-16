class ProvidedAttributesController < ApplicationController
  NotPermitted = Class.new(StandardError)
  private_constant :NotPermitted
  rescue_from NotPermitted, with: :bad_request

  before_action { @provider = Provider.find(params[:provider_id]) }

  def index
    check_access!("providers:#{@provider.id}:attributes:list")
    @objects = Subject.all
    @provided_attributes =
      ProvidedAttribute.joins(:permitted_attribute)
      .where('permitted_attributes.provider_id' => @provider.id)
  end

  def select_subject
    check_access!("providers:#{@provider.id}:attributes:create")
    @filter = params[:filter]
    @objects = Subject.filter(@filter).order(:name)
               .paginate(page: params[:page])
  end

  def new
    check_access!("providers:#{@provider.id}:attributes:create")
    @object = Subject.find(params[:subject_id])
    @invitation = @object.invitation unless @object.complete?

    @provided_attributes = @object.provided_attributes.for_provider(@provider)
    @permitted_attributes = available_permitted_attributes(@provided_attributes)
  end

  def create
    check_access!("providers:#{@provider.id}:attributes:create")

    @provided_attribute = create_provided_attribute
    flash[:success] = creation_message(@provided_attribute)

    @subject = @provided_attribute.subject
    redirect_to new_provider_provided_attribute_path(@provider,
                                                     subject_id: @subject.id)
  end

  def destroy
    check_access!("providers:#{@provider.id}:attributes:delete")

    @provided_attribute = delete_provided_attribute
    flash[:success] = deletion_message(@provided_attribute)

    @subject = @provided_attribute.subject
    redirect_to new_provider_provided_attribute_path(@provider,
                                                     subject_id: @subject.id)
  end

  private

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
      .permit(:subject_id, :permitted_attribute_id)
  end

  def creation_message(provided_attribute)
    subject = provided_attribute.subject
    "Provided attribute with name #{provided_attribute.name} and value " \
      "#{provided_attribute.value} to #{subject.name}"
  end

  def deletion_message(provided_attribute)
    subject = provided_attribute.subject
    "Removed attribute with name #{provided_attribute.name} and value " \
      "#{provided_attribute.value} from #{subject.name}"
  end

  def create_provided_attribute
    attrs = provided_attribute_params.merge(attribute_attrs)
    attrs.merge!(audit_comment: 'Provided attribute via web interface')
    permitted_attribute.provided_attributes.create!(attrs)
  end

  def delete_provided_attribute
    scope = ProvidedAttribute.joins(:permitted_attribute)
            .where('permitted_attributes.provider_id' => @provider.id)

    scope.find(params[:id]).tap do |provided_attribute|
      provided_attribute.audit_comment = 'Revoked attribute via web interface'
      provided_attribute.destroy!
    end
  end

  def available_permitted_attributes(provided_attributes)
    ids = provided_attributes.map(&:permitted_attribute_id)
    @provider.permitted_attributes.reject { |a| ids.include?(a.id) }
  end
end
