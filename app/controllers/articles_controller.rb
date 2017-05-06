require 'securerandom'
require 'rmagick'
require 'base64'

class ArticlesController < ApplicationController
  before_action :login_check_and_set_user, only: [:new, :create, :edit, :update, :destroy, :epub]
  before_action :set_article, only: [:show, :edit, :update, :destroy, :epub]
  before_action only: [:edit, :update] do
    if @article.w_public == 0
      check_correct_user
    end
  end
  before_action :check_correct_user, only: [:destroy, :epub]

  def index
    @articles = Article.all
    articles = []
    @articles.each do |article|
      if article.r_public > 0 || (login? && article.user == current_user)
        articles << article
      end
    end
    @articles = articles
  end

  def show
    if @article.r_public == 0
      check_correct_user
    end
  end

  def new
    @article = Article.new
  end

  def edit
  end

  def create
    @article = Article.new(article_params)
    @article.user_id = @user.id
    if @article.save
      redirect_to @article, flash: { success: 'Article was successfully created.'}
    else
      render :new
    end
  end

  def update
    if @article.update(article_params)
      redirect_to @article, flash: { success: 'Article was successfully updated.' }
    else
      render :edit
    end
  end

  def destroy
    @article.destroy
    redirect_to articles_url, flash: { success: 'Article was successfully destroyed.' }
  end

  def epub
#   epubデータの生成
    mkepub
#   epubのディレクトリの生成
    tmpdir = Rails.root.to_s + '/tmp/' + "#{@article.user.id}"
    if not File.exist?(tmpdir)
      FileUtils.mkdir(tmpdir)
    end
    directories = ['META-INF', 'OEBPS', 'OEBPS/images', 'OEBPS/css'].map{|d| tmpdir + '/' + d}
    directories.each do |d|
      if not File.exist?(d)
        FileUtils.mkdir(d)
      end
    end
#   ファイルの生成
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
#  配列とeachを使ってプログラムを短縮化
    files = [
      [tmpdir + '/' + 'mimetype', 'application/epub+zip', 'w'],
      [tmpdir + '/' + 'META-INF/container.xml', @container_data, 'w'],
      [tmpdir + '/' + 'OEBPS/book.opf', @opf_data, 'w'],
      [tmpdir + '/' + 'OEBPS/toc.xhtml', @toc_data, 'w'],
      [tmpdir + '/' + 'OEBPS/book.xhtml', @xhtml_data, 'w'],
      [tmpdir + '/' + 'OEBPS/images/cover.jpg', @cover_image, 'wb'],
      [tmpdir + '/' + 'OEBPS/css/text.css', @css, 'w']
    ]
    files.each do |file|
      File.open(file[0], file[2]) do |f|
        f.write(file[1])
      end
    end
#   zip圧縮
#   注意　：　zipファイルの生成は非同期に行われているようなのでzipfile.addの直後（一定時間）に元ファイルやディレクトリを削除すると上手く動かなくなる
#           send_fileも非同期に実行されるようなので、zipファイルをすぐに削除することはできない
#            以上から、一時ファイルはそのまま残すことにした。逆に始める時に以前の残りかすがある可能性に注意。
    zip_filename = tmpdir + '/' + "#{@article.title}.epub"
    if File.exist?(zip_filename)
      File.delete(zip_filename)
    end
    input_filenames = ['mimetype', 'META-INF/container.xml',
                       "OEBPS/book.opf", "OEBPS/toc.xhtml", "OEBPS/book.xhtml", 'OEBPS/images/cover.jpg', 'OEBPS/css/text.css']
    Zip.unicode_names = true
    Zip::File.open(zip_filename, Zip::File::CREATE) do |zipfile|
      input_filenames.each do |filename|
        zipfile.add(filename, tmpdir + '/' + filename)
      end
    end
    send_file zip_filename, filename: "#{@article.title}.epub", type: "application/epub+zip"
  end
1
  private
    def login_check_and_set_user
      if (@user = current_user) == nil
        flash[:error] = "You don't have access to this section."
        redirect_to root_path
      end
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params[:id])
    end
    def check_correct_user
      if (@user = current_user) != @article.user
        flash[:warning] = "Only article's owner is allowed to access to this section."
        redirect_to root_path
      end
    end
    # Strong parameter, only allow the white list through.
    # Auto generate uuid
    # If jpeg file is uploaded, add {:cover_image => file_data} to parameter
    # and make thumbnail
    def article_params
      ap = params.require(:article).permit(:title, :author, :language, :modified_datetime, :identifier_uuid,\
                                           :css, :r_public, :w_public, :section_order)
      if ap[:identifier_uuid] == ''
        ap[:identifier_uuid] = SecureRandom.uuid
      end
      uploaded_io = params[:article][:cover_image]
      if uploaded_io
        ap[:cover_image] = uploaded_io.read
        img = Magick::Image.from_blob(ap[:cover_image]).first
        ap[:icon_base64] = img.thumbnail(32,32).to_blob
      end
      return ap
    end

    def mkepub
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
    <item id=\"book\" href=\"book.xhtml\" media-type=\"application/xhtml+xml\"/>
  </manifest>
  <spine>
    <itemref idref=\"book\"/>
  </spine>
</package>
EOS
      # toc file data
      @toc_data = <<EOS
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE html>
<html xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:epub=\"http://www.idpf.org/2007/ops\" lang=\"#{@article.language}\" xml:lang=\"#{@article.language}\">
<head>
</head>
<body>
<nav epub:type=\"toc\">
<ol>
EOS
      @article.ordered_sections.each do |section|
        @toc_data << "<li><a href=\"book.xhtml#section#{section.id}\">#{section.heading}</a></li>\n"
        @toc_data << "<ol>\n"
        section.ordered_notes.each do |note|
          @toc_data << "<li><a href=\"book.xhtml#note#{note.id}\">#{note.title}</a></li>\n"
        end
        @toc_data << "</ol>\n"
      end
      @toc_data << "</ol>\n</nav>\n</body>\n</html>\n"
      # xhtml content data
      renderer = Redcarpet::Render::HTML.new(render_options = {escape_html: true})
      markdown = Redcarpet::Markdown.new(renderer, no_intra_emphasis: true, tables: true, lax_spacing: true, space_after_headers: true)
      @xhtml_data = <<EOS
<?xml version=\"1.0\" encoding=\"utf-8\"?>
<!DOCTYPE html>
<html xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:xml=\"http://www.w3.org/XML/1998/namespace\" xml:lang=\"#{@article.language}\" lang=\"#{@article.language}\">
<head>
<link rel=\"stylesheet\" type=\"text/css\" href=\"./css/text.css\"/>
</head>
<body>
<h1>#{@article.title}</h1>
<h1>目次</h1>
EOS
      @article.ordered_sections.each do |section|
        @xhtml_data << "<a href=\"#section#{section.id}\"><h3>#{section.heading}</h3></a>\n"
        @xhtml_data << "<ul>\n"
        section.ordered_notes.each do |note|
          @xhtml_data << "<li><a href=\"#note#{note.id}\">#{note.title}</a></li>\n"
        end
        @xhtml_data << "</ul>\n"
      end
      @article.ordered_sections.each do |section|
        @xhtml_data << "<a name=\"section#{section.id}\"><h2>#{section.heading}</h2></a>\n"
        section.ordered_notes.each do |note|
          @xhtml_data << "<a name=\"note#{note.id}\"><h3>#{note.title}</h3></a>\n"
          @xhtml_data << markdown.render(note.text).html_safe
        end
      end
      @xhtml_data << "</body>\n</html>\n"
    end
end
