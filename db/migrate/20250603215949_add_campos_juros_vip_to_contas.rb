class AddCamposJurosVipToContas < ActiveRecord::Migration[8.0]
  def change
    add_column :contas, :inicio_periodo_negativo, :datetime
    add_column :contas, :saldo_base_juros_negativo, :decimal, precision: 18, scale: 2
  end
end
