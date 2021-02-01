#!/bin/bash

bundle exec ruby -e "Dir.glob('test/*_test.rb').each { |f| require File.expand_path(f) }"

# for f in ./test/*.rb; do
#   bundle exec ruby $f
# done