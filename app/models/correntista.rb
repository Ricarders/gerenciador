class Correntista < ApplicationRecord
  has_secure_password 
  has_one :conta, dependent: :destroy

  validates :nome, presence: { message: "can't be blank" } 

  validates :numero_conta,
            presence: { message: "can't be blank" }, 
            uniqueness: { message: "has already been taken" },
            length: { is: 5, message: "is the wrong length (should be 5 characters)" }, 
            format: { with: /\A\d{5}\z/, message: "deve conter apenas 5 números" }

  validates :perfil,
            presence: { message: "can't be blank" }, 
            inclusion: { in: %w(Normal VIP), message: "%{value} não é um perfil válido (Normal ou VIP)" }

  validates :password,
            format: { with: /\A\d{4}\z/, message: "deve conter 4 dígitos" },
            allow_nil: true, 
            if: -> { password.present? } 
                                         
end