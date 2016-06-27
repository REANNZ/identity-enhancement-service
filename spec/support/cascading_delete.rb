# frozen_string_literal: true
RSpec.shared_examples 'an association which cascades delete' do
  it 'deletes the child object' do
    subject.audit_comment = 'Deleted while testing cascading delete'
    expect { subject.destroy! }.to change(child.class, :count).by(-1)
    expect { child.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
