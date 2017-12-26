# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

shared_examples 'response with correct Content-Type' do
  let(:header) { { name: 'Content-Type', value: 'application/json' } }
  it { expect(response.header[header[:name]]).to eql(header[:value]) }
end

shared_examples 'response with correct status' do |status|
  it { expect(response.status).to eql(status) }
end

describe 'MyEndpoint' do
  describe 'GET `/` with URL params' do
    let(:expected) { { results: { foo: 'bar' } } }

    before { get '/?foo=bar' }

    it_behaves_like 'response with correct Content-Type'
    it_behaves_like 'response with correct status', 200
    it { expect(json_body).to eql(expected) }
  end

  describe 'GET `/bla`' do
    let(:expected) { { results: [1, 2, 3] } }

    before { get '/bla' }

    it_behaves_like 'response with correct Content-Type'
    it_behaves_like 'response with correct status', 200
    it { expect(json_body).to eql(expected) }
  end

  describe 'POST `/bla`' do
    let(:params) { { name: 'Awesome User' } }

    describe 'without correct Content-Type header' do
      let(:expected) { { error: 'Unsupported Media Type' } }

      before { post '/bla', params.to_json }

      it_behaves_like 'response with correct Content-Type'
      it_behaves_like 'response with correct status', 415
      it { expect(json_body).to eql(expected) }
    end

    describe 'with correct Content-Type header' do
      let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }
      let(:expected) { { name: params[:name] } }

      before { post '/bla', params.to_json, headers }

      it_behaves_like 'response with correct Content-Type'
      it_behaves_like 'response with correct status', 200
      it { expect(json_body).to eql(expected) }
    end
  end

  describe 'visit not existed route' do
    let(:route) { '/not_existed_route' }
    let(:expected) { { error: "Route `#{route}` not found." } }

    describe 'GET' do
      before { get route }

      it_behaves_like 'response with correct Content-Type'
      it_behaves_like 'response with correct status', 404
      it { expect(json_body).to eql(expected) }
    end

    describe 'POST' do
      before { post route }

      it_behaves_like 'response with correct Content-Type'
      it_behaves_like 'response with correct status', 404
      it { expect(json_body).to eql(expected) }
    end
  end
end
