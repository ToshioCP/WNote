require 'test_helper'

class BackupRestoreTest < ActionDispatch::IntegrationTest

  setup do
    @user = users(:toshiocp)
  end

  test "backup and restore" do
    @article_before = Article.find_by(title: 'WNote_Howto')

    login
    get user_backup_path
    assert_response :success
# integration testでは、getやpostの後に@responseでレスポンスを知ることができる
# ダウンロードファイルを一時保存
    File.open("test_backup", "w") do |f|
      f.write @response.body
    end

    get user_reset_path
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_nil Article.find_by(title: 'WNote_Howto')
# integration test では、path（リクエスト先）やstatus（レスポンスコード）というメソッドが使える
# このことはドキュメントの例には出てくるが、解説はあまり見かけない
    assert_equal '/user', path
    assert_equal 'All Articles was successfully destroyed.', flash[:success]

# 一時保存したダウンロードファイルをアップロード
# このとき、インテグレーションテストでは、fixture_file_uploadメソッドを使うことができる
    post "/user/restore", params: {restore_data: fixture_file_upload("test_backup", 'application/json')}
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_equal '/user', path
    assert_equal 'Backup data was successfully restored.', flash[:success]

# 新しくアップロードしたため、articleのidなどは以前と変わってしまうが、タイトルなどの内容は同じものになっているはず
    @article_after = Article.find_by(title: 'WNote_Howto')
    assert_equal @article_before.author, @article_after.author
    assert_equal @article_before.language, @article_after.language
    assert_equal @article_before.modified_datetime, @article_after.modified_datetime
    assert_equal @article_before.identifier_uuid, @article_after.identifier_uuid

# 後始末。一時ファイルを削除。
    File.delete "test_backup"
  end
end
