class RestaurantsController < ApplicationController
  before_action :create_and_log_in_guest_user, only: [:show]

  def index
    @restaurants = Restaurant.where(status: "active").page(params[:page]).per(9)
    @current_user = current_user
    @regions = Region.all
  end

  def create
    @restaurant            = Restaurant.new(restaurant_params)
    @user                  = current_user
    @platform_admin        = platform_admin
    @restaurant.creator_id = @user.id
    if @restaurant.save
      create_job(@user.id, @restaurant.id)
      UserMailer.new_restaurant_submission_confirmation(@user, @restaurant).deliver
      UserMailer.new_restaurant_submission_notification(@platform_admin, @user, @restaurant).deliver
      redirect_to '/', notice: 'Restaurant is submitted and pending approval'
    else
      render action: 'new'
    end
  end

   def update
    @restaurant = Restaurant.where(id: params[:id]).first
    @user = User.where(id: @restaurant.creator_id).first
    respond_to do |format|
      if @restaurant.update(restaurant_params)
        if @restaurant.status == "approved" && !@restaurant.jobs.empty?
          @restaurant.jobs.first.update(role: "Admin")
          job = Job.where(restaurant_id: @restaurant.id).first
          @user.update(job_id: job.id)
          UserMailer.new_restaurant_approval(@user, @restaurant).deliver
          format.html { redirect_to :back }
        end
          format.html { redirect_to :back }
      else
        format.html { redirect_to :back }
      end
    end
  end

  def destroy
    @restaurant = Restaurant.where(id: params[:id]).first
    @restaurant.destroy
      redirect_to dashboard_path, notice: "#{@restaurant.title} was deleted from FoodFight"
  end

  def create_job(user_id, restaurant_id)
    Job.create(user_id: user_id, restaurant_id: restaurant_id)
  end

  def new
    @restaurant = Restaurant.new
    @regions = Region.all
  end

  def show
    @current_order = current_restaurant.orders.find_unsubmitted_order_for(@current_user, current_restaurant.id)
    @current_restaurant = current_restaurant
  end

  def details
    @restaurant = current_restaurant
  end

  def admin_restaurants
    @restaurants = current_user.my_restaurants
  end

  def approve
    @user = User.where(id: current_restaurant.creator_id).first
    current_restaurant.approve
    pending_restaurant_job.update(role: "Admin")
    UserMailer.new_restaurant_approval(@user, @restaurant).deliver
    redirect_to '/dashboard'
  end

  def activate
    current_restaurant.activate
    redirect_to :back
  end


  def reject
    current_restaurant.reject
    redirect_to '/dashboard'
  end

private

  def restaurant_params
    params.require(:restaurant).permit(:title, :description, :id, :status, :region_id, :image)
  end

  def pending_restaurant_job
    creator_id = current_restaurant.creator_id
    current_restaurant.jobs.first
  end

end
