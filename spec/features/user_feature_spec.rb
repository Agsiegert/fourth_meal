require 'spec_helper'

describe "the signup process", :type => :feature do

  it "signs me up after I click become a member" do
    visit '/sign_up'
    fill_in 'user_email',                 :with => "bj@example.com"
    fill_in 'user_full_name',             :with => "Bo Jangles"
    fill_in 'user_display_name',          :with => "BJ"
    fill_in 'user_password',              :with => "foobarbaz"
    fill_in 'user_password_confirmation', :with => "foobarbaz"
    click_link_or_button 'Create User'
    expect(page).to have_content 'Signed up!'
  end

end

describe "the signin process" do
  before :each do
    register_user
  end

  xit "logs me in" do
    within("#flash_notice") do
      expect(page).to have_content 'Logged in'
    end
  end

  xit "logs me out" do
    visit '/items'
    click_link_or_button 'Log Out'
    expect(page).to have_content 'Logged out'
    expect(page).to have_content 'Log In'
  end

end

describe "guest user" do

  xit "cannot edit item" do
    item = make_an_item_via_db
    visit edit_item_path(item)
    page.should have_content("Not authorized")
  end

end

describe "member" do

  xit "cannot edit item" do
    item = make_an_item_via_db
    register_user
    visit edit_item_path(item)
    page.should have_content("Not authorized")
  end

  xit "can edit her own user details" do
    register_changeable_user
    visit '/items'
    click_on 'My profile'
    fill_in 'user_email', :with => "adminOne@example.com"
    click_link_or_button 'Update User'
    page.status_code.should eql(200)
    within('.navbar') do
      page.should have_content('conf')
    end
  end

end

describe "admin user" do

  it "can edit an item" do
    item = make_an_item_via_db
    register_admin_user
    visit edit_item_path(item)
    page.should_not have_content("Not authorized")
  end

end


