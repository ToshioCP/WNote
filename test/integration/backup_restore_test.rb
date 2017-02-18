require 'test_helper'

class BackupRestoreTest < ActionDispatch::IntegrationTest
  test "backup and restore" do
    @article_before = Article.find_by(title: 'WNote_Howto')
    post "/logins/create", email: 'lxboyjp@gmail.com', password: 'aabbccddeeffgg'

    get "/users/backup"
    File.open("test_backup", "w") do |f|
      f.write @response.body
    end

    get "/users/reset"
    assert_nil Article.find_by(title: 'WNote_Howto')

    post_via_redirect "/users/restore", restore_data: fixture_file_upload("test_backup", 'multipart/form-data')
    assert_equal '/users', path
    assert_equal 'Backup data was successfully restored.', flash[:success]
    @article_after = Article.find_by(title: 'WNote_Howto')
    assert_equal @article_before.author, @article_after.author
    assert_equal @article_before.date, @article_after.date

    File.delete "test_backup"
  end
end
