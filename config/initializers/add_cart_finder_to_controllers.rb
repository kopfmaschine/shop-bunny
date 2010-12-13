module ActionController
  class Base
    protected
    # The default behaviour is to map a Cart to a session variable 'cart_id'.
    # You might want to overwrite this method to authorize a user.
    # TODO This could result in a mass of empty carts. A Problem?
    def find_cart
      if session[:cart_id]
        begin
          @cart = Cart.find(session[:cart_id])
        rescue ActiveRecord::RecordNotFound => e
          @cart = Cart.create
          session[:cart_id] = @cart.id
        end

      else
        @cart = Cart.create
        session[:cart_id] = @cart.id
      end
    end
    
    def clear_cart
      session[:cart_id] = nil
    end
  end
end
