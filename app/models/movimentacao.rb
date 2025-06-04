class Movimentacao < ApplicationRecord
  belongs_to :conta

  validates :descricao, presence: true
  validates :valor, presence: true, numericality: true
  validates :tipo_transacao, presence: true
end
