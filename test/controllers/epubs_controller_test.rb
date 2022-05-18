require 'test_helper'

class EpubsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
# Guest can not download epub file.
    get article_epub_url(articles(:wnote))
    assert_response :redirect
    follow_redirect!
    assert_response :success
# Owner can download epub file.
    login
    get article_epub_url(articles(:wnote))
    assert_response :success
    assert_equal "application/epub+zip", @response.content_type
    assert_equal 'attachment; filename="WNote_Howto.epub"; filename*=UTF-8\'\'WNote_Howto.epub', @response.get_header('Content-Disposition')
  end
end
