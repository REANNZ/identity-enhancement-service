# frozen_string_literal: true
class ProvisionedSubjectsController < ApplicationController
  before_action { @provider = Provider.find(params[:provider_id]) }

  def edit
    check_access!("providers:#{@provider.id}:attributes:create")
    @provisioned_subject = find_provisioned_subject
  end

  def update
    check_access!("providers:#{@provider.id}:attributes:create")
    @provisioned_subject = find_provisioned_subject
    @provisioned_subject.update_attributes!(provisioned_subject_params)
    redirect_to [:new, @provider, :provided_attribute,
                 subject_id: @provisioned_subject.subject_id]
  end

  private

  def find_provisioned_subject
    @provider.provisioned_subjects.find(params[:id])
  end

  def provisioned_subject_params
    params.require(:provisioned_subject).permit(:expires_at)
  end
end
