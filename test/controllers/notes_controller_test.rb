require 'test_helper'

class NotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @note = notes(:install_rbenv)
    @section = @note.section
    @article = @section.article
    @user = @article.user
    @note_markdown = notes(:markdown)
  end

  test "logged in user should get new" do
# Guest can not access to new
    get new_section_note_url(@section)
    assert_response :redirect
    follow_redirect!
    assert_response :success
# login
    login
# Owner can access to new
    get new_section_note_url(@section)
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

  test "logged in user should get create" do
# Guest can not create
    assert_no_difference('Note.count') do
      post notes_path, params: {note: {section_id: @section.id, title: 'New Title', text: 'New Text'}}
    end
# login
    login
# Owner can create
    assert_difference('Note.count') do
      post notes_path, params: {note: {section_id: @section.id, title: 'New Title', text: 'New Text'}}
    end
    note = Note.last
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_equal 'Note was successfully created.', flash[:success]
    assert_equal @section, note.section
    assert_equal 'New Title', note.title
    assert_equal 'New Text', note.text
  end

  test "logged in user should show note" do
    login
    get note_path(@note_markdown)
    assert_response :success
    assert_select 'nav' do
#      assert_select 'a.navbar-brand', 'WNote'
      assert_select 'a', 'Article'
      assert_select 'a', 'Section'
      assert_select 'a', 'New Note'
      assert_select 'a', 'Edit Note'
      assert_select 'a', 'Delete Note'
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

  test "Only the owner can read note when r_public is off" do
#Guest
    @article.update(r_public: 0) # off
    get note_path(@note)
    assert_response :redirect
    follow_redirect!
    assert_response :success
    @article.update(r_public: 1) # on
    get note_path(@note)
    assert_response :success
# login
    login
# Owner
    @article.update(r_public: 0) # off
    get note_path(@note)
    assert_response :success
    @article.update(r_public: 1) # on
    get note_path(@note)
    assert_response :success
  end

  test "logged in user should get edit" do
    login
    get edit_note_path(@note)
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
      assert_select "input[class='btn btn-primary']"
    end
  end

  test "incorrect user shouldn't get edit" do
    login_another_user
    @article.update(w_public: 0) # off
    get edit_note_path(@note)
    assert_response :redirect, "Incorrect user saw editing page." 
    @article.update(w_public: 1) # on
    get edit_note_path(@note)
    assert_response :success, "The other user couldn't see editing page, though w_public was on."
  end

  test "logged in user should update note" do
    login
    section_id = sections(:two).id
    patch "/notes/#{@note.id}", params: {note: {section_id: section_id, title: 'New Title', text: 'New Text'}}
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_equal 'Note was successfully updated.', flash[:success]
    note = Note.find(@note.id)
    assert_equal section_id, note.section_id
    assert_equal 'New Title', note.title
    assert_equal 'New Text', note.text
  end

  test "incorrect user shouldn't update note" do
    login_another_user
    @article.update(w_public: 0) # off
    patch "/notes/#{@note.id}", params: {note: {title: 'Hello World.'}}
    note = Note.find(@note.id) # reload
    assert_not_equal 'Hello World.', note.title, "Title was updated."
    @article.update(w_public: 1) # on
    patch "/notes/#{@note.id}", params: {note: {title: 'Hello World.'}}
    note = Note.find(@note.id) # reload
    assert_equal 'Hello World.', note.title, "Title wasn't updated."
  end

  test "logged in user should destroy note" do
    login
    section = @note.section
    assert_difference('Note.count', -1) do
      delete "/notes/#{@note.id}"
    end
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_equal 'Note was successfully destroyed.', flash[:success]
  end

  test "incorrect user shouldn't destroy note" do
    login_another_user
    @article.update(w_public: 1) # even if w_public is on
    assert_no_difference('Note.count') do
      delete "/notes/#{@note.id}"
    end
  end
end
