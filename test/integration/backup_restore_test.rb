require 'test_helper'

class BackupRestoreTest < ActionDispatch::IntegrationTest
  test "backup and restore" do
    @article_before = Article.find_by(title: 'WNote_Howto')
    post "/logins/create", params: {email: 'lxboyjp@gmail.com', password: 'aabbccddeeffgg'}

    get "/user/backup"
    File.open("test_backup", "w") do |f|
      f.write @response.body
    end

    get "/user/reset"
    assert_nil Article.find_by(title: 'WNote_Howto')
    follow_redirect!
    assert_equal '/user', path
    assert_equal 'All articles was successfully destroyed.', flash[:success]

    post "/user/restore", params: {restore_data: fixture_file_upload("test_backup", 'multipart/form-data')}
    follow_redirect!
    assert_equal '/user', path
    assert_equal 'Backup data was successfully restored.', flash[:success]
    @article_after = Article.find_by(title: 'WNote_Howto')
    assert_equal @article_before.author, @article_after.author
    assert_equal @article_before.language, @article_after.language
    assert_equal @article_before.modified_datetime, @article_after.modified_datetime
    assert_equal @article_before.identifier_uuid, @article_after.identifier_uuid

    File.delete "test_backup"
  end
end
