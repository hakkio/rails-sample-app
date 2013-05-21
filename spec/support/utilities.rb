include ApplicationHelper


# More info on this here:
# http://ruby.railstutorial.org/chapters/sign-in-sign-out#code-have_error_message

def valid_signin(user)
  fill_in "Email",    with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    page.should have_selector('div.alert.alert-error', text: message)
  end
end

RSpec::Matchers.define :have_alert_message do |alert, message|
  match do |page|
    page.should have_selector('div.alert.alert-' + alert, text: message)
  end
end