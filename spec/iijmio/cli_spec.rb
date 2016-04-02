# -*- coding: utf-8 -*-
require "spec_helper"

describe ::Iijmio::CLI do
  it %{has a version number} do
    expect(::Iijmio::CLI::VERSION).not_to be nil
  end
end
