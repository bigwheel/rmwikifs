#!/usr/bin/env ruby

require 'rubygems'
require 'fusefs'
require 'json'
require 'httpclient'
require 'uri'

require 'pry'

class RedMineFS < FuseFS::FuseDir
  def initialize(redmine_wiki_root)
    @redmine_wiki_root = redmine_wiki_root

    @http_client = HTTPClient.new

    @counter = 0
  end

  def directory? path
    path == '/'
  end

  def file? path
    #not directory?(path)
    path != '/'
  end

  #def can_delete?; true end

  #def can_write? path; file? path end

  def contents path
    # このFile.joinの使い方は正しくないが面倒なので一旦これで行く
    response = @http_client.get(File.join(@redmine_wiki_root, 'index.json'))
    if response.status == 200
      json = JSON.parse(response.content)
      json['wiki_pages'].map { |page| page['title'] }
    else
      []
    end
  end

  #def write_to path, body
  #  obj = YAML::load( body )
  #  obj.save
  #end

  def read_file path
    # 本当はURIエスケープも使うべきじゃないんだけど・・・
    # こうしてみるとRubyもbad parts増えてきたなあ
    response = @http_client.get(File.join(@redmine_wiki_root, URI::escape(path) + '.json'))
    if response.status == 200
      json = JSON.parse(response.content)
      JSON.pretty_generate(json)
    else
      ''
    end
  end
end

