class ExtratosController < ApplicationController
  before_action :authorize

  def show
    @correntista = current_correntista
    if @correntista&.conta
      @movimentacoes = @correntista.conta.movimentacoes.order(created_at: :desc)
    else
      flash[:alert] = "Conta não encontrada."
      redirect_to dashboard_path
      return
    end
  end
end
