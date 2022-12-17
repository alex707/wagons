class CreatePhonograms < ActiveRecord::Migration[6.1]
  def change
    create_table :phonograms do |t|
      t.jsonb :data

      t.timestamps
    end
  end
end
