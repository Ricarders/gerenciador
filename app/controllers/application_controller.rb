class ApplicationController < ActionController::Base
  helper_method :current_correntista, :logged_in?

  private

  def current_correntista
    @current_correntista ||= Correntista.find_by(id: session[:correntista_id]) if session[:correntista_id]
  end

  def logged_in?
    !!current_correntista
  end

  def authorize
    unless logged_in?
      flash[:alert] = "Você precisa estar logado para acessar esta página."
      redirect_to login_path
    end
  end
end
