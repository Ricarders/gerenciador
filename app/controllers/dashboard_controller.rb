class DashboardController < ApplicationController
  before_action :authorize

  def index
    @correntista = current_correntista
    if @correntista&.conta
      conta = @correntista.conta
      if conta.correntista.perfil == "VIP" && conta.saldo.negative? && conta.inicio_periodo_negativo.present?
        conta.aplicar_juros_saldo_negativo_vip!
        conta.reload
      end
      @saldo = conta.saldo
    else
      @saldo = "N/A"
    end
  end
end

class ExtratosController < ApplicationController
  before_action :authorize

  def show
    @correntista = current_correntista
    if @correntista&.conta
      conta = @correntista.conta
      if conta.correntista.perfil == "VIP" && conta.saldo.negative? && conta.inicio_periodo_negativo.present?
        conta.aplicar_juros_saldo_negativo_vip!
        conta.reload
      end
      @movimentacoes = conta.movimentacoes.order(created_at: :desc)
    else
      flash[:alert] = "Conta não encontrada."
      redirect_to dashboard_path
      return
    end
  end
end