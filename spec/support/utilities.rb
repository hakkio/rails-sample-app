include ApplicationHelper
include ActionView

# More info on this here:
# http://ruby.railstutorial.org/chapters/sign-in-sign-out#code-have_error_message

def sign_in(user)
  visit signin_path
  fill_in "Email",    with: user.email.upcase
  fill_in "Password", with: user.password
  click_button "Sign in"
  cookies[:remember_token] = user.remember_token
end

def signup_fill_in_form
	fill_in "Name",         with: "Example User"
	fill_in "Email",        with: "user@example.com"
	fill_in "Password",     with: "foobar"
	fill_in "Confirmation", with: "foobar"
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    page.should have_selector('div.alert.alert-error', text: message)
  end
end

RSpec::Matchers.define :have_success_message do |message|
  match do |page|
    page.should have_selector('div.alert.alert-success', text: message)
  end
end

RSpec::Matchers.define :have_title do |message|
  match do |page|
    page.should have_selector('title', text: message)
  end
end

RSpec::Matchers.define :have_error_field do |message|
  match do |page|
    page.should have_selector('div#error_explanation ul li', text: message)
  end
end