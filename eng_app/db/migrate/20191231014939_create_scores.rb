class CreateScores < ActiveRecord::Migration[6.0]
  def change
    create_table :scores do |t|
      t.boolean :passed
      t.integer :val
      t.integer :sentence_id
      t.integer :user_id
      t.string  :type

      t.timestamps
    end
  end
end
