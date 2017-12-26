# frozen_string_literal: true

describe 'Framework' do
  subject { Framework }

  describe 'returns its version' do
    it { expect(subject).to respond_to(:version) }
    it { expect(subject).to have_constant(:VERSION) }
  end
end
