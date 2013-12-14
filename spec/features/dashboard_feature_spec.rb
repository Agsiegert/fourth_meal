require 'spec_helper'

describe "dashboard controller" do 

  it "global admin dashboard shows restaurants" do 
    register_admin_user
    FactoryGirl.create(:restaurant)
    visit '/dashboard'
    expect(page).to have_content("Restaurants by Status")
    expect(page).to have_content("Status")
    expect(page).to have_content("Description")
  end

end