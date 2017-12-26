## Simple Ruby Framework

### Description
A small Ruby web framework for writing simple JSON APIs.

See the task requirements [here](https://github.com/antnruban/simple-ruby-json-framework/blob/master/Trial-Day.-Backend.-Web-framework.md).

### Installation
* Clone repository.
* `cd` to *cloned directory* and run `bundle install`.

### Usage
* To build own endpoint you need to inherit `Framework::Endpoint` class and provide endpoints logic. See example:

```ruby
# my_endpoint.rb

require 'framework'

class MyEndpoint < Framework::Endpoint
  get '/bla' do
    { results: [1, 2, 3] }
  end

  post '/bla' do |params|
    { name: params[:name] }
  end
end

```

* You can easy provide headers if it's necessary. See example bellow.

```ruby
# ...
class MyEndpoint < Framework::Endpoint
  headers 'Content-Type'  => 'application/json',
        'Custom-Header' => '*'

# ...
```
* Inherit `Framework::Application` class provides simple application for mounting your endpoints.

```ruby
# my_application.rb

class MyApplication < Framework::Application
  mount MyEndpoint
end
```
than `MyApplication` class can be used in `config.ru` file

```ruby
# config.ru
require 'config/my_application.rb'

run MyApplication
```

### Run Examples

Ones repository pulled and bundled, you can run [endpoint](https://github.com/antnruban/simple-ruby-framework/blob/master/app/my_endpoint.rb) example.

To do that, navigate to *cloned directory* and run `rackup -port=0000`, where `0000` - specific port, or run on default (3000) port via `rackup` command.

You might run server in `test` environment via `RACK_ENV=test rackup` command.

### Testing

* #### linter
Run `Rubocop` linter by `rubocop` command.

* #### specs
Run `Rspec` tests by `bundle exec rspec spec` or just `rspec` command.
