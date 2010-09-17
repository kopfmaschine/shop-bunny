class CartsController < ApplicationController
  respond_to :html
  before_filter :find_cart
  before_filter :find_item, :only => [:add_item, :remove_item]
    
  def show
  end
  
  # TODO Add js responds for add_item and remove_item
  
  def add_item
    @cart.add_item(@item) if @item
    respond_with @cart do |format|
      # We hav to redirect by hand here, because 
      # url_for(@cart) returns "/cart.x" when cart is a singular resource
      # (see routes.rb).
      format.html { redirect_to :action => :show }
    end
  end
  
  def remove_item
    @cart.remove_item(@item) if @item
    respond_with @cart do |format|
      format.html { redirect_to :action => :show }
    end
  end
  
  def update
    @cart.update_attributes(params[:cart])
    respond_with @cart do |format|
      format.html { 
        if @cart.errors.any?
          render 'show' 
        else
          redirect_to :action => :show 
        end
      }
    end
  end
  
  private
  
  def find_item
    @item = @cart.item_model.find(params[:item_id])
  end
  
  # The default behaviour is to map a Cart to a session variable 'cart_id'.
  # You might want to overwrite this method to authorize a user.
  # TODO This could result in a mass of empty carts. A Problem?
  def find_cart
    if session[:cart_id]
      @cart = Cart.find(session[:cart_id])
    else
      @cart = Cart.create
      session[:cart_id] = @cart.id
    end
  end
end
