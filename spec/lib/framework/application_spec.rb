# frozen_string_literal: true

describe 'Framework::Application' do
  subject { Framework::Application }

  describe 'has class methods' do
    it { expect(subject).to respond_to(:mount) }
    it { expect(subject).to respond_to(:call) }
  end
end
