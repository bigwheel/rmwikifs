#!/usr/bin/env ruby

require 'rubygems'
require 'fusefs'
require 'json'
require 'httpclient'
require 'uri'

require 'pry'

require_relative 'rm_wiki_renamer'

class RMWikiFS < FuseFS::FuseDir
  def initialize redmine_wiki_root, username, password
    @redmine_wiki_root = redmine_wiki_root
    @http_client = HTTPClient.new
    @renamer = RMWikiRenamer.new @http_client, @redmine_wiki_root,
      username, password
  end

  def directory? path
    not file?(path)
  end

  def file? path
    path =~ /.*\.json\Z/
  end

  #def can_delete?; true end

  #def can_write? path; file? path end

  def contents path
    def select_child_pages wiki_pages, parent_name
      wiki_pages.select { |page|
        page.has_key?('parent') && page['parent']['title'] == parent_name
      }
    end
    # TODO: このFile.joinの使い方は正しくないが面倒なので一旦これで行く
    response = @http_client.get(File.join(@redmine_wiki_root, 'index.json'))
    if response.status == 200
      json = JSON.parse(response.content)
      child_pages = if path == '/'
                      json['wiki_pages'].reject { |page| page.has_key? 'parent' }
                    else
                      select_child_pages json['wiki_pages'], File::basename(path)
                    end
      child_pages.map { |page| page['title'] }.
        map { |title|
        if select_child_pages(json['wiki_pages'], title).empty?
          [ title + '.json' ]
        else
          [ title, title + '.json' ]
        end
      }.flatten
    else
      []
    end
  end

  # def size(path) TODO: headerでアクセスして長さだけ取ってくればいいんじゃないかな
  # def times(path) TODO: index.jsonの方で取れる最終更新日と作成日は両方使えそう

  #def write_to path, body
  #  obj = YAML::load( body )
  #  obj.save
  #end

  def read_file path
    # TODO: 本当はURIエスケープも使うべきじゃないんだけど・・・
    # こうしてみるとRubyもbad parts増えてきたなあ
    page_name = File::basename(path)
    response = @http_client.get(File.join(@redmine_wiki_root, URI::escape(page_name)))
    if response.status == 200
      json = JSON.parse(response.content)
      a = JSON.pretty_generate(json)
      a # TODO: なぜかファイルで開くと末尾の数文字〜数行が
      # 出ないファイルがある。サイズが大きいの？謎
    else
      ''
    end
  end
end

