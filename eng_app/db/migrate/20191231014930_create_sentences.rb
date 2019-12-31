class CreateSentences < ActiveRecord::Migration[6.0]
  def change
    create_table :sentences do |t|
      t.integer :no
      t.string :en
      t.string :jp
      t.string :voice_data

      t.timestamps
    end
  end
end
