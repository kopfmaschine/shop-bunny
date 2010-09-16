class CartsController < ApplicationController
  respond_to :html
  before_filter :find_cart
    
  def show
  end
  
  def update
    # FIXME Think about API.
    Array(params[:add_items]).each { |item_id|      
      @cart.add_item(item_id)
    }
    Array(params[:remove_items]).each { |item_id|      
      @cart.remove_item(item_id)
    }
    respond_with @cart
  end
  
  protected
  
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
