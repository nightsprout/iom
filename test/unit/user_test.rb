# == Schema Information
#
# Table name: users
#
#  id                                     :integer          not null, primary key
#  name                                   :string(100)      default("")
#  email                                  :string(100)
#  crypted_password                       :string(40)
#  salt                                   :string(40)
#  created_at                             :datetime
#  updated_at                             :datetime
#  remember_token                         :string(40)
#  remember_token_expires_at              :datetime
#  organization_id                        :integer
#  role                                   :string(255)
#  blocked                                :boolean          default(FALSE)
#  site_id                                :string(255)
#  description                            :text
#  password_reset_token                   :string(255)
#  password_reset_sent_at                 :datetime
#  last_login                             :datetime
#  six_months_since_last_login_alert_sent :boolean          default(FALSE)
#  login_fails                            :integer          default(0)
#

require File.expand_path('../../test_helper', __FILE__)

class UserTest < ActiveSupport::TestCase

  def test_should_create_user
    assert_difference 'User.count' do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_password
    assert_no_difference 'User.count' do
      u = new_user(:password => nil)
      assert !u.valid?
      assert u.errors[:password]
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'User.count' do
      u = new_user(:password_confirmation => nil)
      assert !u.valid?
      assert u.errors[:password_confirmation]
    end
  end

  def test_should_require_email
    assert_no_difference 'User.count' do
      u = new_user(:email => nil)
      assert !u.valid?
      assert u.errors[:email]
    end
  end

  def test_should_reset_password
    user = create_user
    user.update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal user, User.authenticate(user.email, 'new password')
  end

  def test_should_authenticate_user
    user = create_user
    assert_equal user, User.authenticate('admin@example.com', 'admin')
  end

end
