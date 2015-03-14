require 'test_helper'

class NotesControllerTest < ActionController::TestCase
  setup do
    @note = notes(:one)
  end

  test "should get index" do
    get :index
    assert_select 'nav' do
      assert_select 'a.navbar-brand', 'WNote'
      assert_select 'a', 'New Note'
    end
    assert_response :success
    assert_not_nil assigns(:notes)
  end

  test "should get new" do
    get :new
    assert_select 'nav' do
      assert_select 'a.navbar-brand', 'WNote'
    end
    assert_response :success
  end

  test "should create note" do
    assert_difference('Note.count') do
      post :create, note: { text: @note.text, title: @note.title }
    end
    assert_redirected_to note_path(assigns(:note))
    assert_equal 'Note was successfully created.', flash[:success]
  end

  test "should show note" do
    get :show, id: @note
    assert_select 'nav' do
      assert_select 'a.navbar-brand', 'WNote'
      assert_select 'a', 'New Note'
      assert_select 'a', 'Edit'
      assert_select 'a', 'Destroy'
    end
    assert_response :success
  end

  test "should show note with markdown" do
    @note = notes(:three)
    # @note.text includes '### Redcarpet'
    #                     '- line one'
    #                     '- line two'
    #                     '- line three'
    get :show, id: @note
    assert_select 'div.note-main' do
      assert_select 'h3'
    end
    assert_select 'div.note-main' do
      assert_select 'ul' do
        assert_select 'li',3
      end
    end
  end

  test "should get edit" do
    get :edit, id: @note
    assert_select 'nav' do
      assert_select 'a.navbar-brand', 'WNote'
    end
    assert_response :success
  end

  test "should update note" do
    patch :update, id: @note, note: { text: @note.text, title: @note.title }
    assert_redirected_to note_path(assigns(:note))
    assert_equal 'Note was successfully updated.', flash[:success]
  end

  test "should destroy note" do
    assert_difference('Note.count', -1) do
      delete :destroy, id: @note
    end
    assert_redirected_to notes_path
    assert_equal 'Note was successfully destroyed.', flash[:success]
  end

end
