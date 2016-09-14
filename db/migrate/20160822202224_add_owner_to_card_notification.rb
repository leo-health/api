class AddOwnerToCardNotification < ActiveRecord::Migration
  def change
    add_reference :card_notifications, :owner, polymorphic: true
  end
end
