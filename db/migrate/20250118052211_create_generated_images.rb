class CreateGeneratedImages < ActiveRecord::Migration[8.0]
  def change
    create_table :generated_images do |t|
      t.text :given_text, null: false, default: ''
      t.text :options, null: false, default: '{}'

      t.timestamps
    end
  end
end
