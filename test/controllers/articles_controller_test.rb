require 'test_helper'

class ArticlesControllerTest < ActionController::TestCase

  setup do
    @article = articles(:wnote)
    @user = users(:toshiocp)
# @another_user is not the owner of @note.
# It is used in the test for the read/write permission and r/w_public flag.
    @another_user = users(:foobar)
# Some situations make the redirection to :back.
# For example GUEST can't access some action and it make the redirection to :back.
# Testing such redirection needs HTTP_REFERER.
    @request.headers["HTTP_REFERER"] = root_url
  end

  test "should get index" do
    articles(:wnote).update(r_public: 1)
    articles(:rails_howto).update(r_public: 1)
    get :index
    assert_response :success
    assert_not_nil assigns(:articles)
    assert_select 'nav' do
      assert_select 'a.navbar-brand', 'WNote'
#      assert_select 'a', 'New Article'
    end
    assert_select 'div.wnote-main' do
      assert_select 'th', 'Show'
      assert_select 'th', 'Title'
      assert_select 'th', 'Author'
      assert_select 'th', 'Date'
      assert_select 'td', 'Show'
      assert_select 'td', 'WNote_Howto'
      assert_select 'td', 'ToshioCP'
      assert_select 'td', '2015-03-21'
      assert_select 'td', 'Show'
      assert_select 'td', 'Raiils_Howto'
      assert_select 'td', 'Toshio_Sekiya'
      assert_select 'td', '2015-03-21'
    end
  end

  test "should get index under collect permission" do
    articles(:wnote).update(r_public: 0)
    articles(:rails_howto).update(r_public: 0)
    get :index, nil, {current_user_id: @user.id}
    assert_response :success
    assert_includes assigns(:articles), articles(:wnote)
    assert_not_includes assigns(:articles), articles(:rails_howto)
  end

  test "should get new" do
    get :new,nil, { current_user_id: @user.id }
    assert_response :success
    assert_select 'nav' do
#      assert_select 'a.navbar-brand', 'WNote'
      assert_select 'a', 'List Articles'
    end
    assert_select 'div.wnote-main' do
      assert_select 'form.new_article' do
        assert_select "input.form-control[name=?]", 'article[title]'
        assert_select "input.form-control[name=?]", 'article[author]'
        assert_select "select[name=?]", 'article[date(1i)]'
        assert_select "select[name=?]", 'article[date(2i)]'
        assert_select "select[name=?]", 'article[date(3i)]'
        assert_select "input[type='checkbox'][name=?]", 'article[r_public]'
        assert_select "input[type='checkbox'][name=?]", 'article[w_public]'
        assert_select "input[class='btn btn-primary']"
      end
    end
  end

  test "guest shouldn't get new" do
    get :new
    assert_redirected_to :back
  end

  test "should create article" do
    parameter = article_params('new title', 'mayuu', '2015', '4', '26', '0', '0')
    assert_difference('Article.count') do
      post :create, {article: parameter}, {current_user_id: @user.id}
    end
    article = assigns(:article)
    assert_redirected_to article_path(article)
    assert_equal 'Article was successfully created.', flash[:success]
    assert_equal article.user, @user, "Created article does not belong to the creating user." 
  end

  test "guest shouldn't get create" do
    parameter = article_params('new title', 'mayuu', '2015', '4', '26', '0', '0')
    assert_no_difference('Article.count') do
      post :create, article: parameter
    end
  end

  test "should show article" do
    get :show, {id: @article}, {current_user_id: @user.id}
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
    @article.update(r_public: 0) # off
    get :show, {id: @article}, {current_user_id: @another_user.id}
    assert_redirected_to :back
    get :show, {id: @article}, {current_user_id: nil} #GUEST
    assert_redirected_to :back
    @article.update(r_public: 1) # on
    get :show, {id: @article}, {current_user_id: @another_user.id}
    assert_response :success
    get :show, {id: @article}, {current_user_id: nil} #GUEST
    assert_response :success
  end

  test "should get edit" do
    get :edit, {id: @article} , {current_user_id: @user.id}
    assert_response :success
    assert_select 'div.wnote-main' do
        assert_select "input.form-control[name=?]", 'article[title]'
        assert_select "input.form-control[name=?]", 'article[author]'
        assert_select "select[name=?]", 'article[date(1i)]'
        assert_select "select[name=?]", 'article[date(2i)]'
        assert_select "select[name=?]", 'article[date(3i)]'
        assert_select "input[type='checkbox'][name=?]", 'article[r_public]'
        assert_select "input[type='checkbox'][name=?]", 'article[w_public]'
        assert_select 'ul#sortable' do
        assert_select 'li.ui-state-default', 'Instalation'
        assert_select 'li.ui-state-default', 'Rails_generate_scaffold'
      end
      assert_select 'input#edit_article_submit'
      assert_select 'input.btn'
      assert_select 'input.btn-primary'
    end
  end

  test "incorrect user shouldn't get edit" do
    @article.update(w_public: 0) # off
    get :edit, {id: @article} , {current_user_id: @another_user.id}
    assert_response :redirect, "Incorrect user saw editing page." 
    @article.update(w_public: 1) # on
    get :edit, {id: @article} , {current_user_id: @another_user.id}
    assert_response :success, "The other user couldn't see editing page, though w_public was on."
  end

  test "should update article" do
    parameter = article_params('New Title', 'New Author', '2015', '4', '1', '0', '0')
    parameter = parameter.merge({section_order: "#{sections(:two).id},#{sections(:one).id}"})
    patch :update, {id: @article, article: parameter}, {current_user_id: @user.id}
    assert_redirected_to article_path(assigns(:article))
    assert_equal 'Article was successfully updated.', flash[:success]
    article = Article.find(@article.id) # reload
    assert_equal 'New Title', article.title, "Title wasn't updated."
    assert_equal 'New Author', article.author, "Author wasn't updated."
    assert_equal Date.new(2015,4,1), article.date, "Date wasn't updated."
    assert_equal "#{sections(:two).id},#{sections(:one).id}", article.section_order, "Section_order wasn't updated."
  end

  test "incorrect user shouldn't update section" do
    @article.update(w_public: 0) # off
    patch :update, {id: @article, article: {title: 'New Title'}}, {current_user_id: @another_user.id}
    article = Article.find(@article.id) # reload
    assert_not_equal 'New Title', @article.title, "Title was updated."
    @article.update(w_public: 1) # on
    patch :update, {id: @article, article: {title: 'New Title'}}, {current_user_id: @another_user.id}
    article = Article.find(@article.id) # reload
    assert_equal 'New Title', article.title, "Title wasn't updated."
  end

  test "should destroy article" do
    assert_difference('Article.count', -1) do
      delete :destroy, {id: @article}, {current_user_id: @user.id}
    end
    assert_redirected_to articles_path
    assert_equal 'Article was successfully destroyed.', flash[:success]
  end

  test "incorrect user shouldn't destroy section" do
    @article.update(w_public: 1) # even if w_public is on
    assert_no_difference('Article.count') do
      delete :destroy, {id: @article}, {current_user_id: @another_user.id}
    end
  end

  private
    def article_params(title,author,year,month,day,r_public,w_public)
      date = {:'date(1i)'=> year, :'date(2i)'=> month, :'date(3i)'=> day}
      parameter = {title: title, author: author, r_public: r_public, w_public: w_public}.merge(date)
    end
end
