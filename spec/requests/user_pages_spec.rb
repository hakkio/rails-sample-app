require 'spec_helper'

describe "UserPages" do

	subject { page }

	describe "profile page" do
		let(:user) { FactoryGirl.create(:user) }
		before { visit user_path(user) }

		it { should have_selector('h1',    text: user.name) }
		it { should have_title(user.name) }
	end

	describe "signup page" do
		before { visit signup_path }
		let(:submit) { "Create my account" }

		it { should have_selector('h1',    text: 'Sign up') }
		it { should have_title(full_title('Sign up')) }

		describe "with invalid information" do
			it "should not create a user" do
				expect { click_button submit  }.not_to change(User, :count)
			end

			describe "after submission" do
				before { click_button submit }

				it { should have_selector('h1', text: 'Sign up') }

				# Error messages
				it { should have_error_message('The form contains') }
				it { should have_error_field('Email is invalid') }
				it { should have_error_field('Name can\'t be blank') }
				it { should have_error_field('Password can\'t be blank') }
				it { should have_error_field('Password confirmation') }

				# Make sure fields are highlighted
				it { should have_selector('div.field_with_errors') }
			end
		end

		describe "with valid information" do
			before { signup_fill_in_form } 

			it "should create a user" do
				expect { click_button submit }.to change(User, :count).by(1)
			end

			describe "after saving the user" do
				before { click_button submit }
				
				let (:user) { User.find_by_email('user@example.com')}

				it { should have_title(user.name) }
				it { should have_success_message('Welcome') }
				it { should have_link('Sign out') }
			end
		end	

	end

end
