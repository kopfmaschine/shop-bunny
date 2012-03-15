class IndexToCouponUseCouponIdAndCartId < ActiveRecord::Migration

  def up
    add_index :coupon_uses, [:cart_id, :coupon_id], :unique => true
  end

  def down
    remove_index :coupon_uses, :column => [:cart_id, :coupon_id]
  end
end
