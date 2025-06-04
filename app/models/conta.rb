class Conta < ApplicationRecord
  belongs_to :correntista
  has_many :movimentacoes, dependent: :destroy

  validates :saldo, presence: true, numericality: true

  TAXA_JUROS_VIP_POR_MINUTO = 0.001

  def aplicar_juros_saldo_negativo_vip!
    return false unless correntista.perfil == "VIP" && 
                        saldo.negative? && 
                        inicio_periodo_negativo.present? && 
                        saldo_base_juros_negativo.present?

    minutos_para_cobrar = ((Time.current - self.inicio_periodo_negativo) / 60).floor
    juros_foram_aplicados = false

    if minutos_para_cobrar > 0
      juros_devidos = (self.saldo_base_juros_negativo.abs * TAXA_JUROS_VIP_POR_MINUTO) * minutos_para_cobrar
      juros_devidos_arredondado = juros_devidos.round(2)

      if juros_devidos_arredondado > 0 
        ActiveRecord::Base.transaction do
          self.saldo -= juros_devidos_arredondado
          
          movimentacoes.create!(
            descricao: "Juros s/ saldo negativo VIP (#{minutos_para_cobrar} min ref. base R$ #{self.saldo_base_juros_negativo.abs.round(2)})",
            valor: -juros_devidos_arredondado,
            tipo_transacao: "JUROS_VIP"
          )
          
        
          self.inicio_periodo_negativo = Time.current
          save!
          juros_foram_aplicados = true
          Rails.logger.info "JUROS: #{helpers.number_to_currency(juros_devidos_arredondado)} aplicados à conta #{id}. Novo início período: #{self.inicio_periodo_negativo}"
        end
      end
    end
    juros_foram_aplicados
  end

  private

  def helpers
    ActionController::Base.helpers
  end
end