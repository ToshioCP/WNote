require 'test_helper'

class ArticlesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @article = articles(:wnote)
    @user = users(:toshiocp)
# Some situations make the redirection to :back.
# For example GUEST can't access some action and it make the redirection to :back.
# Testing such redirection needs HTTP_REFERER.
#    @request.headers["HTTP_REFERER"] = root_url
  end

  test "should get index" do
    get articles_path
    assert_response :success
    assert_select 'h2', 'Listing Articles'
# The article(r_public=0) is in the list when its owner accesses the page.
    articles(:wnote).update(r_public: 0)
    login
    get articles_path
    assert_response :success
    assert_select 'td'
    assert_select 'td'
    assert_select 'td', 'WNote_Howto'
  end

  test "logged in user should get new" do
    login
    get new_article_path
    assert_response :success
    assert_select 'div.wnote-main' do
      assert_select 'form.new_article' do
        assert_select "input.form-control[name=?]", 'article[title]'
        assert_select "input.form-control[name=?]", 'article[author]'
#        and so on ....
        assert_select "input[class='btn btn-primary']"
      end
    end
  end

  test "guest shouldn't get new" do
    get new_article_path
    assert_redirected_to root_path
  end

  test "logged in user should create article" do
    login
    parameter = article_params('New Title', 'New Author', '0', '0', 'en', '2017-04-20 00:00:00 UTC', '50a7f095-6a62-4a39-966b-dcef11ebf810')
    assert_difference('Article.count') do
      post '/articles', params: {article: parameter}
    end
    article = Article.last
    assert_redirected_to article_path(article)
    assert_equal 'Article was successfully created.', flash[:success]
    assert_equal article.user, @user, "Created article does not belong to the creating user." 
  end

  test "guest shouldn't get create" do
    parameter = article_params('New Title', 'New Author', '0', '0', 'en', '2017-04-20 00:00:00 UTC', '50a7f095-6a62-4a39-966b-dcef11ebf810')
    assert_no_difference('Article.count') do
      post '/articles', params: {article: parameter}
    end
  end

  test "logged in user should show article" do
    login
    get article_path(@article)
    assert_response :success
    assert_select 'nav' do
#      assert_select 'a.navbar-brand', 'WNote'
      assert_select 'a', {text: 'List Articles', html: articles_path}
      assert_select 'a', 'New Article'
      assert_select 'a', 'Edit Article'
      assert_select 'a', 'Destroy Article'
      assert_select 'a', 'New Section'
    end
    assert_select 'div.wnote-main' do
      assert_select 'td', 'Instalation'
    end
  end

  test "Only the owner can read section when r_public is off" do
# Guest
    @article.update(r_public: 0) # off
    get article_path(@article)
    assert_redirected_to root_path
    @article.update(r_public: 1) # on
    get article_path(@article)
    assert_response :success
# Another user
    login_another_user
    @article.update(r_public: 0) # off
    get article_path(@article)
    assert_redirected_to root_path
    @article.update(r_public: 1) # on
    get article_path(@article)
    assert_response :success
  end

  test "should get edit" do
    login
    get edit_article_path(@article)
    assert_response :success
    assert_select 'div.wnote-main' do
      assert_select "input.form-control[name=?]", 'article[title]'
      assert_select "input.form-control[name=?]", 'article[author]'
#        assert_select "select[name=?]", 'article[date(1i)]'
#        assert_select "select[name=?]", 'article[date(2i)]'
#        assert_select "select[name=?]", 'article[date(3i)]'
#        assert_select "input[type='checkbox'][name=?]", 'article[r_public]'
#        assert_select "input[type='checkbox'][name=?]", 'article[w_public]'
#        assert_select 'ul#sortable' do
#        assert_select 'li.ui-state-default', 'Instalation'
#        assert_select 'li.ui-state-default', 'Rails_generate_scaffold'
#      end
#      assert_select 'input#edit_article_submit'
#      assert_select 'input.btn'
#      assert_select 'input.btn-primary'
    end
  end

  test "incorrect user shouldn't get edit" do
    login_another_user
    @article.update(w_public: 0) # off
    get edit_article_path(@article)
    assert_response :redirect, "Incorrect user saw editing page." 
    @article.update(w_public: 1) # on
    get edit_article_path(@article)
    assert_response :success, "The other user couldn't see editing page, though w_public was on."
  end

  test "should update article" do
    login
    parameter = article_params('New Title', 'New Author', '0', '0', 'en', '2017-04-20 00:00:00 UTC', '50a7f095-6a62-4a39-966b-dcef11ebf810')
    parameter = parameter.merge({section_order: "#{sections(:two).id},#{sections(:one).id}"})
    patch "/articles/#{@article.id}", params: {article: parameter}
    assert_redirected_to article_path(@article)
    assert_equal 'Article was successfully updated.', flash[:success]
    article = Article.find(@article.id) # reload
    assert_equal 'New Title', article.title, "Title wasn't updated."
    assert_equal 'New Author', article.author, "Author wasn't updated."
#   and so on ...
    assert_equal "#{sections(:two).id},#{sections(:one).id}", article.section_order, "Section_order wasn't updated."
  end

  test "incorrect user shouldn't update section" do
    login_another_user
    @article.update(w_public: 0) # off
    patch "/articles/#{@article.id}", params: {article: {title: 'New Title'}}
    article = Article.find(@article.id) # reload
    assert_not_equal 'New Title', @article.title, "Title was updated."
    @article.update(w_public: 1) # on
    patch "/articles/#{@article.id}", params: {article: {title: 'New Title'}}
    article = Article.find(@article.id) # reload
    assert_equal 'New Title', article.title, "Title wasn't updated."
  end

  test "logged in user should destroy article" do
    login
    assert_difference('Article.count', -1) do
      delete "/articles/#{@article.id}"
    end
    assert_redirected_to articles_path
    assert_equal 'Article was successfully destroyed.', flash[:success]
  end

  test "incorrect user shouldn't destroy section" do
    login_another_user
    @article.update(w_public: 1) # even if w_public is on
    assert_no_difference('Article.count') do
      delete "/articles/#{@article.id}"
    end
  end

  private
    def article_params(title,author,r_public,w_public, language, modified_datetime, identifier_uuid)
      parameter = {title: title, author: author, r_public: r_public, w_public: w_public,
                   language: language, modified_datetime: modified_datetime, identifier_uuid: identifier_uuid}
    end
end
