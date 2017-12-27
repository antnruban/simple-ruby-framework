# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

describe 'Framework::Endpoint' do
  subject { Framework::Endpoint }

  let(:env)    { Rack::MockRequest::DEFAULT_ENV.dup }
  let(:object) { subject.new(env) }

  describe 'class methods' do
    it { expect(subject).to respond_to(:headers) }
    it { expect(subject).to respond_to(:get) }
    it { expect(subject).to respond_to(:post) }
  end

  describe 'instance methods' do
    it { expect(object).to respond_to(:response) }
  end

  describe 'defines routing methods' do
    describe '#get' do
      it 'without parameters' do
        meth_name = subject.get('/') { { result: 'foo' } }
        expect(object).respond_to?(meth_name)
      end

      it 'with parameters' do
        meth_name = subject.get('/') { |params| { result: params } }
        expect(object.method(meth_name).arity).to eql(1)
      end
    end

    describe '#post' do
      it 'without parameters' do
        meth_name = subject.post('/') { { result: 'foo' } }
        expect(object).respond_to?(meth_name)
      end

      it 'with parameters' do
        meth_name = subject.post('/') { |params| { result: params } }
        expect(object.method(meth_name).arity).to eql(1)
      end
    end
  end

  describe 'headers' do
    let(:headers)       { object.instance_variable_get('@headers') }
    let(:default_ct)    { { name: 'Content-Type',  value: 'application/json' } }
    let(:custom_header) { { name: 'Custom-Header', value: 'custom-value' } }

    it 'assings default Content-Type' do
      subject.headers({})
      expect(headers[default_ct[:name]]).to eql(default_ct[:value])
    end

    it 'overrides default Content-Type' do
      subject.headers(default_ct[:name] => custom_header[:value])
      expect(headers[default_ct[:name]]).to eql(custom_header[:value])
    end

    it 'applies custom headers' do
      subject.headers(custom_header[:name] => custom_header[:value])
      expect(headers[custom_header[:name]]).to eql(custom_header[:value])
    end
  end

  describe 'HTTP methods' do
    let(:route) { '/route' }
    let(:success_status) { 200 }

    describe 'GET' do
      describe 'success route call' do
        let(:expected_body) { [{ foo: 'bar' }.to_json] }

        before do
          subject.get(route) { { foo: 'bar' } }
          env['PATH_INFO'] = route
          env['REQUEST_METHOD'] = 'GET'
        end

        it 'returns correct status' do
          status, = object.response
          expect(status).to eql(success_status)
        end

        it 'correct body' do
          _, _, rack_resp = object.response
          expect(rack_resp.body).to eql(expected_body)
        end
      end

      describe 'success route call with parmeters' do
        let(:expected_body) { [{ result: { foo: 'bar' } }.to_json] }

        before do
          subject.get(route) { |params| { result: params } }
          env['PATH_INFO'] = route
          env['REQUEST_METHOD'] = 'GET'
          env['QUERY_STRING'] = 'foo=bar'
        end

        it 'correct body' do
          _, _, rack_resp = object.response
          expect(rack_resp.body).to eql(expected_body)
        end

        it 'returns correct status' do
          status, = object.response
          expect(status).to eql(success_status)
        end
      end
    end

    describe 'POST' do
      describe 'when Content-Type header is missed or incorrect returns' do
        let(:route) { '/foo' }
        let(:error_status) { 415 }
        let(:error_body)   { [{ error: Rack::Utils::HTTP_STATUS_CODES[error_status] }.to_json] }

        before do
          subject.post(route) { |params| params }
          env['CONTENT_TYPE'] = 'text/html'
          env['PATH_INFO'] = route
          env['REQUEST_METHOD'] = 'POST'
        end

        it 'correct status' do
          status, = object.response
          expect(status).to eql(error_status)
        end

        it 'correct body' do
          _, _, rack_resp = object.response
          expect(rack_resp.body).to eql(error_body)
        end
      end

      describe 'success route call' do
        let(:expected_body) { [{ foo: 'bar' }.to_json] }

        before do
          subject.post(route) { { foo: 'bar' } }
          env['PATH_INFO'] = route
          env['REQUEST_METHOD'] = 'POST'
        end

        it 'returns correct status' do
          status, = object.response
          expect(status).to eql(success_status)
        end

        it 'correct body' do
          _, _, rack_resp = object.response
          expect(rack_resp.body).to eql(expected_body)
        end
      end

      describe 'success route call with parmeters' do
        let(:params) { { name: 'NAME' } }
        let(:expected_body) { [{ new_name: params[:name] }.to_json] }

        before do
          subject.post(route) { |params| { new_name: params[:name] } }
          env['PATH_INFO'] = route
          env['REQUEST_METHOD'] = 'POST'
          env['CONTENT_TYPE'] = 'application/json'
          env['rack.input'] = StringIO.new(params.to_json)
        end

        it 'correct body' do
          _, _, rack_resp = object.response
          expect(rack_resp.body).to eql(expected_body)
        end

        it 'returns correct status' do
          status, = object.response
          expect(status).to eql(success_status)
        end
      end
    end
  end

  describe 'routing error returns' do
    let(:error_status) { 404 }
    let(:route)        { '/not_existed_route' }
    let(:error_body)   { [{ error: "Route `#{route}` not found." }.to_json] }

    before { env['PATH_INFO'] = route }

    it 'correct body' do
      _, _, rack_resp = object.response
      expect(rack_resp.body).to eql(error_body)
    end

    it 'correct status' do
      status, = object.response
      expect(status).to eql(error_status)
    end
  end

  describe 'endpoint internal error returns' do
    let(:error_status) { 500 }
    let(:route)        { '/some_path' }
    let(:error_body)   { [{ error: Rack::Utils::HTTP_STATUS_CODES[error_status] }.to_json] }

    before do
      subject.get(route) { raise StandardError }
      env['PATH_INFO'] = route
      env['REQUEST_METHOD'] = 'GET'
    end

    it 'correct body' do
      _, _, rack_resp = object.response
      expect(rack_resp.body).to eql(error_body)
    end

    it 'correct status' do
      status, = object.response
      expect(status).to eql(error_status)
    end
  end
end
