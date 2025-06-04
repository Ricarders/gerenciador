class CreateCorrentistas < ActiveRecord::Migration[8.0]
  def change
    create_table :correntistas do |t|
      t.string :nome, null: false
      t.string :numero_conta, null: false
      t.string :password_digest, null: false
      t.string :perfil, null: false

      t.timestamps
    end
    add_index :correntistas, :numero_conta, unique: true
  end
end
