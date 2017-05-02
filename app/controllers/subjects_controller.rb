# frozen_string_literal: true

class SubjectsController < ApplicationController
  # @subject is the current user. We use @objects and @object to sidestep that.

  def index
    check_access!('admin:subjects:list')
    @filter = params[:filter]
    @objects = Subject.filter(@filter).order(:name)
                      .paginate(page: params[:page])
  end

  def show
    check_access!('admin:subjects:read')
    @object = Subject.find(params[:id])
  end

  def update
    check_access!('admin:subjects:update')

    @object = Subject.find(params[:id])
    @object.attributes = subject_params
    word = @object.enabled? ? 'Enabled' : 'Disabled'
    @object.update_attributes!(audit_comment: "#{word} Subject")

    flash[:success] = "#{@object.name} has been #{word.downcase}"

    redirect_to @object
  end

  def destroy
    check_access!('admin:subjects:delete')
    @object = Subject.find(params[:id])
    @object.audit_comment = 'Deleted from admin interface'
    @object.destroy!

    flash[:success] = "Deleted subject #{@object.name}"

    redirect_to(subjects_path)
  end

  def audits
    check_access!('admin:subjects:audit')
    @object = Subject.find(params[:id])
    @audits = @object.audits.all
  end

  private

  def subject_params
    params.require(:subject).permit(:enabled)
  end
end
