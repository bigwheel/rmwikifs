#!/usr/bin/env ruby

require 'rubygems'
require 'fusefs'
require 'json'
require 'uri'

require 'pry'

require 'rmwiki'

class RMWikiFS < FuseFS::FuseDir
  def initialize wiki_root, username, password
    @rmwiki = Rmwiki.new(wiki_root, username, password)
    @tree = @rmwiki.tree
  end

  def directory? path
    not file?(path)
  end

  def json? path
    path =~ /.*\.json\Z/
  end

  def file? path
    json? path
  end

#  def rename from_path, to_path
#    if file?(from_path) && file?(to_path) &&
#      File::dirname(from_path) == File::dirname(to_path)
#      @renamer.rename File::basename(from_path, '.json'),
#        File::basename(to_path, '.json')
#      true
#    else
#      false
#    end
#  end

  #def can_delete?; true end

  #def can_write? path; file? path end

  def contents path
    if path == '/'
      res = @tree.map { |_, page|
        if page.children.empty?
          [page.title + '.json']
        else
          [page.title + '.json', page.title]
        end
      }.flatten
      p res
      res
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

  # とりあえずページ内部だけ出す
  def read_file path
    @rmwiki.page(File::basename(path, '.json')).text
  end
end

