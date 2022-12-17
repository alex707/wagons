class AddStatusToPhonogram < ActiveRecord::Migration[6.1]
  def change
    add_column :phonograms, :status, :integer
    add_column :phonograms, :task_uuid, :string
  end
end
