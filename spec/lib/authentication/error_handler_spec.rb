# frozen_string_literal: true

require 'rails_helper'

module Authentication
  RSpec.describe ErrorHandler do
    context '#handle' do
      let(:env) { {} }
      let(:exception) { StandardError.new('test error') }
      def run
        subject.handle(env, exception)
      end

      it 'raises the exception' do
        expect { run }.to raise_error(StandardError, /test error/)
      end
    end
  end
end
