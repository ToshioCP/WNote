require 'test_helper'

class NotesControllerTest < ActionController::TestCase
  setup do
    @note = notes(:install_rbenv)
    @section = @note.section
    @article = @section.article
    @note_markdown = notes(:markdown)
    @user = users(:toshiocp)
# @another_user is not the owner of @note.
# It is used in the test for the read/write permission and r/w_public flag.
    @another_user = users(:foobar)
# Some situations make the redirection to :back.
# For example GUEST can't access some action and it make the redirection to :back.
# Testing such redirection needs HTTP_REFERER.
    @request.headers["HTTP_REFERER"] = root_url
  end

  test "should get new" do
    get :new, {section_id: @section.id}, {current_user_id: @user.id}
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

  test "guest shouldn't get new" do
    get :new, {section_id: @section.id}
    assert_redirected_to :back
  end

  test "should get create" do
    assert_difference('Note.count') do
      post :create, {note: {section_id: @section.id, title: 'New Title', text: 'New Text'}}, {current_user_id: @user.id}
    end
    note = Note.find(assigns(:note).id)
    assert_redirected_to note_path(assigns(:note))
    assert_equal 'Note was successfully created.', flash[:success]
    assert_equal @section, note.section
    assert_equal 'New Title', note.title
    assert_equal 'New Text', note.text
  end

  test "guest shouldn't create note" do
    assert_no_difference('Note.count') do
      post :create, {note: {section_id: @section.id, title: 'New Title', text: 'New Text'}}
    end
 end

  test "should show note" do
    get :show, {id: @note_markdown}, {current_user_id: @note_markdown.section.article.user.id} 
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

  test "Only the owner can read note when r_public is off" do
    @article.update(r_public: 0) # off
    get :show, {id: @note}, {current_user_id: @another_user.id}
    assert_redirected_to :back
    get :show, {id: @note}, {current_user_id: nil} #GUEST
    assert_redirected_to :back
    @article.update(r_public: 1) # on
    get :show, {id: @note}, {current_user_id: @another_user.id}
    assert_response :success
    get :show, {id: @note}, {current_user_id: nil} #GUEST
    assert_response :success
  end

  test "should get edit" do
    get :edit, {id: @note}, {current_user_id: @user.id}
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
    @article.update(w_public: 0) # off
    get :edit, {id: @note} , {current_user_id: @another_user.id}
    assert_response :redirect, "Incorrect user saw editing page." 
    @article.update(w_public: 1) # on
    get :edit, {id: @note} , {current_user_id: @another_user.id}
    assert_response :success, "The other user couldn't see editing page, though w_public was on."
  end

  test "should update note" do
    section_id = sections(:two).id
    patch :update, {id: @note, note: {section_id: section_id, title: 'New Title', text: 'New Text'}}, {current_user_id: @user.id}
    assert_redirected_to note_path(assigns(:note))
    assert_equal 'Note was successfully updated.', flash[:success]
    note = Note.find(@note.id)
    assert_equal section_id, note.section_id
    assert_equal 'New Title', note.title
    assert_equal 'New Text', note.text
  end

  test "incorrect user shouldn't update note" do
    @article.update(w_public: 0) # off
    patch :update, {id: @note, note: {title: 'Hello World.'}}, {current_user_id: @another_user.id}
    note = Note.find(@note.id) # reload
    assert_not_equal 'Hello World.', note.title, "Title was updated."
    @article.update(w_public: 1) # on
    patch :update, {id: @note, note: {title: 'Hello World.'}}, {current_user_id: @another_user.id}
    note = Note.find(@note.id) # reload
    assert_equal 'Hello World.', note.title, "Title wasn't updated."
  end

  test "should destroy note" do
    section = @note.section
    assert_difference('Note.count', -1) do
      delete :destroy, {id: @note}, {current_user_id: @user.id}
    end
    assert_redirected_to section_path(section)
    assert_equal 'Note was successfully destroyed.', flash[:success]
  end

  test "incorrect user shouldn't destroy note" do
    @article.update(w_public: 1) # even if w_public is on
    assert_no_difference('Note.count') do
      delete :destroy, {id: @note}, {current_user_id: @another_user.id}
    end
  end

end
