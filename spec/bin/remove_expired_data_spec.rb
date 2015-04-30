require 'rails_helper'
load Rails.root.join('bin/remove_expired_data')

RSpec.describe 'bin/remove_expired_data' do
  def run
    RemoveExpiredData.perform
  end

  around do |spec|
    old = $stderr
    $stderr = StringIO.new
    begin
      Timecop.freeze { spec.run }
    ensure
      $stderr = old
    end
  end

  context 'with an expired invitation' do
    let(:invitation) do
      create(:invitation, used: false, expires: 1.second.from_now)
    end

    let(:object) { invitation.subject }

    around do |spec|
      invitation
      Timecop.travel(1.minute) { spec.run }
    end

    it 'removes the subject' do
      expect { run }.to change(Subject, :count).by(-1)
      expect { object.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'disassociates the invitation' do
      expect { run }.to change { invitation.reload.subject_id }.to be_nil
    end

    context 'when the invitation is used' do
      let(:invitation) do
        create(:invitation, used: true, expires: 1.second.from_now)
      end

      it 'leaves the subject intact' do
        expect { run }.not_to change(Subject, :count)
        object.reload
      end
    end
  end

  context 'with a nonexpired invitation' do
    let!(:invitation) do
      create(:invitation, used: false, expires: 4.weeks.from_now)
    end

    let(:object) { invitation.subject }

    it 'leaves the subject intact' do
      expect { run }.not_to change(Subject, :count)
      object.reload
    end
  end

  context 'with an expired provisioned subject' do
    let(:provisioned_subject) do
      create(:provisioned_subject, expires_at: 1.minute.ago)
    end

    let(:permitted_attribute) do
      create(:permitted_attribute, provider: provider)
    end

    let(:provider) { provisioned_subject.provider }
    let(:object) { provisioned_subject.subject }
    let!(:attribute) do
      create(:provided_attribute, subject: object,
                                  permitted_attribute: permitted_attribute)
    end

    it 'removes the attribute' do
      expect { run }.to change(ProvidedAttribute, :count).by(-1)
      expect { attribute.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'removes the provisioned subject' do
      expect { run }.to change(ProvisionedSubject, :count).by(-1)
      expect { provisioned_subject.reload }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'with a nonexpired provisioned subject' do
    let!(:provisioned_subject) do
      create(:provisioned_subject, expires_at: 1.hour.from_now)
    end

    it 'leaves the provisioned subject intact' do
      expect { run }.not_to change(ProvisionedSubject, :count)
      provisioned_subject.reload
    end
  end
end
