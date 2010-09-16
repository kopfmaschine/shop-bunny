class CartsController < ApplicationController
  respond_to :html
  before_filter :find_cart
  before_filter :find_item, :only => [:add_item, :remove_item]
    
  def show
  end
  
  # TODO Add js responds for add_item and remove_item
  
  def add_item
    @cart.add_item(@item) if @item
    redirect_to @cart
  end
  
  def remove_item
    @cart.remove_item(@item) if @item
    redirect_to @cart
  end
  
  def update
    @cart.update_attributes(params[:cart])
    if @cart.errors.any?
      render :action => 'show'
    else
      # FIXME Don't know why respond_to @cart does not work properly here
      redirect_to @cart
    end
  end
  
  protected

  def find_item
    @item = Item.find(params[:item_id])
  end
  
  # The default behaviour is to map a Cart to a session variable 'cart_id'.
  # You might want to overwrite this method to authorize a user.
  def find_cart
    if session[:cart_id]
      @cart = Cart.find(session[:cart_id])
    else
      @cart = Cart.create
      session[:cart_id] = @cart.id
    end
  end
end
