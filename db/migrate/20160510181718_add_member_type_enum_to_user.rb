class AddMemberTypeEnumToUser < ActiveRecord::Migration
  def change
    create_table :member_types do |t|
      t.string :name
    end
    add_reference :users, :member_type
  end
end
