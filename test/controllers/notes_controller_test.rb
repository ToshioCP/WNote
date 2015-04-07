require 'test_helper'

class NotesControllerTest < ActionController::TestCase
  setup do
    @note = notes(:install_rbenv)
    @note_markdown = notes(:markdown)
  end

  test "should get new" do
    get :new, section_id: @note.section_id
    assert_response :success
    assert_select 'nav' do
      assert_select 'a', 'Section'
    end
    assert_select 'select.form-control' do
      assert_select 'option',sections(:one).heading
      assert_select 'option',sections(:two).heading
    end
    assert_select 'input.form-control'
    assert_select 'textarea.form-control'
    assert_select 'input.btn'
    assert_select 'input.btn-primary'
  end

  test "should create note" do
    section_id = sections(:one).id
    assert_difference('Note.count') do
      post :create, note: { section_id: section_id, title: 'New Title', text: 'New Text'}
    end
    note = Note.find(assigns(:note).id)
    assert_redirected_to note_path(assigns(:note))
    assert_equal 'Note was successfully created.', flash[:success]
    assert_equal section_id, note.section_id
    assert_equal 'New Title', note.title
    assert_equal 'New Text', note.text
  end

  test "should show note" do
    get :show, id: @note_markdown
    assert_response :success
    assert_select 'nav' do
#      assert_select 'a.navbar-brand', 'WNote'
      assert_select 'a', 'Article'
      assert_select 'a', 'Section'
      assert_select 'a', 'New Note'
      assert_select 'a', 'Edit Note'
      assert_select 'a', 'Destroy Note'
   end
    assert_select 'div.wnote-main' do
#     @note_markdown.title = 'redcarpet'
      assert_select 'h2.text-center', 'redcarpet'
#     @note_markdown.text is '### Redcarpet'
#                            '- line one'
#                            '- line two'
#                            '- line three'
      assert_select 'h3', 'Redcarpet'
      assert_select 'ul' do
        assert_select 'li', 'line one'
        assert_select 'li', 'line two'
        assert_select 'li', 'line three'
      end
    end
  end

  test "should get edit" do
    get :edit, id: @note
    assert_response :success
    assert_select 'nav' do
      assert_select 'a', 'Section'
    end
    assert_select 'div.wnote-main' do
      assert_select 'select.form-control' do
        assert_select 'option',sections(:one).heading
        assert_select 'option',sections(:two).heading
      end
      assert_select 'input.form-control'
      assert_select 'textarea.form-control'
      assert_select 'input.btn'
      assert_select 'input.btn-primary'
    end
  end

  test "should update note" do
    section_id = sections(:two).id
    patch :update, id: @note, note: { section_id: section_id, title: 'New Title', text: 'New Text' }
    assert_redirected_to note_path(assigns(:note))
    assert_equal 'Note was successfully updated.', flash[:success]
    note = Note.find(@note.id)
    assert_equal section_id, note.section_id
    assert_equal 'New Title', note.title
    assert_equal 'New Text', note.text
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
