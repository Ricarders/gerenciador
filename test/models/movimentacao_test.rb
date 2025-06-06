require "test_helper"

class MovimentacaoTest < ActiveSupport::TestCase
  setup do
    Movimentacao.delete_all
    Conta.delete_all
    Correntista.delete_all

    @correntista = Correntista.create!(
      nome: "Correntista Para Movimentacao",
      numero_conta: "77777",
      perfil: "Normal",
      password: "3333",
      password_confirmation: "3333"
    )
    @conta = @correntista.create_conta!(saldo: 500.00)
  end

  test "deve salvar movimentacao valida" do
    movimentacao = @conta.movimentacoes.build(
      descricao: "Compra no mercado",
      valor: -50.75,
      tipo_transacao: "COMPRA_DEBITO"
    )
    assert movimentacao.save, "Não salvou movimentação válida. Erros: #{movimentacao.errors.full_messages.join(', ')}"
  end

  test "nao deve salvar movimentacao sem conta associada" do
    movimentacao = Movimentacao.new(
      descricao: "Movimentacao Solta",
      valor: 10.00,
      tipo_transacao: "TESTE"
    )
    assert_not movimentacao.save, "Salvou movimentação sem conta_id"
    assert_includes movimentacao.errors[:conta], "must exist" 
  end

  test "nao deve salvar movimentacao sem descricao" do
    movimentacao = @conta.movimentacoes.build(
      valor: 100.00,
      tipo_transacao: "DEPOSITO"
    )
    assert_not movimentacao.save, "Salvou movimentação sem descrição"
    assert_includes movimentacao.errors[:descricao], "can't be blank"
  end

  test "nao deve salvar movimentacao sem valor" do
    movimentacao = @conta.movimentacoes.build(
      descricao: "Pagamento de conta",
      tipo_transacao: "PAGAMENTO"
    )
    assert_not movimentacao.save, "Salvou movimentação sem valor"
    assert_includes movimentacao.errors[:valor], "can't be blank"
  end

  test "valor da movimentacao deve ser numerico" do
    movimentacao = @conta.movimentacoes.build(
      descricao: "Teste valor não numérico",
      valor: "abc",
      tipo_transacao: "TESTE_VALOR"
    )
    assert_not movimentacao.save, "Salvou movimentação com valor não numérico"
    assert_includes movimentacao.errors[:valor], "is not a number"
  end

  test "nao deve salvar movimentacao sem tipo_transacao" do
    movimentacao = @conta.movimentacoes.build(
      descricao: "Alguma movimentação",
      valor: -25.00
    )
    assert_not movimentacao.save, "Salvou movimentação sem tipo_transacao"
    assert_includes movimentacao.errors[:tipo_transacao], "can't be blank"
  end

  test "deve pertencer a uma conta" do
    movimentacao = Movimentacao.new
    assert_respond_to movimentacao, :conta, "Movimentacao não responde a :conta (associação belongs_to)"
  end

  test "deve ter created_at definido apos salvar" do
    movimentacao = @conta.movimentacoes.create(
      descricao: "Teste created_at",
      valor: 1.00,
      tipo_transacao: "TESTE_DATA"
    )
    assert_not_nil movimentacao.created_at, "created_at não foi definido"
  end
end
