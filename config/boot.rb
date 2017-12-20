# frozen_string_literal: true

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

# Allows to require any file from lib directory as regular gem.
$LOAD_PATH.unshift('lib')

# Set up gems listed in the Gemfile and require they.
require 'bundler/setup'
require 'json'

Bundler.require(:default, :development)
