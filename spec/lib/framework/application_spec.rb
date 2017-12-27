# frozen_string_literal: true

describe 'Framework::Application' do
  let(:env) { Rack::MockRequest::DEFAULT_ENV.dup }

  subject { Framework::Application }

  describe 'has class methods' do
    it { expect(subject).to respond_to(:mount) }
    it { expect(subject).to respond_to(:call) }
  end

  describe 'method #call' do
    let(:response) { [200, env, 'My App'] }

    before do
      klass = class_double('FakeEndpoint', new: instance_double('FakeEndpoint', response: response))
      subject.mount(klass)
    end

    it 'runs application' do
      expect(subject.call(env)).to eql(response)
    end
  end
end
