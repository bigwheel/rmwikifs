#!/usr/bin/env ruby

require 'rubygems'
require 'fusefs'

require_relative 'rm_wiki_fs'

def directory_check
  unless File.directory? ARGV[0]
    puts "#{ARGV[0]} is not a directory"
    exit false
  end
end

def argument_validation
  if ARGV.length == 4
    directory_check ARGV[0]
    ARGV
  elsif ARGV.length == 3
    directory_check ARGV[0]
    require 'io/console'
    print 'password:'
    password = STDIN.noecho(&:gets).chomp
    ARGV[0..2] + [password]
  else
    puts("Usage: #{$0} {{directory}} {{redmine_root}} " +
         "{{rm_username}}")
    exit false
  end
end

if File.basename($0) == File.basename(__FILE__)
  (mount_point, redmine_wiki_root, username, password) = argument_validation
  # redmine_wiki_rootはこんな感じ
  # http://www.redmine.org/projects/redmine/wiki/

  root = RMWikiFS.new redmine_wiki_root, username, password

  FuseFS.set_root(root)
  FuseFS.mount_under(mount_point)
  FuseFS.run # This doesn't return until we're unmounted.
end
