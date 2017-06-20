class EpubsController < ApplicationController

  include ImagesHelper

  before_action :set_models_variable
  before_action :verify_user
  before_action do
    access_denied if current_user != @article.user
  end

  def show
#   epubデータ（本文、目次）の生成、イメージファイルの配列の生成
    mkepub
#   表紙とCSSデータの生成
#   表紙とCSSはデータがなければサンプルを代用する
    if @article.cover_image == ""
      @cover_image = IO.read(Rails.root.to_s + '/lib/sample.jpg')
    else
      @cover_image = @article.cover_image
    end
    if @article.css == ""
      @css = IO.read(Rails.root.to_s + '/lib/sample.css')
    else
      @css = @article.css
    end
#   epubファイルを置くディレクトリの生成
    tmpdir = Rails.root.to_s + '/tmp/' + "#{@article.user.id}"
#    ディレクトリが無ければ作成
    if ! File.exist?(tmpdir)
      FileUtils.mkdir(tmpdir)
    end
#  配列とeachを使ってプログラムを短縮化
    dirs = ['META-INF', 'OEBPS', 'OEBPS/images', 'OEBPS/css']
    files = [
      ['mimetype', 'application/epub+zip', 'w'],
      ['META-INF/container.xml', @container_data, 'w'],
      ['OEBPS/book.opf', @opf_data, 'w'],
      ['OEBPS/toc.xhtml', @toc_data, 'w'],
      ['OEBPS/images/cover.jpg', @cover_image, 'wb'],
      ['OEBPS/css/text.css', @css, 'w']
    ]
    @xhtml_files.each do |xhtml_data|
      files << ['OEBPS/' + xhtml_data[0], xhtml_data[1], 'w']
    end
#   zip圧縮
#   注意　：　send_fileは非同期に実行されるようなので、zipファイルをすぐに削除することはできない
#            以上から、一時ファイルはそのまま残すことにした。逆に始める時に以前の残りかすがある可能性に注意。
    zip_filename = tmpdir + '/' + "#{@article.title}.epub"
    if File.exist?(zip_filename)
      File.delete(zip_filename)
    end
    Zip.unicode_names = true
    Zip::File.open(zip_filename, Zip::File::CREATE) do |zipfile|
      dirs.each do |dir|
        zipfile.mkdir(dir)
      end
      files.each do |file_array|
        file, data, mode  = file_array
        zipfile.get_output_stream(file) { |f| f.write data }
      end
#  画像の保存
      if ! @image_ids.empty?
        image_directory = 'OEBPS/images'
        @image_ids.uniq!
        @image_ids.each do |image_id|
          image = Image.find(image_id)
          image_name = image.name.gsub(/\A\d*_/,'')
          zipfile.get_output_stream(image_directory + '/' + "b_#{image_name}.jpg") { |f| f.write image.image }
        end
      end
    end
    send_file zip_filename, filename: "#{@article.title}.epub", type: "application/epub+zip"
  end


  private
    def set_models_variable
      @article = Article.find(params[:article_id]) if params[:article_id]
      if ! @article # params[:id]が無かったか、Article.find(params[:id])で見つからなかった場合
        flash[:warning] = t('Article_missing')
        redirect_back(fallback_location: root_path)
      end
    end

=begin rdoc
= CSSのクラスについて
== 本文中のクラス

本文中のsection、noteの見出しはh2, h3タグを用いている。
このクラスを用いて、セクション、ノート見出しのデザインを変更することが出来る。

- h2.section セクション見出し
- h3.note ノート見出し

各セクション、ノートの見出しは、任意のタグのid属性でリンク先を表すようになっている。
（HTML4までは、aタグのname属性を用いていた）。

以上を実際のhtmlにすると、

  <h2 class="section" id="section5">セクション見出しについて</h2>
  <h3 class="note" id="note23">ノート見出しについて</h3>

html目次のsection、noteのリンクはdivタグにクラスを指定している。

- div.section 目次の中のセクションへのリンクを囲む
- div.note 目次の中のノートへのリンクを囲む

以上を実際のhtmlにすると、

  <div class="section"><a href="section5.html#section5">セクション見出しについて</a></div>
  <div class="note"><a href="section5.html#note23">ノート見出しについて</a></div>

=end
    def mkepub
      # initialize RedCarpet
      renderer = Redcarpet::Render::XHTML.new(render_options = {escape_html: true})
      markdown = Redcarpet::Markdown.new(renderer, no_intra_emphasis: true, tables: true, lax_spacing: true, space_after_headers: true)
      # (1)opfファイルのid, href (2)xhtmlファイル (3)目次のリンク の生成
      ids_hrefs = [["booktoc", "booktoc.xhtml"]]
      case @article.language
        when "en" then
          t = "Table of Contents"
        when "ja" then
          t = "目次"
        else
          t = "Table of Contents" # English is default
      end
      html_toc = "<div id=\"title\">#{@article.title}</div>\n" # html目次
      html_toc = "<div id=\"author\">#{@article.author}</div>\n" # html目次
      html_toc = "<h1 id=\"html_toc\">#{t}</h1>\n" # html目次
      toc = "<ol>\n<li><a href=\"booktoc.xhtml#html_toc\">#{t}</a></li>\n" # 論理目次
      @xhtml_files = []
      @image_ids = [] #   イメージファイルの配列
      @article.ordered_sections.each do |section|
        #opf
        ids_hrefs << ["book#{section.id}", "book#{section.id}.xhtml"]
        # table of contents
        html_toc << "<div class=\"section\"><a href=\"book#{section.id}.xhtml#section#{section.id}\">#{section.heading}</a></div>\n"
        toc << "<li><a href=\"book#{section.id}.xhtml#section#{section.id}\">#{section.heading}</a></li>\n"
        toc << "<ul>\n"
        # body
        xhtml_data = mkheader section.heading
        xhtml_data << "<h2 class=\"section\" id=\"section#{section.id}\">#{section.heading}</h2>\n"
        section.ordered_notes.each do |note|
          # table of contents
          html_toc << "<div class=\"note\"><a href=\"book#{section.id}.xhtml#note#{note.id}\">#{note.title}</a></div>\n"
          toc << "<li><a href=\"book#{section.id}.xhtml#note#{note.id}\">#{note.title}</a></li>\n"
          # body
          xhtml_data << "<h3 class=\"note\" id=\"note#{note.id}\">#{note.title}</h3>\n"
          text, image_ids = evaluate_for_epub(parse(markdown.render(note.text)))
          xhtml_data << text
          # image
          @image_ids.concat image_ids
        end
        # table of contents
        toc << "</ul>\n"
        # body
        xhtml_data << "</body>\n</html>\n"
        @xhtml_files << ["book#{section.id}.xhtml", xhtml_data]
      end
      # table of contents
      toc << "</ol>\n"
      # html目次を@xhtml_filesの先頭へ
      xhtml_data = mkheader "Table of Contents"
      xhtml_data << html_toc
      xhtml_data << "</body>\n</html>\n"
      @xhtml_files.insert 0, ["booktoc.xhtml", xhtml_data]

      # container.xml data
      @container_data = <<EOS
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<container xmlns=\"urn:oasis:names:tc:opendocument:xmlns:container\" version=\"1.0\">
  <rootfiles>
    <rootfile full-path=\"OEBPS/book.opf\" media-type=\"application/oebps-package+xml\"/>
  </rootfiles>
</container>
EOS

      # opf file data
      @opf_data = <<EOS
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<package xmlns=\"http://www.idpf.org/2007/opf\" unique-identifier=\"pub-id\" xml:lang=\"#{@article.language}\" version=\"3.0\">
  <metadata xmlns:dc=\"http://purl.org/dc/elements/1.1/\">
    <dc:identifier id=\"pub-id\">#{@article.identifier_uuid}</dc:identifier>
    <dc:title xml:lang=\"ja\">#{@article.title}</dc:title>
    <dc:language>#{@article.language}</dc:language>
    <meta property=\"dcterms:modified\">#{@article.modified_datetime}</meta>
    <dc:creator id=\"creator\">#{@article.author}</dc:creator>
    <meta refines=\"#creator\" property=\"role\" scheme=\"marc:relators\">aut</meta>
  </metadata>
  <manifest>
    <item id=\"cimage\" media-type=\"image/jpeg\" href=\"images/cover.jpg\" properties=\"cover-image\"/>
    <item id=\"toc\" properties=\"nav\" href=\"toc.xhtml\" media-type=\"application/xhtml+xml\"/>
EOS
      ids_hrefs.each do |id_href|
        @opf_data << "    <item id=\"#{id_href[0]}\" href=\"#{id_href[1]}\" media-type=\"application/xhtml+xml\"/>\n"
      end
      @opf_data << <<EOS
  </manifest>
  <spine>
EOS
      ids_hrefs.each do |id_href|
        @opf_data << "    <itemref idref=\"#{id_href[0]}\"/>\n"
      end
      @opf_data << <<EOS
  </spine>
</package>
EOS

      # toc file data
      @toc_data = <<EOS
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE html>
<html xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:epub=\"http://www.idpf.org/2007/ops\" lang=\"#{@article.language}\" xml:lang=\"#{@article.language}\">
<head>
<title>Table of Contents</title>
</head>
<body>
<nav epub:type=\"toc\">
#{toc}
</nav>
</body>
</html>
EOS

    end

    def mkheader title
      return <<EOS
<?xml version=\"1.0\" encoding=\"utf-8\"?>
<!DOCTYPE html>
<html xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:xml=\"http://www.w3.org/XML/1998/namespace\" xml:lang=\"#{@article.language}\" lang=\"#{@article.language}\">
<head>
<link rel=\"stylesheet\" type=\"text/css\" href=\"./css/text.css\"/>
<title>#{title}</title>
</head>
<body>
EOS
    end

end
