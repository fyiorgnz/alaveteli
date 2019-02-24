#!/usr/bin/env ruby

require 'erb'
require 'yaml'

["general.yml", "database.yml"].each { |f|
  c = YAML.load(ERB.new(File.read("config/" + f + ".erb")).result)
  File.write("config/" + f, YAML.dump(c))
}
