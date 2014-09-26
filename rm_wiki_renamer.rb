require 'nokogiri'
require 'httpclient'
require 'uri'

class RMWikiRenamer
  def initialize http_client, wiki_base_url, username, password
    @http_client = http_client
    @wiki_base_url = wiki_base_url

    login username, password
  end

  def rename before_name, after_name
    rename_form_url = File.join(@wiki_base_url, before_name, '/rename')
    doc = Nokogiri::HTML(@http_client.get_content(rename_form_url))
    authenticity_token = get_authenticity_token(doc)

    # 今はディレクトリ移動を実装してないのでとりあえず使ってない
    # page_name_id_map = get_page_name_id_map doc

    res = @http_client.post(rename_form_url, {
      authenticity_token: authenticity_token,
      'wiki_page[title]' => after_name,
      'wiki_page[redirect_existing_links]' => 0,
      'wiki_page[parent_id]' => get_default_parent_id(doc)
    })
    check_status_code res
  end

  private
  def get_authenticity_token nokogiri_doc
    nokogiri_doc.css('input[name="authenticity_token"]').first.attributes['value'].value
  end

  def check_status_code res
    unless res.header.status_code == 302
      raise 'まずいですよ' + res.to_s
    end
  end

  def login username, password
    def fetch_login_url
      url = URI.parse(@wiki_base_url)
      doc = Nokogiri::HTML(@http_client.get_content(@wiki_base_url))
      url.path = doc.css('.login').first.attributes['href'].value
      url.to_s
    end

    login_url = fetch_login_url

    authenticity_token = get_authenticity_token(Nokogiri::HTML(@http_client.get_content(login_url)))
    # redmineは認証失敗したら200,成功したら302が帰る。ks
    check_status_code(@http_client.post(login_url, {
      authenticity_token: authenticity_token,
      username: username,
      password: password
    }))
  end

  def get_page_name_id_map nokogiri_doc
    page_id_and_anme = nokogiri_doc.css('#wiki_page_parent_id option').
      map { |i| i.text =~ /» (.*)/; [$1, i.attributes['value'].value.to_i] }.
      select { |page_name, id| page_name }
    Hash[page_id_and_anme]
  end

  def get_default_parent_id nokogiri_doc
    nokogiri_doc.css('#wiki_page_parent_id option[selected="selected"]').first.attributes['value'].value.to_i
  end
end

if $0 == __FILE__
  r = RMWikiRenamer.new(HTTPClient.new, ARGV.shift, 'bigwheel', '4CrY39Ellb07')

  #r.rename 'B', 'A'
  r.rename 'A', 'B'
end
