    class Cart < ActiveRecord::Base
  has_many :cart_items
  
  validates_presence_of :owner_id
  
  def items
    self.cart_items
  end
  
  def item_count
    self.cart_items.inject(0) {|sum,e| sum += e.quantity}
  end

  def item_sum
    self.cart_items.inject(0) {|sum,e| sum += e.quantity*e.quantity.article.price}
  end

  #increases the quantity of an article. creates a new one if it doesn't exist
  def add(options)
    article = self.cart_items.find_or_create_by_article_id(options[:article_id])
    article.quantity += options[:quantity]
    article.save!
    self.reload
    article
  end
  
  #removes a quantity of an article specified by :article_id, returns nil if no article has been found
  def remove(options)
    article = self.cart_items.find_by_article_id(options[:article_id])
    if article
      article.quantity -= options[:quantity]
      article.quantity = 0 if article.quantity < 0
      article.save!
      self.reload
    end
    article
  end

  #sets the quantity of an article specified by :article_id, returns nil if no article has been found
  def set(options)
     article = self.cart_items.find_by_article_id(options[:article_id])
    if article
      article.quantity = options[:quantity]
      article.save!
      self.reload
    end
    article
  end
end
