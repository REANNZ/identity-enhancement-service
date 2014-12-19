require 'spec_helper'

require 'api_constraints'

RSpec.describe APIConstraints do
  let(:matching_request) { double }
  let(:non_matching_request) { double }
  let(:matching_header) { 'application/vnd.aaf.ide.v1+json' }
  let(:non_matching_header) { 'application/vnd.aaf.ide.v2+json' }

  before do
    allow(matching_request).to receive(:headers)
      .and_return('Accept' => matching_header)
    allow(non_matching_request).to receive(:headers)
      .and_return('Accept' => non_matching_header)
  end

  context '#matches?' do
    context 'with default: false' do
      subject { described_class.new(version: '1', default: false) }

      it 'is true for a valid request' do
        expect(subject.matches?(matching_request)).to be_truthy
      end

      it 'is false for a non-matching request' do
        expect(subject.matches?(non_matching_request)).to be_falsey
      end
    end

    context 'with default: true' do
      subject { described_class.new(version: '1', default: true) }

      it 'is true for a valid request' do
        expect(subject.matches?(matching_request)).to be_truthy
      end

      it 'is true for a non-matching request' do
        expect(subject.matches?(non_matching_request)).to be_truthy
      end
    end
  end
end
