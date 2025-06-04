class CreateContas < ActiveRecord::Migration[8.0]
  def change
    create_table :contas do |t|
      t.decimal :saldo, precision: 18, scale: 2, null: false, default: 0.0
      t.references :correntista, null: false, foreign_key: true

      t.timestamps
    end
  end
end
