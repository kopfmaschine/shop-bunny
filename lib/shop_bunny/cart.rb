module ShopBunny
  module Cart
    
    def self.included(clazz)
      clazz.send(:respond_to, :html, :json)
      clazz.send(:before_filter, :find_cart)
      clazz.send(:before_filter, :find_item, :only => [:add_item, :remove_item])
    end

    def show
      respond_with @cart
    end  
    
    def add_item
      @cart.add_item(@item) if @item
      respond_with @cart do |format|
        format.html { redirect_to :action => :show }
      end
    end
    
    def remove_item
      @cart.remove_item(@item) if @item
      respond_with @cart do |format|
        format.html { redirect_to :action => :show }
      end
    end

    def checkout
    end
    
    def update
      @cart.update_attributes(params[:cart])
      respond_with @cart do |format|
        format.html { 
          if @cart.errors.any?
            render 'show' 
          else
            # We have to redirect by hand here, because 
            # url_for(@cart) returns "/cart.x" when cart is a singular resource
            # (see routes.rb). This is a known limitation of Rails.
            # See https://rails.lighthouseapp.com/projects/8994/tickets/4168
            redirect_to :action => :show 
          end
        }
      end
    end
    
    private
    
    def find_item
      @item = @cart.item_model.find(params[:item_id])
    end
  end
end      
