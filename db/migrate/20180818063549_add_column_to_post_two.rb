class AddColumnToPostTwo < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :user_name, :string
  end
end
