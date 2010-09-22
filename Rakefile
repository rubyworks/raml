#!/usr/bin/env ruby

desc "build treetop parser"
task :treetop do
  Dir.chdir "lib/raml" do
    sh "tt -o parser.rb treetop/raml.treetop"
  end
end

