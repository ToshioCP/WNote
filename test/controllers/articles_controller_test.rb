require 'test_helper'

class ArticlesControllerTest < ActionController::TestCase
  setup do
    @article = articles(:wnote)
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

  test "should get new" do
    get :new
    assert_response :success
    assert_select 'nav' do
#      assert_select 'a.navbar-brand', 'WNote'
      assert_select 'a', 'List Articles'
    end
    assert_select 'div.wnote-main' do
      assert_select 'form.new_article' do
        assert_select 'input.form-control',2
        assert_select 'select'
        assert_select 'input.btn'
        assert_select 'input.btn-primary'
      end
    end
  end

  test "should create article" do
    assert_difference('Article.count') do
      post :create, article: { title: @article.title, author: @article.author, date: @article.date }
    end
    assert_redirected_to article_path(assigns(:article))
    assert_equal 'Article was successfully created.', flash[:success]
  end

  test "should show article" do
    get :show, id: @article
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

  test "should get edit" do
    get :edit, id: @article
    assert_response :success
    assert_select 'div.wnote-main' do
      assert_select 'input.form-control',2
      assert_select 'select'
      assert_select 'ul#sortable' do
        assert_select 'li.ui-state-default', 'Instalation'
        assert_select 'li.ui-state-default', 'Rails_generate_scaffold'
      end
      assert_select 'input#edit_article_submit'
      assert_select 'input.btn'
      assert_select 'input.btn-primary'
    end
  end

  test "should update article" do
    patch :update, id: @article, article: { title: 'New Title', author: 'New Author', 'date(1i)'=> 2015, 'date(2i)'=> 4, 'date(3i)'=> 1,
      section_order: "#{sections(:two).id},#{sections(:one).id}" }
    assert_redirected_to article_path(assigns(:article))
    assert_equal 'Article was successfully updated.', flash[:success]
    @article = Article.find(@article.id) # reload
    assert_equal 'New Title', @article.title, "Title wasn't updated."
    assert_equal 'New Author', @article.author, "Author wasn't updated."
    assert_equal Date.new(2015,4,1), @article.date, "Date wasn't updated."
    assert_equal "#{sections(:two).id},#{sections(:one).id}", @article.section_order, "Title wasn't updated."
  end

  test "should destroy article" do
    assert_difference('Article.count', -1) do
      delete :destroy, id: @article
    end
    assert_redirected_to articles_path
    assert_equal 'Article was successfully destroyed.', flash[:success]
  end
end
