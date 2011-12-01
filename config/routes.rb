ShopBunny::Engine.routes.draw do
  resource :cart, :only => [:show, :update] do
    get :add_item, :as => 'add_item_to'
    get :remove_item, :as => 'remove_item_from'
  end
end
