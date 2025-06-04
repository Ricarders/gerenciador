class DepositosController < ApplicationController
  before_action :authorize

  def new
  end

  def create
  @correntista = current_correntista
  conta = @correntista.conta
  valor_deposito_str = params[:valor_deposito].to_s.tr(',', '.')
  valor_deposito = BigDecimal(valor_deposito_str) rescue nil

  if valor_deposito.nil? || valor_deposito <= 0
    flash.now[:alert] = "Valor de depósito inválido."
    render :new, status: :unprocessable_entity
    return
  end

  juros_aplicados_nesta_acao = false
  if @correntista.perfil == "VIP" && conta.saldo.negative? && conta.inicio_periodo_negativo.present?
    if conta.aplicar_juros_saldo_negativo_vip!
      juros_aplicados_nesta_acao = true
      conta.reload 
    end
  end

  ActiveRecord::Base.transaction do
    conta.movimentacoes.create!(
      descricao: "Depósito em conta",
      valor: valor_deposito,
      tipo_transacao: "DEPOSITO"
    )
    
    conta.saldo += valor_deposito

    if @correntista.perfil == "VIP"
      if conta.saldo.negative?
        conta.inicio_periodo_negativo = Time.current
        conta.saldo_base_juros_negativo = conta.saldo 
      else
        conta.inicio_periodo_negativo = nil
        conta.saldo_base_juros_negativo = nil
      end
    end

    conta.save!

  end

    flash[:notice] = "Depósito de #{helpers.number_to_currency(valor_deposito, unit: 'R$', separator: ',', delimiter: '.')} realizado com sucesso!"
    redirect_to dashboard_path

  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = "Erro ao processar o depósito: #{e.message}"
    render :new, status: :unprocessable_entity
  rescue StandardError => e
    flash.now[:alert] = "Ocorreu um erro inesperado: #{e.message}"
    render :new, status: :unprocessable_entity
  end
end