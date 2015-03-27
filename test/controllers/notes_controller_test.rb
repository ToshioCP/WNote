require 'test_helper'

class NotesControllerTest < ActionController::TestCase
  setup do
    @note = notes(:three)
    @note.section= sections(:one)
    @note.save
    @note.section.article= articles(:one)
    @note.section.save
  end

  test "should get new" do
    get :new, section_id: @note.section.id
    assert_select 'nav' do
      assert_select 'a', 'Section'
    end
    assert_response :success
  end

  test "should create note" do
    assert_difference('Note.count') do
      post :create, section_id: @note.section.id, note: { title: @note.title, text: @note.text}
    end
    assert_redirected_to note_path(assigns(:note))
    assert_equal 'Note was successfully created.', flash[:success]
  end

  test "should show note" do
    get :show, id: @note
    assert_select 'nav' do
#      assert_select 'a.navbar-brand', 'WNote'
      assert_select 'a', 'Article'
      assert_select 'a', 'Section'
      assert_select 'a', 'New Note'
      assert_select 'a', 'Edit Note'
      assert_select 'a', 'Destroy Note'
   end
    assert_response :success
  end

  test "should show note with markdown" do
    # @note.text includes '### Redcarpet'
    #                     '- line one'
    #                     '- line two'
    #                     '- line three'
    get :show, id: @note
    assert_select 'div.wnote-main' do
      assert_select 'h3'
      assert_select 'ul' do
        assert_select 'li',3
      end
    end
  end

  test "should get edit" do
    get :edit, id: @note
    assert_select 'nav' do
      assert_select 'a', 'Section'
    end
    assert_response :success
  end

  test "should update note" do
    patch :update, id: @note, note: { title: @note.title, text: @note.text }
    assert_redirected_to note_path(assigns(:note))
    assert_equal 'Note was successfully updated.', flash[:success]
  end

  test "should destroy note" do
    section = @note.section
    assert_difference('Note.count', -1) do
      delete :destroy, id: @note
    end
    assert_redirected_to section_path(section)
    assert_equal 'Note was successfully destroyed.', flash[:success]
  end

end
