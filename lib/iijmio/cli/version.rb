# -*- coding: utf-8 -*-
require "capybara"
require "capybara/poltergeist"
require "faraday"
require "json"
require "phantomjs"
require "securerandom"
require "webrick"
require "yaml"

module ::Iijmio
  module CLI
    VERSION = %{0.0.1}
  end
end
