require 'test_helper'

class ArticlesControllerTest < ActionController::TestCase
  setup do
    @article = articles(:one)
    @section = sections(:one)
    @section.article= @article
    @section.save
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:articles)
    assert_select 'nav' do
      assert_select 'a.navbar-brand', 'WNote'
      assert_select 'a', 'New Article'
    end
    assert_select 'div.wnote-main' do
      assert_select 'td', 'WNote_Howto'
      assert_select 'td', 'Raiils_Howto'
    end
  end

  test "should get new" do
    get :new
    assert_response :success
    assert_select 'nav' do
#      assert_select 'a.navbar-brand', 'WNote'
      assert_select 'a', 'List Articles'
    end
  end

  test "should create article" do
    assert_difference('Article.count') do
      post :create, article: { author: @article.author, date: @article.date, title: @article.title }
    end
    assert_redirected_to article_path(assigns(:article))
    assert_equal 'Article was successfully created.', flash[:success]
  end

  test "should show article" do
    get :show, id: @article
    assert_response :success
    assert_select 'nav' do
#      assert_select 'a.navbar-brand', 'WNote'
      assert_select 'a', 'List Articles'
      assert_select 'a', 'New Article'
      assert_select 'a', 'Edit Article'
      assert_select 'a', 'Destroy Article'
      assert_select 'a', 'New Section'
    end
    assert_select 'div.wnote-main' do
      assert_select 'td', 'Section_one'
    end
  end

  test "should get edit" do
    get :edit, id: @article
    assert_response :success
  end

  test "should update article" do
    patch :update, id: @article, article: { title: @article.title, author: @article.author, date: @article.date }
    assert_redirected_to article_path(assigns(:article))
    assert_equal 'Article was successfully updated.', flash[:success]
  end

  test "should destroy article" do
    assert_difference('Article.count', -1) do
      delete :destroy, id: @article
    end
    assert_redirected_to articles_path
    assert_equal 'Article was successfully destroyed.', flash[:success]
  end
end
