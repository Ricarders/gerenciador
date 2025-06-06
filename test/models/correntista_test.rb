require "test_helper"

class CorrentistaTest < ActiveSupport::TestCase
  setup do
    Correntista.delete_all
  end

  test "deve salvar correntista com todos os campos validos" do
    correntista = Correntista.new(
      nome: "Fulano de Tal",
      numero_conta: "12345",
      perfil: "Normal",
      password: "1234",
      password_confirmation: "1234"
    )
    assert correntista.save, "Não salvou o correntista com dados válidos. Erros: #{correntista.errors.full_messages.join(', ')}"
  end

  test "nao deve salvar correntista sem nome" do
    correntista = Correntista.new(numero_conta: "54321", perfil: "VIP", password: "4321", password_confirmation: "4321")
    assert_not correntista.save
    assert_includes correntista.errors[:nome], "can't be blank"
  end

  test "nao deve salvar correntista sem numero_conta" do
    correntista = Correntista.new(nome: "Beltrano", perfil: "Normal", password: "1111", password_confirmation: "1111")
    assert_not correntista.save
    assert_includes correntista.errors[:numero_conta], "can't be blank"
  end

  test "nao deve salvar correntista com numero_conta duplicado" do
    Correntista.create!(nome: "Sicrano Existente", numero_conta: "98765", perfil: "VIP", password: "9876", password_confirmation: "9876")
    correntista_duplicado = Correntista.new(nome: "Novo Correntista", numero_conta: "98765", perfil: "Normal", password: "0000", password_confirmation: "0000")
    assert_not correntista_duplicado.save
    assert_includes correntista_duplicado.errors[:numero_conta], "has already been taken"
  end

  test "nao deve salvar correntista com numero_conta com menos de 5 digitos" do
    correntista = Correntista.new(nome: "Teste Len", numero_conta: "1234", perfil: "Normal", password: "1234", password_confirmation: "1234")
    assert_not correntista.save
    assert_includes correntista.errors[:numero_conta], "is the wrong length (should be 5 characters)"
  end

  test "nao deve salvar correntista com numero_conta com mais de 5 digitos" do
    correntista = Correntista.new(nome: "Teste Len", numero_conta: "123456", perfil: "Normal", password: "1234", password_confirmation: "1234")
    assert_not correntista.save
    assert_includes correntista.errors[:numero_conta], "is the wrong length (should be 5 characters)"
  end

  test "nao deve salvar correntista com numero_conta contendo letras" do
    correntista = Correntista.new(nome: "Teste Format", numero_conta: "1234a", perfil: "Normal", password: "1234", password_confirmation: "1234")
    assert_not correntista.save
    assert_includes correntista.errors[:numero_conta], "deve conter apenas 5 números"
  end

  test "nao deve salvar correntista com perfil invalido" do
    correntista = Correntista.new(nome: "Perfil Teste", numero_conta: "11223", perfil: "Bronze", password: "2222", password_confirmation: "2222")
    assert_not correntista.save
    assert_includes correntista.errors[:perfil], "Bronze não é um perfil válido (Normal ou VIP)" 
  end

  test "nao deve salvar correntista sem senha na criacao" do
    correntista = Correntista.new(nome: "Sem Senha", numero_conta: "33445", perfil: "Normal")
    assert_not correntista.save, "Salvou correntista sem senha"
    assert_includes correntista.errors[:password], "can't be blank"
  end

  test "nao deve salvar correntista com senha de formato invalido (menos de 4 numeros)" do
    correntista = Correntista.new(nome: "Senha Curta", numero_conta: "44556", perfil: "VIP", password: "123", password_confirmation: "123")
    assert_not correntista.save
    assert_includes correntista.errors[:password], "deve conter 4 dígitos" 
  end

  test "nao deve salvar correntista com senha de formato invalido (mais de 4 numeros)" do
    correntista = Correntista.new(nome: "Senha Longa", numero_conta: "55667", perfil: "VIP", password: "12345", password_confirmation: "12345")
    assert_not correntista.save
    assert_includes correntista.errors[:password], "deve conter 4 dígitos" 
  end

  test "nao deve salvar correntista com senha contendo letras" do
    correntista = Correntista.new(nome: "Senha Letras", numero_conta: "66778", perfil: "VIP", password: "a123", password_confirmation: "a123")
    assert_not correntista.save
    assert_includes correntista.errors[:password], "deve conter 4 dígitos" 
  end

  test "deve ter uma conta associada apos a criacao da conta" do
    correntista = Correntista.create!(
      nome: "Com Conta",
      numero_conta: "77889",
      perfil: "Normal",
      password: "7777",
      password_confirmation: "7777"
    )
    assert_nil correntista.conta
    conta = correntista.build_conta(saldo: 100.0)
    assert conta.save
    correntista.reload
    assert_not_nil correntista.conta
    assert_equal conta, correntista.conta
  end
end
