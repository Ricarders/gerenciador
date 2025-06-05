class SaquesController < ApplicationController
  before_action :authorize

  def new
    @correntista = current_correntista
    if @correntista&.conta
      conta = @correntista.conta
      if conta.correntista.perfil == "VIP" && conta.saldo.negative? && conta.inicio_periodo_negativo.present?
        conta.aplicar_juros_saldo_negativo_vip!
        conta.reload
      end
      @saldo_atual = conta.saldo
    else
      @saldo_atual = 0 
    end
  end

  def create
    @correntista = current_correntista
    unless @correntista && @correntista.conta
      flash.now[:alert] = "Correntista ou conta não encontrados."
      @saldo_atual = 0 
      render :new, status: :unprocessable_entity
      return
    end
    conta = @correntista.conta

    valor_saque_str = params[:valor_saque].to_s.tr(',', '.')
    valor_saque = BigDecimal(valor_saque_str) rescue nil

    # Valida o valor do saque
    if valor_saque.nil? || valor_saque <= 0
      flash.now[:alert] = "Valor de saque inválido."
      @saldo_atual = conta.saldo
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

    if @correntista.perfil == "Normal" && valor_saque > conta.saldo
      flash.now[:alert] = "Saldo insuficiente para realizar este saque."
      @saldo_atual = conta.saldo 
      render :new, status: :unprocessable_entity
      return
    end

    begin
      ActiveRecord::Base.transaction do
        conta.movimentacoes.create!(
          descricao: "Saque em conta",
          valor: -valor_saque.abs,
          tipo_transacao: "SAQUE"
        )

        conta.saldo -= valor_saque

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

      flash[:notice] = "Saque de #{helpers.number_to_currency(valor_saque, unit: 'R$', separator: ',', delimiter: '.')} realizado com sucesso!"
      redirect_to dashboard_path

    rescue ActiveRecord::RecordInvalid => e
      flash.now[:alert] = "Erro ao processar o saque: #{e.message}"
      @saldo_atual = @correntista&.conta&.reload&.saldo
      render :new, status: :unprocessable_entity
    rescue StandardError => e
      flash.now[:alert] = "Ocorreu um erro inesperado: #{e.message}"
      @saldo_atual = @correntista&.conta&.reload&.saldo
      render :new, status: :unprocessable_entity
    end
  end

end
