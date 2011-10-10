Given /^I am not authenticated$/ do
  visit('/users/sign_out') # ensure that at least
end

Given /^I am logged in as admin$/ do
  admin = User.make!(:admin)

  Given %{I go to the login page}
  And %{I fill in "user_email" with "#\{admin.email\}"}
  And %{I fill in "user_password" with "#\{admin.password\}"}
  And %{I press "Sign in"}
end

Given /^I am logged in as a user$/ do
  user = User.make!

  Given %{I go to the login page}
  And %{I fill in "user_email" with "#\{user.email\}"}
  And %{I fill in "user_password" with "#\{user.password\}"}
  And %{I press "Sign in"}
end
