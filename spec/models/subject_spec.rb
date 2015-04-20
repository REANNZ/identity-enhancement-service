require 'rails_helper'

require 'gumboot/shared_examples/subjects'

RSpec.describe Subject, type: :model do
  include_examples 'Subjects'
  it_behaves_like 'an audited model'

  context 'validations' do
    subject { build(:subject, complete: false) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.not_to validate_uniqueness_of(:name) }
    it { is_expected.to validate_presence_of(:mail) }
    it { is_expected.to validate_uniqueness_of(:mail) }
    it { is_expected.not_to validate_presence_of(:targeted_id) }
    it { is_expected.not_to validate_presence_of(:shared_token) }
    it { is_expected.to validate_uniqueness_of(:shared_token) }

    context 'with a complete subject' do
      subject { build(:subject, complete: true) }

      it { is_expected.to validate_presence_of(:targeted_id) }
      it { is_expected.to validate_presence_of(:shared_token) }
      it { is_expected.to validate_uniqueness_of(:shared_token) }
    end
  end

  subject { create(:subject) }

  let(:role) do
    create(:role).tap do |role|
      create(:permission, value: 'a:*', role: role)
    end
  end

  context '#permits?' do
    it 'derives permissions from roles' do
      subject.subject_role_assignments.create(role_id: role.id)
      expect(subject.permits?('a:b:c')).to be_truthy
    end

    it 'only applies permissions from assigned roles' do
      role
      expect(subject.permits?('a:b:c')).to be_falsey
    end
  end

  context '#functioning?' do
    context 'when enabled' do
      subject { create(:subject, enabled: true) }
      it { is_expected.to be_functioning }
    end

    context 'when disabled' do
      subject { create(:subject, enabled: false) }
      it { is_expected.not_to be_functioning }
    end
  end

  context '#accept' do
    subject { create(:subject, :incomplete) }

    let(:attrs) do
      attributes_for(:subject).slice(:name, :mail, :targeted_id, :shared_token)
    end

    let(:invitation) { create(:invitation, subject: subject) }

    def run
      subject.accept(invitation, attrs)
    end

    it 'updates the attributes' do
      run
      expect(subject.reload).to have_attributes(attrs)
    end

    it 'marks the invitation as used' do
      expect { run }.to change { invitation.reload.used? }.to be_truthy
    end

    it 'marks the subject as complete' do
      expect { run }.to change { subject.reload.complete? }.to be_truthy
    end

    context 'when a merge is required' do
      let(:other) { create(:subject) }
      let(:invitation) { create(:invitation, subject: other).reload }

      it 'reassigns the invitation' do
        expect { run }.to change { invitation.reload.subject }.to(subject)
      end

      it 'merges the subjects' do
        expect(subject).to receive(:merge).with(other).and_call_original
        run
        expect { other.reload }.to raise_error
      end
    end
  end

  context '#providers' do
    let!(:provider) do
      create(:provider).tap do |provider|
        subject.roles.first.update_attributes!(provider: provider)
      end
    end
    let!(:other) { create(:provider) }
  end

  context 'associated objects' do
    context 'subject_role_assignments' do
      let(:child) { create(:subject_role_assignment) }
      subject { child.subject }
      it_behaves_like 'an association which cascades delete'
    end

    context 'provided_attributes' do
      let!(:child) { create(:provided_attribute) }
      subject { child.subject }
      it_behaves_like 'an association which cascades delete'
    end

    context 'requested_enhancements' do
      let!(:child) { create(:requested_enhancement) }
      subject { child.subject }
      it_behaves_like 'an association which cascades delete'
    end
  end

  context '#merge' do
    RSpec::Matchers.define_negated_matcher(:not_include, :include)

    let!(:object) { create(:subject) }
    let!(:other) { create(:subject) }

    context 'with a role' do
      let(:role) { create(:role) }
      let!(:role_assoc) do
        create(:subject_role_assignment, subject: other, role: role)
      end

      it 'moves the roles' do
        expect { object.merge(other) }.to change { object.roles(true).to_a }
          .to include(role)
      end

      it 'removes the existing role assignment' do
        expect { object.merge(other) }.to change { other.roles(true).to_a }
          .to not_include(role)
      end

      context 'when the target already has the role' do
        let!(:existing) do
          create(:subject_role_assignment, subject: object, role: role)
        end

        it 'creates no extra records' do
          expect { object.merge(other) }
            .not_to change { object.subject_role_assignments.count }
        end

        it 'still removes the existing role assignment' do
          expect { object.merge(other) }.to change { other.roles(true).to_a }
            .to not_include(role)
        end
      end
    end

    context 'with an attribute' do
      let!(:attr) { create(:provided_attribute, subject: other) }

      it 'moves the provided attributes' do
        expect { object.merge(other) }
          .to change { object.provided_attributes(true).to_a }
          .to include(have_attributes(name: attr.name, value: attr.value))
      end

      it 'removes the existing provided attribute' do
        expect { object.merge(other) }
          .to change { other.provided_attributes(true).to_a }
          .to not_include(have_attributes(name: attr.name, value: attr.value))
      end

      context 'when the target already has the attribute' do
        let!(:existing) do
          create(:provided_attribute,
                 name: attr.name, value: attr.value, subject: object,
                 permitted_attribute: attr.permitted_attribute)
        end

        it 'creates no extra records' do
          expect { object.merge(other) }
            .not_to change { object.provided_attributes.count }
        end

        it 'still removes the existing provided attribute' do
          expect { object.merge(other) }
            .to change { other.provided_attributes(true).to_a }
            .to not_include(have_attributes(name: attr.name, value: attr.value))
        end
      end
    end

    it 'removes the other subject' do
      expect { object.merge(other) }.to change(Subject, :count).by(-1)
      expect { other.reload }.to raise_error
    end
  end
end
