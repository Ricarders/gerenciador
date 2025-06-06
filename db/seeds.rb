puts "Limpando dados de Correntista e Conta existentes..."
Movimentacao.delete_all 
Conta.delete_all
Correntista.delete_all

puts "Criando correntistas e suas contas..."

# Correntista Normal
correntista_normal = Correntista.create_with(
  password: "1234", 
  password_confirmation: "1234"
).find_or_create_by!(
  nome: "Cliente Normal da Silva",
  numero_conta: "11111", 
  perfil: "Normal"
)

if correntista_normal.persisted? && correntista_normal.conta.nil?
  correntista_normal.create_conta!(saldo: 1000.00) 
  puts "Correntista Normal '#{correntista_normal.nome}' (Conta: #{correntista_normal.numero_conta}) e sua conta criados."
elsif correntista_normal.persisted? && correntista_normal.conta.present?
  puts "Correntista Normal '#{correntista_normal.nome}' já existe com conta."
else
  puts "Erro ao criar Correntista Normal: #{correntista_normal.errors.full_messages.join(', ')}"
end

if correntista_normal&.conta
  conta_normal = correntista_normal.conta
  conta_normal.movimentacoes.destroy_all 
  conta_normal.movimentacoes.create!(
    descricao: "Depósito inicial",
    valor: 1000.00,
    tipo_transacao: "DEPOSITO"
  )
  puts "Movimentação de depósito inicial criada para #{correntista_normal.nome}."
end

# Correntista VIP
correntista_vip = Correntista.create_with(
  password: "5678",
  password_confirmation: "5678"
).find_or_create_by!(
  nome: "Cliente VIP de Souza",
  numero_conta: "22222",
  perfil: "VIP"
)

if correntista_vip.persisted? && correntista_vip.conta.nil?
  correntista_vip.create_conta!(saldo: 50000.00)
  puts "Correntista VIP '#{correntista_vip.nome}' (Conta: #{correntista_vip.numero_conta}) e sua conta criados."
elsif correntista_vip.persisted? && correntista_vip.conta.present?
  puts "Correntista VIP '#{correntista_vip.nome}' já existe com conta."
else
  puts "Erro ao criar Correntista VIP: #{correntista_vip.errors.full_messages.join(', ')}"
end

if correntista_vip&.conta
  conta_vip = correntista_vip.conta
  conta_vip.movimentacoes.destroy_all
  conta_vip.movimentacoes.create!(
    descricao: "Depósito inicial VIP",
    valor: 50000.00,
    tipo_transacao: "DEPOSITO"
  )
  puts "Movimentação de depósito inicial criada para #{correntista_vip.nome}."
end

puts "Seed data finalizado!"