module ShopBunny
  module CartControllerModule
    def self.included(clazz)
      clazz.send(:respond_to, :html, :json)
      clazz.send(:before_filter, :find_cart)
      clazz.send(:before_filter, :find_item, :only => [:add_item, :remove_item])
    end

    def show
      respond_with @cart
    end

    def add_item
      if !params[:quantity].blank?
        quantity = params[:quantity].to_i
      else
        quantity = 1
      end
      @cart.add_item(@item, :quantity => quantity) if @item
      respond_with @cart do |format|
        format.html { redirect_to cart_path }
      end
    end

    def remove_item
      @cart.remove_item(@item) if @item
      respond_with @cart do |format|
        format.html { redirect_to cart_path }
      end
    end

    def update
      @cart.update_attributes(params[:cart])
      respond_with @cart do |format|
        format.html { 
          if @cart.errors.empty?
            redirect_to after_update_path
        else
          render :show
        end
        }
      end
    end

    private

    def after_update_path
      cart_path
    end

    def find_item
      @item = @cart.item_model.find(params[:item_id])
    end
  end
end      
