# frozen_string_literal: true

RSpec.shared_examples 'an audited model' do
  subject { create(factory).reload }
  let(:factory) { described_class.name.underscore.to_sym }

  # FactoryGirl doesn't include associated objects in `attributes_for`
  let(:base_attrs) do
    build(factory).attributes.merge(audit_comment: 'test')
                  .symbolize_keys.except(:created_at, :updated_at, :id)
  end

  context 'with an audit message' do
    let(:attrs) { base_attrs }

    it 'allows creation' do
      expect { described_class.create!(attrs) }
        .to not_raise_error
        .and change(described_class, :count).by(1)
    end

    it 'allows an edit' do
      expect { subject.update_attributes!(attrs) }.not_to raise_error
      expect(subject.reload).to have_attributes(attrs.except(:audit_comment))
    end

    it 'allows deletion' do
      obj = described_class.find(subject.id)
      obj.audit_comment = base_attrs[:audit_comment]

      expect { obj.destroy! }.to not_raise_error
        .and change(described_class, :count).by(-1)
    end
  end

  context 'without an audit message' do
    def tx
      described_class.transaction { yield }
    end

    let(:attrs) { base_attrs.except(:audit_comment) }

    it 'fails creation' do
      expect { tx { described_class.create!(attrs) } }
        .to raise_error(ActiveRecord::RecordInvalid,
                        /Audit comment can't be blank/)
        .and not_change(described_class, :count)
    end

    it 'fails an edit' do
      initial = subject.attributes.dup.except('created_at', 'updated_at')
      expect { tx { subject.update_attributes!(attrs) } }
        .to raise_error(ActiveRecord::RecordInvalid,
                        /Audit comment can't be blank/)
      expect(subject.reload).to have_attributes(initial)
    end

    it 'fails deletion' do
      obj = described_class.find(subject.id)

      expect { tx { obj.destroy! } }
        .to raise_error(ActiveRecord::RecordNotDestroyed)
        .and not_change(described_class, :count)
    end
  end

  context 'with a current user' do
    let(:user) { create(:subject) }
    let(:controller) { double }
    let(:attrs) { base_attrs }

    # https://github.com/collectiveidea/audited/blob/v4.0.0/lib/audited/sweeper.rb
    around do |example|
      ::Audited.store[:current_controller] = controller
      example.run
      ::Audited.store[:current_controller] = nil
    end

    before { allow(controller).to receive(:subject).and_return(user) }

    it 'records the user on creation' do
      obj = described_class.create!(attrs)
      expect(obj.audits.last.user).to eq(user)
    end

    it 'records the user on edit' do
      subject.update_attributes!(attrs)
      expect(subject.audits.last.user).to eq(user)
    end

    it 'records the user on destroy' do
      subject.audit_comment = attrs[:audit_comment]
      subject.destroy!
      expect(subject.audits.last.user).to eq(user)
    end
  end
end
