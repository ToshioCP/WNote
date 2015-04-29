require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "MayuIT", email: "MayuIT@mayumail.com", password: "iijjkkll")
    @user.email_confirmation = @user.email
    @user.password_confirmation = @user.password
  end

  test "the legal user can be saved" do
    assert @user.save, "Couldn't save the legal user."
  end
  test "the presence of the name" do
    @user.name = ""
    assert_not @user.save, "Saved the User without a name."
  end
  test "the length of the name should be equal or less than 64" do
    @user.name = "a"*65
    assert_not @user.save, "Saved the User with a long name."
  end

  test "the presence of the email" do
    @user.email = ""
    assert_not @user.save, "Saved the User without an email."
  end
  test "the length of the email should be equal or less than 128" do
    @user.email = "a"*129
    assert_not @user.save, "Saved the User with a long email."
  end
  test "the email should be unique" do
    @user.email = User.first.email
    assert_not @user.save, "Saved the User which email was the same as the one of others."
  end
  test "the email confirmation" do
    @user.email_confirmation = "Mayu@mayu.com"
    assert_not @user.save, "Saved when the email was different from the email_confirmation."
  end
  test "the pattern of the email" do
    ["abcdefg", "aabbcc@123456", "abc..@email.com"].each do |email|
      @user.email = email
      assert_not @user.save, "Saved the User with an illegal email."
    end
  end

  test "the presence of the password_digest" do
    @user.password_digest = ""
    assert_not @user.save, "Saved the User without a password_digest."
  end
  test "the password confirmation" do
    @user.password_confirmation = "foobar"
    assert_not @user.save, "Saved when the user was diffrent from the password_confirmation."
  end
  test "the length of the password should be equal or less than 72" do
    @user.password = "a"*73
    assert_not @user.save, "Saved the User with too long password."
  end
  test "delete the desendant articles and sections and notes when user was deleted" do
    assert_difference('Article.count',-1) do
      assert_difference('Section.count',-2) do
        assert_difference('Note.count',-4) do
          articles(:wnote).destroy
        end
      end
    end
  end

end
