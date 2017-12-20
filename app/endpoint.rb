# frozen_string_literal:true

require 'framework'

class Endpoint < Framework
  headers 'Content-Type'  => 'application/json',
          'Custom-Header' => '*'

  get '/bla' do
    { results: [1, 2, 3] }
  end

  get '/' do |params|
    { results: params }
  end

  post '/bla' do |params|
    { name: params[:name] }
  end
end
