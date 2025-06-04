class Correntista < ApplicationRecord
    has_secure_password
    has_one :conta, dependent: :destroy

    validates :nome, presence: true
    validates :numero_conta, presence: true,
                           uniqueness: true,
                           length: { is: 5 },
                           format: { with: /\A\d{5}\z/, message: "deve conter apenas 5 números" }
    validates :perfil, presence: true, inclusion: {in:  %w(Normal VIP), message: "%{value} não é um perfil válido (Normal ou VIP)" }
    validates :password, format: { with: /\A\d{4}\z/, message: "deve conter 4 dígitos" }, if: -> { new_record? || !password.nil? }
end
