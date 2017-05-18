require 'securerandom'
require 'rmagick'
require 'base64'

class ArticlesController < ApplicationController

  include ImagesHelper

  before_action :set_models_variable, except: :index
  before_action :verify_correct_user, only: [:new, :create, :destroy, :epub]
  before_action only: [:edit, :update] do
    verify_correct_user if @article.w_public == 0
  end
  before_action only: :show do
    verify_correct_user if @article.r_public == 0
  end

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

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)
    @article.user_id = @user.id
    if @article.save
      redirect_to @article, flash: { success: I18n.t('x_created', x: I18n.t('Article'))}
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @article.update(article_params)
      redirect_to @article, flash: { success: I18n.t('x_updated', x: I18n.t('Article')) }
    else
      render :edit
    end
  end

  def show
  end

  def destroy
    @article.destroy
    redirect_to articles_url, flash: { success: I18n.t('x_destroyed', x: I18n.t('Article')) }
  end

  def epub
#   イメージファイルの配列
    @image_ids = []
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
      ['OEBPS/book.xhtml', @xhtml_data, 'w'],
      ['OEBPS/images/cover.jpg', @cover_image, 'wb'],
      ['OEBPS/css/text.css', @css, 'w']
    ]
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
      if params[:id] # edit, update, show, destroy, epub
        @article = Article.find(params[:id])
        @user = @article.user
      else # new, create
        @user = current_user
      end
      if ! @user
        flash[:warning] = "The article couldn't read from the database or no logged in user."
        redirect_back(fallback_location: root_path)
      end
    end
    # Strong parameter, only allow the white list through.
    # Auto generate uuid
    # If jpeg file is uploaded, add {:cover_image => file_data} to parameter
    # and make thumbnail
    def article_params
      ap = params.require(:article).permit(:title, :author, :language, :modified_datetime, :identifier_uuid,\
                                           :cover_image, :css, :r_public, :w_public, :section_order)
      if ap[:identifier_uuid] == ''
        ap[:identifier_uuid] = SecureRandom.uuid
      end
      uploaded_io = params[:article][:cover_image]
      if uploaded_io
        ap[:cover_image] = uploaded_io.read
        img = Magick::ImageList.new.from_blob(ap[:cover_image]).first
        ap[:icon_base64] = Base64.encode64(img.thumbnail(32,32).to_blob)
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
# html5 ではname属性が廃止され、id属性を使うことになった
        @xhtml_data << "<a id=\"section#{section.id}\"><h2>#{section.heading}</h2></a>\n"
        section.ordered_notes.each do |note|
          @xhtml_data << "<a id=\"note#{note.id}\"><h3>#{note.title}</h3></a>\n"
          text, image_ids = evaluate_for_epub(parse(markdown.render(note.text)))
          @xhtml_data << text
          @image_ids.concat image_ids
        end
      end
      @xhtml_data << "</body>\n</html>\n"
    end
end
