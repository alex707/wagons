class AddUserIdToPhonograms < ActiveRecord::Migration[6.1]
  def change
    add_column :phonograms, :user_id, :integer
  end
end
