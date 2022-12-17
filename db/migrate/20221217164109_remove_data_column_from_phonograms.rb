class RemoveDataColumnFromPhonograms < ActiveRecord::Migration[6.1]
  def change
    remove_column :phonograms, :data

    add_column :phonograms, :parsed_text, :text
  end
end
