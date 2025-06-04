class SessionsController < ApplicationController

  # GET /login
  def new
    if current_correntista
      redirect_to root_path_autenticado, notice: "Você já está logado."
    end
  end

# POST /login
  def create
    correntista = Correntista.find_by(numero_conta: params[:session][:numero_conta])
    if correntista && correntista.authenticate(params[:session][:senha])
      # Login bem-sucedido
      session[:correntista_id] = correntista.id
      flash[:notice] = "Login realizado com sucesso!"
      redirect_to root_path_autenticado
    else
      # Falha no login
      flash.now[:alert] = "Número da conta ou senha inválidos."
      render :new, status: :unprocessable_entity
    end
  end


  def destroy
    session[:correntista_id] = nil
    flash[:notice] = "Logout realizado com sucesso."
    redirect_to login_path
  end

  private

  def root_path_autenticado
    dashboard_path # Criar essa rota e controller.
  end

end
