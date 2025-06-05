class TransferenciasController < ApplicationController
  before_action :authorize
  before_action :set_correntista_e_conta_remetente, only: [:new, :create]

  def new
    @saldo_atual = @conta_remetente&.saldo
  end

  def create
    numero_conta_destino = params[:numero_conta_destino]
    valor_transferencia_str = params[:valor_transferencia].to_s.tr(',', '.')
    valor_transferencia = BigDecimal(valor_transferencia_str) rescue nil

    if valor_transferencia.nil? || valor_transferencia <= 0
      flash.now[:alert] = "Valor de transferência inválido."
      render_new_com_saldo_e_status
      return
    end

    if numero_conta_destino.blank? || numero_conta_destino.length != 5 || !numero_conta_destino.match?(/\A\d{5}\z/)
      flash.now[:alert] = "Número da conta de destino inválido. Deve conter 5 números."
      render_new_com_saldo_e_status
      return
    end

    if @correntista_remetente.numero_conta == numero_conta_destino
      flash.now[:alert] = "Você não pode transferir para sua própria conta."
      render_new_com_saldo_e_status
      return
    end

    correntista_destino = Correntista.find_by(numero_conta: numero_conta_destino)
    unless correntista_destino && correntista_destino.conta
      flash.now[:alert] = "Conta de destino não encontrada."
      render_new_com_saldo_e_status
      return
    end
    conta_destino = correntista_destino.conta

    if @correntista_remetente.perfil == "VIP" && @conta_remetente.saldo.negative? && @conta_remetente.inicio_periodo_negativo.present?
      if @conta_remetente.aplicar_juros_saldo_negativo_vip!
        @conta_remetente.reload
      end
    end

    taxa_transferencia = calcular_taxa_transferencia(@correntista_remetente, valor_transferencia)
    valor_total_debito = valor_transferencia + taxa_transferencia

    if @correntista_remetente.perfil == "Normal"
      if valor_transferencia > 1000.00
        flash.now[:alert] = "Transferência excede o limite de R$ 1.000,00 para seu perfil."
        render_new_com_saldo_e_status
        return
      end
      if valor_total_debito > @conta_remetente.saldo
        flash.now[:alert] = "Saldo insuficiente para realizar esta transferência (R$ #{helpers.number_to_currency(valor_transferencia)} + taxa R$ #{helpers.number_to_currency(taxa_transferencia)})."
        render_new_com_saldo_e_status
        return
      end
    elsif @correntista_remetente.perfil == "VIP"
      
    end

    begin
      ActiveRecord::Base.transaction do
        @conta_remetente.saldo -= valor_transferencia
        @conta_remetente.movimentacoes.create!(
          descricao: "Transferência enviada para conta #{numero_conta_destino}",
          valor: -valor_transferencia,
          tipo_transacao: "TRANSFERENCIA_ENVIADA"
        )

        @conta_remetente.saldo -= taxa_transferencia
        @conta_remetente.movimentacoes.create!(
          descricao: "Taxa de transferência para conta #{numero_conta_destino}",
          valor: -taxa_transferencia,
          tipo_transacao: "TAXA_TRANSFERENCIA"
        )

        if @correntista_remetente.perfil == "VIP"
          if @conta_remetente.saldo.negative?
            if @conta_remetente.inicio_periodo_negativo.nil?
              @conta_remetente.inicio_periodo_negativo = Time.current
              @conta_remetente.saldo_base_juros_negativo = @conta_remetente.saldo
            end
          else
            @conta_remetente.inicio_periodo_negativo = nil
            @conta_remetente.saldo_base_juros_negativo = nil
          end
        end
        @conta_remetente.save!

        conta_destino.saldo += valor_transferencia
        conta_destino.movimentacoes.create!(
          descricao: "Transferência recebida da conta #{@correntista_remetente.numero_conta}",
          valor: valor_transferencia,
          tipo_transacao: "TRANSFERENCIA_RECEBIDA"
        )

        if correntista_destino.perfil == "VIP" && conta_destino.saldo >= 0 && conta_destino.inicio_periodo_negativo.present?
          conta_destino.inicio_periodo_negativo = nil
          conta_destino.saldo_base_juros_negativo = nil
        end
        conta_destino.save!
      end

      flash[:notice] = "Transferência de #{helpers.number_to_currency(valor_transferencia)} para a conta #{numero_conta_destino} realizada com sucesso. Taxa: #{helpers.number_to_currency(taxa_transferencia)}."
      redirect_to dashboard_path

    rescue ActiveRecord::RecordInvalid => e
      flash.now[:alert] = "Erro ao processar a transferência: #{e.message}"
      render_new_com_saldo_e_status
    rescue StandardError => e
      Rails.logger.error "Erro inesperado na transferência: #{e.message} \n#{e.backtrace.join("\n")}"
      flash.now[:alert] = "Ocorreu um erro inesperado ao processar a transferência."
      render_new_com_saldo_e_status
    end
  end

  private

  def set_correntista_e_conta_remetente
    @correntista_remetente = current_correntista
    unless @correntista_remetente && @correntista_remetente.conta
      flash[:alert] = "Sua conta não foi encontrada. Por favor, faça login novamente."
      redirect_to login_path
      return
    end
    @conta_remetente = @correntista_remetente.conta
  end

  def calcular_taxa_transferencia(correntista, valor_transferencia)
    if correntista.perfil == "Normal"
      8.00
    elsif correntista.perfil == "VIP"
      (valor_transferencia * 0.008).round(2)
    else
      flash.now[:alert] = "Perfil desconhecido, tente novamente"
      0.00
    end
  end

  def render_new_com_saldo_e_status
    @saldo_atual = @conta_remetente&.reload&.saldo
    render :new, status: :unprocessable_entity
  end
end