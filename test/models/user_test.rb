require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new({ :name => "Example user", :email => "user@example.com",
                       :password => "foobar", :password_confirmation => "foobar"})
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "     "
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "     "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = 'a' * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.name = 'a' * 244 + '@example.com'
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.working
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    valid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                         foo@bar_baz.com foo@baz+baz.com foo@bar..com]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert_not @user.valid?, "#{valid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email addresses should be saved as lower-case" do
    mixed_case_email = 'fOOBaR@exAmPle.COm'
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should be present" do
    @user.password = @user.password_confirmation = "     "
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "abcde"
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    usr1 = users(:user_1)
    usr2 = users(:user_2)
    usr3 = users(:user_3)
    assert_not usr1.following?(usr2)
    usr1.follow(usr2)
    usr1.follow(usr3)
    assert usr1.following?(usr2)
    assert usr1.following?(usr3)
    assert usr2.followers.include?(usr1)
    assert_not usr2.following?(usr1)
    usr1.unfollow(usr2)
    assert_not usr1.following?(usr2)
  end

  test "feed should have the right posts" do
    michael = users(:michael)
    lana = users(:lana)
    archer = users(:archer)

    # Posts from followed user
    lana.microposts.each do |post_following|
      assert michael.feed.include?(post_following)
    end

    # Posts from self
    michael.microposts.each do |post_self|
      assert michael.feed.include?(post_self)
    end

    # Posts from unfollowed user
    archer.microposts.each do |post_unfollowed|
      assert_not michael.feed.include?(post_unfollowed)
    end
  end
end
