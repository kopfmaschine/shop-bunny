class CreateCouponUses < ActiveRecord::Migration
  def self.up
    create_table :coupon_uses do |t|
      t.integer :cart_id
      t.integer :coupon_id

      t.timestamps
    end
  end

  def self.down
    drop_table :coupon_uses
  end
end
