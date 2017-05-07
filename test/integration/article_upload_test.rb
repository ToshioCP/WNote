require 'test_helper'

class ArticleUploadTest < ActionDispatch::IntegrationTest
  test "article update" do
    @article = Article.find_by(title: 'WNote_Howto')

    post "/logins/create", params: {email: 'lxboyjp@gmail.com', password: 'aabbccddeeffgg'}
# ログインは成功するはずなので、リダイレクト
    assert_response :redirect
    follow_redirect!
    assert_response :success

# newの部分はコメントアウトしてもテストは通過した
#    get "/articles/#{@article.id}/edit"
#    assert_response :success

    put "/articles/#{@article.id}", params: {article: {
      title: @article.title,
      author: @article.author,
      r_public: @article.r_public,
      w_public: @article.w_public,
      language: @article.language,
      modified_datetime: @article.modified_datetime,
      identifier_uuid: @article.identifier_uuid,
      cover_image: fixture_file_upload("lib/sample.jpg", 'image/jpeg', true),
      css: '@charset \"utf-8\";'+"\n"+'@namespace \"http://www.w3.org/1999/xhtml\";'+"\n"+'h1 {page-break-before:always;}' \
           +"\n"+'h2 {page-break-before:always;}'
    } }
    assert_response :redirect
    follow_redirect!
    assert_response :success

# データベースに保存されたものを読み込み、画像データをチェック
# バイナリで読み込む時に、IOの外部エンコーディング、内部エンコーディングをASCII-8BITにすること
# 読み込みモードで、改行をそのままにする場合は'rb'とする
    @article = Article.find(@article.id)
    File.open('lib/sample.jpg', 'rb', encoding: 'ASCII-8BIT:ASCII-8BIT') do |f|
      @sample = f.read(nil)
    end
    assert_equal @sample, @article.cover_image
  end
end
