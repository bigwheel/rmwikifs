#!/usr/bin/env ruby

require 'rubygems'
require 'fusefs'
require 'open-uri'
require 'json'

require 'pry'

class RedMineFS < FuseFS::FuseDir
  def initialize(redmine_wiki_root)
    @redmine_wiki_root = redmine_wiki_root
  end

  def directory? path
    path == '/'
  end

  #def file? path
  #  not directory?(path)
  #end

  #def can_delete?; true end

  #def can_write? path; file? path end

  def contents path
    # このFile.joinの使い方は正しくないが面倒なので一旦これで行く
    json = JSON.parse(open(File.join(@redmine_wiki_root, 'index.json')).read)
    json['wiki_pages'].map { |page| page['title'] }
  end

  #def write_to path, body
  #  obj = YAML::load( body )
  #  obj.save
  #end

  def read_file path
    'Hello, World!'
  end
end

