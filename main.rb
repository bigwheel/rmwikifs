#!/usr/bin/env ruby

require 'rubygems'
require 'fusefs'

require_relative 'redmine_fs'

def argument_validation
  if ARGV.length != 2
    puts "Usage: #{$0} {{directory}} {{redmine_root}}"
    exit false
  end

  unless File.directory? ARGV[0]
    puts "#{ARGV[0]} is not a directory"
    exit false
  end

  ARGV
end

if File.basename($0) == File.basename(__FILE__)
  (mount_point, redmine_wiki_root) = argument_validation
  # redmine_wiki_rootはこんな感じ
  # http://www.redmine.org/projects/redmine/wiki/

  root = RMWikiFS.new redmine_wiki_root

  FuseFS.set_root(root)
  FuseFS.mount_under(mount_point)
  FuseFS.run # This doesn't return until we're unmounted.
end
