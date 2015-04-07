require 'test_helper'

class SectionsControllerTest < ActionController::TestCase
  setup do
    @section = sections(:one)
  end

  test "should get new" do
    get :new, article_id: @section.article.id
    assert_response :success
    assert_select 'nav' do
      assert_select 'a', 'Article'
    end
    assert_select 'form' do
      assert_select 'select.form-control' do
        assert_select 'option',articles(:wnote).title
        assert_select 'option',articles(:rails_howto).title
      end
      assert_select 'input.form-control'
      assert_select 'input.btn'
      assert_select 'input.btn-primary'
    end
  end

  test "should get create" do
    article_id = articles(:wnote).id
    assert_difference('Section.count') do
      post :create, section: { article_id: article_id, heading: 'New Heading' }
    end
    section = Section.find(assigns(:section).id)
    assert_redirected_to section_path(section)
    assert_equal 'Section was successfully created.', flash[:success]
    assert_equal article_id, section.article_id
    assert_equal 'New Heading', section.heading
  end

  test "should show section" do
    get :show, id: @section
    assert_select 'nav' do
#      assert_select 'a.navbar-brand', 'WNote'
      assert_select 'a', 'Article'
      assert_select 'a', 'New Section'
      assert_select 'a', 'Edit Section'
      assert_select 'a', 'Destroy Section'
      assert_select 'a', 'New Note'
    end
    assert_response :success
    assert_select 'div.wnote-main' do
      assert_select 'h2', @section.heading
      assert_select 'tr' do
        assert_select 'td', 'Show'
        assert_select 'td', 'Install_rbenv'
        assert_select 'td', 'Visit rbeny site and download it.'
      end
    end
  end

  test "should get edit" do
    get :edit, id: @section
    assert_response :success
    assert_select 'nav' do
      assert_select 'a', 'Article'
    end
    assert_select 'div.wnote-main' do
      assert_select 'select.form-control' do
        assert_select 'option',articles(:wnote).title
        assert_select 'option',articles(:rails_howto).title
      end
      assert_select 'input.form-control'
      assert_select 'ul' do
        assert_select 'li', 'Install_rbenv'
        assert_select 'li', 'Install_ruby'
        assert_select 'li', 'Install_rails'
      end
      assert_select 'input.btn'
      assert_select 'input.btn-primary'
      assert_select 'input#edit_section_submit'
    end
  end

  test "should get update" do
    article_id = articles(:rails_howto).id
    note_order = "#{notes(:install_ruby)},#{notes(:install_rbenv)},#{notes(:install_rails)}" # exchange 1,2
    patch :update, id: @section, section: { article_id: article_id, heading: 'Updated Heading', note_order: note_order}
    assert_redirected_to section_path(assigns(:section))
    assert_equal 'Section was successfully updated.', flash[:success]
    section = Section.find(@section.id)
    assert_equal article_id, section.article_id
    assert_equal 'Updated Heading', section.heading
    assert_equal note_order, section.note_order
  end

  test "should destroy article" do
    article = @section.article
    assert_difference('Section.count', -1) do
      delete :destroy, id: @section
    end
    assert_redirected_to article_path(article)
    assert_equal 'Section was successfully destroyed.', flash[:success]
  end
end
