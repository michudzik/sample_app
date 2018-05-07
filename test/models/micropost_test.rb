require 'test_helper'

class MicropostTest < ActiveSupport::TestCase

  def setup
    @user = users(:michael)
    @micropost = Micropost.new(:content => "Lorem ipsum", :user_id => @user.id)
  end

  test "should be valid" do
    assert @micropost.valid?
  end

  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test "content should be present" do
    @micropost.content = "   "
    assert_not @micropost.valid?
  end

  test "content should not be longer than 140 characters" do
    @micropost.content = 'a' * 141
    assert_not @micropost.valid?
  end

  test "content should allow posts shorter than 141 characters" do
    @micropost.content = 'a' * 140
    assert @micropost.valid?
  end

end
