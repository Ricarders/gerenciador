class CreateMovimentacoes < ActiveRecord::Migration[8.0]
  def change
    create_table :movimentacoes do |t|
      t.references :conta, null: false, foreign_key: true
      t.string :descricao, null: false
      t.decimal :valor, precision: 18, scale: 2, null: false
      t.string :tipo_transacao, null:false

      t.timestamps
    end
  end
end
