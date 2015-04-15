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
end
