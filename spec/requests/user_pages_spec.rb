require 'spec_helper'

describe "UserPages" do

	subject { page }

	describe "user index" do
		let(:user) { FactoryGirl.create(:user) }
		before do
			sign_in user
			visit users_path
		end

		it { should have_title('All users') }
		it { should have_selector('h1', text: 'All users') }

		describe "pagination" do
			before(:all) { 30.times { FactoryGirl.create(:user) } }
			after(:all) { User.delete_all }
	
			it { should have_selector('div.pagination') }

			it "should list each user" do
				User.paginate(page: 1, per_page: 10).each do |user|
					page.should have_selector('li', text: user.name)
				end
			end
		end

		describe "delete links" do
			it { should_not have_link('delete') }

			describe "as an admin user" do
				let(:admin) { FactoryGirl.create(:admin) }
				before do
					sign_in admin
					visit users_path
				end

				it { should have_link('delete', href: user_path(User.first)) }
				it "should be able to delete another user" do
					expect {click_link('delete') }.to change(User, :count).by(-1)
				end
				it { should_not have_link('delete', href: user_path(admin)) }

				it 'should not be able to delete themself' do
					expect { page.driver.delete(user_path(admin)) }.to change(User, :count).by(0)
				end
			end
		end
	end

	describe "profile page" do
	    let(:user) { FactoryGirl.create(:user) }
	    let!(:m1) { FactoryGirl.create(:micropost, user: user, content: "Foo") }
	    let!(:m2) { FactoryGirl.create(:micropost, user: user, content: "Bar") }

	    before { visit user_path(user) }

	    it { should have_content(user.name) }
	    it { should have_title(user.name) }

	    describe "microposts" do
	      it { should have_content(m1.content) }
	      it { should have_content(m2.content) }
	      it { should have_content(user.microposts.count) }

	      describe "after logging in" do
	      	before do
	      		sign_in user
	      		visit user_path(user)
	      	end
	    	it { should have_link('delete', href: micropost_path(m1)) }

	    	describe "viewing another user's profile" do
		    	let(:another_user) { FactoryGirl.create(:user) }
		      	let!(:m3) { FactoryGirl.create(:micropost, user: another_user, content: "Foo") }
	    		let!(:m4) { FactoryGirl.create(:micropost, user: another_user, content: "Bar") }
		    	before do
		    		sign_in user
		    		visit user_path(another_user)
		    	end

		    	it { should_not have_link('delete') }
	    	end  	
	      end
	    end

	    describe "follow/unfollow buttons" do
	      let(:other_user) { FactoryGirl.create(:user) }
	      before { sign_in user }

	      describe "following a user" do
	        before { visit user_path(other_user) }

	        it "should increment the followed user count" do
	          expect do
	            click_button "Follow"
	          end.to change(user.followed_users, :count).by(1)
	        end

	        it "should increment the other user's followers count" do
	          expect do
	            click_button "Follow"
	          end.to change(other_user.followers, :count).by(1)
	        end

	        describe "toggling the button" do
	          before { click_button "Follow" }
	          it { should have_selector('input', value: 'Unfollow') }
	        end
	      end

	      describe "unfollowing a user" do
	        before do
	          user.follow!(other_user)
	          visit user_path(other_user)
	        end

	        it "should decrement the followed user count" do
	          expect do
	            click_button "Unfollow"
	          end.to change(user.followed_users, :count).by(-1)
	        end

	        it "should decrement the other user's followers count" do
	          expect do
	            click_button "Unfollow"
	          end.to change(other_user.followers, :count).by(-1)
	        end

	        describe "toggling the button" do
	          before { click_button "Unfollow" }
	          it { should have_selector('input', value: 'Follow') }
	        end
	      end
	 	end
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

	describe "edit profile page" do
		let(:user) { FactoryGirl.create(:user) }
		before do
			sign_in user
			visit edit_user_path(user)
		end

		let(:submit) { "Save changes" }

		describe "page" do
			it { should have_selector('h1', text: "Update your profile") }
			it { should have_title('Edit user') }
			it { should have_link('change', href: 'http://gravatar.com/emails') }
		end

		describe "with invalid information" do
			before { click_button submit }

			it { should have_content('error') }
		end

		describe "with valid information" do
			let(:new_name) { "Joe" }
			let(:new_email) { "joe@gmail.com" }
			before do
				fill_in "Name",         with: new_name
		        fill_in "Email",        with: new_email
		        fill_in "Password",     with: user.password
		        fill_in "Confirmation", with: user.password
			 	click_button submit
			end

			it { should have_success_message('Successfully updated settings') }
			it { should have_title(new_name) }
			it { should have_link('Sign out', href: signout_path) }
			specify { user.reload.name.should  == new_name }
      		specify { user.reload.email.should == new_email }
		end
	end

	describe "following/followers" do
		let(:user) { FactoryGirl.create(:user) }
		let(:other_user) { FactoryGirl.create(:user) }
		before { user.follow!(other_user) }

		describe "followed users" do
			before do
				sign_in user
				visit following_user_path(user)
			end

		    it { should have_selector('title', text: full_title('Following')) }
		    it { should have_selector('h3', text: 'Following') }
		    it { should have_link(other_user.name, href: user_path(other_user)) }
		end

		describe "followers" do
			before do
				sign_in other_user
				visit followers_user_path(other_user)
			end

			it { should have_selector('title', text: full_title('Followers')) }
		    it { should have_selector('h3', text: 'Followers') }
		    it { should have_link(user.name, href: user_path(user)) }
		end
	end
end
