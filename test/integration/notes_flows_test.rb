require 'test_helper'

class NotesFlowsTest < ActionDispatch::IntegrationTest
  test "new and create" do
    @note = notes(:one)
    get "/notes/new"
    assert_response :success

    post_via_redirect "/notes", note: {title: @note.title, text: @note.text}
    assert_equal note_path, path
#    assert_equal 'Note was successfully created.', flash[:success]
    assert_select 'div.alert', 'Note was successfully created.'
  end
  test "edit and update" do
    @note = notes(:one)
    @note3 = notes(:three)
    get "/notes/#{@note.id}/edit"
    assert_response :success

    patch_via_redirect "/notes/#{@note.id}", note: {title: @note3.title, text: @note3.text}
    assert_equal "/notes/#{@note.id}", path
#    assert_equal 'Note was successfully updated.', flash[:success]
    assert_select 'div.alert', 'Note was successfully updated.'
  end
  test "destroy" do
    @note = notes(:one)
    get "/notes/#{@note.id}"
    assert_response :success

    delete_via_redirect "/notes/#{@note.id}"
    assert_equal "/notes", path
#    assert_equal 'Note was successfully updated.', flash[:success]
    assert_select 'div.alert', 'Note was successfully destroyed.'
  end
end
