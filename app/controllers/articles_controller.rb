class ArticlesController < ApplicationController
  before_action :login_check_and_set_user, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_article, only: [:show, :edit, :update, :destroy, :kindle]
  before_action only: [:edit, :update] do
    if @article.w_public == 0
      check_correct_user
    end
  end
  before_action :check_correct_user, only: [:destroy, :kindle]

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

  def kindle
#gzipの場合
    data = ActiveSupport::Gzip.compress(mkkindle)
    send_data data, filename: "wnote#{@article.id}.gz", type: "application/gzip"
#zipの場合
#    require 'zip'
#    temp_filename = Rails.root.to_s+"/tmp/tempfile.html"
#    IO.write(temp_filename, mkkindle)
#    zip_filename = Rails.root.to_s+"/tmp/wnote#{@article.id}.zip"
#    if File.exist?(zip_filename)
#      File.delete(zip_filename)
#    end
#    Zip::File.open(zip_filename,Zip::File::CREATE) do |zipfile|
#      zipfile.add("wnote#{@article.id}.html", temp_filename)
#    end
#    File.delete(temp_filename)
#    send_file zip_filename, filename: "wnote#{@article.id}.zip", type: "application/zip"
#ストリームの送信（ユーザから見ればダウンロード）は非同期に（並行して）行われるのでzipファイルを削除してはいけない
  end

  private
    def login_check_and_set_user
      if (@user = current_user) == nil
        flash[:error] = "You don't have access to this section."
        redirect_to :back
      end
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def article_params
      params.require(:article).permit(:title, :author, :date, :section_order, :r_public, :w_public)
    end
    def check_correct_user
      if (@user = current_user) != @article.user
        flash[:warning] = "Only article's owner is allowed to access to this section."
        redirect_to :back
      end
    end
    def mkkindle
      renderer = Redcarpet::Render::HTML.new(render_options = {escape_html: true})
      markdown = Redcarpet::Markdown.new(renderer, no_intra_emphasis: true, tables: true, lax_spacing: true, space_after_headers: true)
      html_data = "<html>\n"
      html_data << "<head>\n"
      html_data << "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">\n"
      html_data << "<style type=\"text/css\">\n"
      html_data << "h1 {page-break-before:always;}\n"
      html_data << "h2 {page-break-before:always;}\n"
      html_data << "</style>\n"
      html_data << "</head>\n"
      html_data << "<body>\n"
      html_data << "<h1>#{@article.title}</h1>\n"
      html_data << "<h1>目次</h1>\n"
      @article.ordered_sections.each do |section|
        html_data << "<a href=\"#section#{section.id}\"><h3>#{section.heading}</h3></a>\n"
        html_data << "<ul>\n"
        section.ordered_notes.each do |note|
          html_data << "<li><a href=\"#note#{note.id}\">#{note.title}</a></li>\n"
        end
        html_data << "</ul>\n"
      end
      @article.ordered_sections.each do |section|
        html_data << "<a name=\"section#{section.id}\"><h2>#{section.heading}</h2></a>\n"
        section.ordered_notes.each do |note|
          html_data << "<a name=\"note#{note.id}\"><h3>#{note.title}</h3></a>\n"
          html_data << markdown.render(note.text).html_safe
        end
      end
      html_data << "</body>\n"
    end
end
