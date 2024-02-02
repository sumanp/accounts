class CreateUser < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password, null: false
      t.boolean :two_factor_enabled, default: false
      t.string :secret_key

      t.timestamps
    end
  end
end
