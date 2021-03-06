class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :edit, :update, :destroy]

  def index
    @items = Item.order("created_at DESC")
  end

  def show
    @restaurant = current_restaurant
  end

  def new
    @item = Item.new
    @current_restaurant = current_restaurant
  end

  def edit
    @current_restaurant = Restaurant.where(id: @item.restaurant_id).first
  end

  def create
    @item = Item.new(item_params)
    if @item.save
      @item.update(restaurant_id: current_restaurant.id)
      redirect_to restaurant_name_path(@restaurant.slug), notice: 'Item was successfully created.'
    else
      redirect_to :back, notice: "Price should be a number"
    end
  end

  def update
    @restaurant_id = @item.restaurant_id
    @item.update(item_params)
    @item.update(restaurant_id: @restaurant_id)
    redirect_to @item, notice: 'Item was successfully updated.'
  end

  def destroy
    @item.destroy
    restaurant = Restaurant.where(id: @item.restaurant_id).first
    redirect_to restaurant_name_path(restaurant.slug), notice: "#{@item.title} was deleted from menu"
  end

private

  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:title, :description, :price, :active, :item_categories, :image, :restaurant_id)
  end

  def categories(ids)
    ids.map {|id| Category.find_by_id(id) }.compact
  end

end
