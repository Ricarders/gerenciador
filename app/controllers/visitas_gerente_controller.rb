class VisitasGerenteController < ApplicationController
  before_action :authorize
  before_action :verificar_perfil_vip
  before_action :set_correntista_e_conta, only: [:new, :create]

  TAXA_VISITA_GERENTE = 50.00

  def new
    @taxa_visita = TAXA_VISITA_GERENTE
    @saldo_atual = @conta.saldo
  end

  def create
    if @conta.saldo.negative? && @conta.inicio_periodo_negativo.present?
      if @conta.aplicar_juros_saldo_negativo_vip!
        @conta.reload
      end
    end

    begin
      ActiveRecord::Base.transaction do
        @conta.saldo -= TAXA_VISITA_GERENTE

        @conta.movimentacoes.create!(
          descricao: "Taxa por solicitação de visita do gerente",
          valor: -TAXA_VISITA_GERENTE,
          tipo_transacao: "TAXA_VISITA_GERENTE"
        )

        if @conta.saldo.negative?
          if @conta.inicio_periodo_negativo.nil? 
            @conta.inicio_periodo_negativo = Time.current
            @conta.saldo_base_juros_negativo = @conta.saldo
          else
            @conta.inicio_periodo_negativo = Time.current
          end
        else
          @conta.inicio_periodo_negativo = nil
          @conta.saldo_base_juros_negativo = nil
        end
        @conta.save!
      end 

      flash[:notice] = "Solicitação de visita do gerente confirmada. Uma taxa de #{helpers.number_to_currency(TAXA_VISITA_GERENTE)} foi debitada."
      redirect_to dashboard_path

    rescue ActiveRecord::RecordInvalid => e
      flash.now[:alert] = "Erro ao processar a solicitação: #{e.message}"
      @taxa_visita = TAXA_VISITA_GERENTE 
      @saldo_atual = @conta&.reload&.saldo
      render :new, status: :unprocessable_entity
    rescue StandardError => e
      Rails.logger.error "Erro inesperado na solicitação de visita: #{e.message} \n#{e.backtrace.join("\n")}"
      flash.now[:alert] = "Ocorreu um erro inesperado."
      @taxa_visita = TAXA_VISITA_GERENTE
      @saldo_atual = @conta&.reload&.saldo
      render :new, status: :unprocessable_entity
    end
  end

  private

  def verificar_perfil_vip
    unless current_correntista&.perfil == "VIP"
      flash[:alert] = "Esta funcionalidade está disponível apenas para clientes VIP."
      redirect_to dashboard_path 
    end
  end

  def set_correntista_e_conta
    @correntista = current_correntista
    unless @correntista && @correntista.conta
      flash[:alert] = "Sua conta não foi encontrada. Por favor, faça login novamente."
      redirect_to login_path
      return
    end
    @conta = @correntista.conta
  end
end