require "test_helper"

class ContaTest < ActiveSupport::TestCase
  setup do
    Movimentacao.delete_all
    Conta.delete_all
    Correntista.delete_all 

    @correntista_normal = Correntista.create!(
      nome: "Teste Normal",
      numero_conta: "55555",
      perfil: "Normal",
      password: "1234",
      password_confirmation: "1234"
    )
    @conta_normal = @correntista_normal.create_conta!(saldo: 100.0)

    @correntista_vip = Correntista.create!(
      nome: "Teste VIP",
      numero_conta: "66666", 
      perfil: "VIP",
      password: "5678",
      password_confirmation: "5678"
    )
    @conta_vip = @correntista_vip.create_conta!(saldo: 1000.0)
  end

  test "deve salvar conta valida associada a um correntista" do
    conta = @correntista_normal.build_conta(saldo: 200.00)
    assert conta.save, "Não salvou conta válida. Erros: #{conta.errors.full_messages.join(', ')}"
  end

  test "nao deve salvar conta sem correntista_id" do
    conta = Conta.new(saldo: 100.00)
    assert_not conta.save, "Salvou conta sem correntista_id"
    assert_includes conta.errors[:correntista], "must exist" 
  end

  test "saldo deve ser um numero" do
    @conta_normal.saldo = "abc"
    assert_not @conta_normal.save
    assert_includes @conta_normal.errors[:saldo], "is not a number" 
  end

  test "saldo deve ter valor padrao 0.0 ao criar conta (verificado pela migration)" do
    nova_conta = @correntista_normal.build_conta 
    assert_equal 0.0, Conta.new.saldo, "Saldo não é 0.0 por padrão no objeto Ruby (se não houver default no attribute)"
    conta_sem_saldo_inicial = @correntista_normal.build_conta
    assert conta_sem_saldo_inicial.save
    assert_equal 0.0, conta_sem_saldo_inicial.reload.saldo
  end

  test "aplicar_juros_saldo_negativo_vip! nao deve fazer nada para correntista Normal" do
    @conta_normal.update!(saldo: -50.0, inicio_periodo_negativo: Time.current - 2.minutes, saldo_base_juros_negativo: -50.0)
    saldo_antes = @conta_normal.saldo
    movimentacoes_antes = @conta_normal.movimentacoes.count

    assert_not @conta_normal.aplicar_juros_saldo_negativo_vip!, "Aplicou juros para correntista Normal"
    
    @conta_normal.reload
    assert_equal saldo_antes, @conta_normal.saldo, "Saldo do Normal foi alterado"
    assert_equal movimentacoes_antes, @conta_normal.movimentacoes.count, "Movimentação de juros criada para Normal"
  end

  test "aplicar_juros_saldo_negativo_vip! nao deve fazer nada se saldo VIP for positivo" do
    @conta_vip.update!(saldo: 100.0, inicio_periodo_negativo: Time.current - 2.minutes, saldo_base_juros_negativo: -50.0) 
    saldo_antes = @conta_vip.saldo
    movimentacoes_antes = @conta_vip.movimentacoes.count

    assert_not @conta_vip.aplicar_juros_saldo_negativo_vip!, "Aplicou juros com saldo VIP positivo"
    
    @conta_vip.reload
    assert_equal saldo_antes, @conta_vip.saldo
    assert_equal movimentacoes_antes, @conta_vip.movimentacoes.count
  end

  test "aplicar_juros_saldo_negativo_vip! nao deve fazer nada se inicio_periodo_negativo for nil" do
    @conta_vip.update!(saldo: -100.0, inicio_periodo_negativo: nil, saldo_base_juros_negativo: -100.0)
    saldo_antes = @conta_vip.saldo
    movimentacoes_antes = @conta_vip.movimentacoes.count

    assert_not @conta_vip.aplicar_juros_saldo_negativo_vip!, "Aplicou juros com inicio_periodo_negativo nil"

    @conta_vip.reload
    assert_equal saldo_antes, @conta_vip.saldo
    assert_equal movimentacoes_antes, @conta_vip.movimentacoes.count
  end
  
  test "aplicar_juros_saldo_negativo_vip! nao deve fazer nada se saldo_base_juros_negativo for nil" do
    @conta_vip.update!(saldo: -100.0, inicio_periodo_negativo: Time.current - 2.minutes, saldo_base_juros_negativo: nil)
    saldo_antes = @conta_vip.saldo
    movimentacoes_antes = @conta_vip.movimentacoes.count

    assert_not @conta_vip.aplicar_juros_saldo_negativo_vip!, "Aplicou juros com saldo_base_juros_negativo nil"

    @conta_vip.reload
    assert_equal saldo_antes, @conta_vip.saldo
    assert_equal movimentacoes_antes, @conta_vip.movimentacoes.count
  end

  test "aplicar_juros_saldo_negativo_vip! nao deve aplicar juros se minutos_para_cobrar for zero" do
    @conta_vip.update!(saldo: -100.0, inicio_periodo_negativo: Time.current, saldo_base_juros_negativo: -100.0)
    saldo_antes = @conta_vip.saldo
    movimentacoes_antes = @conta_vip.movimentacoes.count

    assert_not @conta_vip.aplicar_juros_saldo_negativo_vip!, "Aplicou juros com 0 minutos para cobrar"
    
    @conta_vip.reload
    assert_equal saldo_antes, @conta_vip.saldo
    assert_equal movimentacoes_antes, @conta_vip.movimentacoes.count
  end

  test "aplicar_juros_saldo_negativo_vip! deve calcular e aplicar juros corretamente" do
    travel_to Time.current - 10.minutes do 
      @conta_vip.update!(
        saldo: -1000.00,
        inicio_periodo_negativo: Time.current, 
        saldo_base_juros_negativo: -1000.00
      )
    end
    
    saldo_base = @conta_vip.saldo_base_juros_negativo.abs 
    taxa = Conta::TAXA_JUROS_VIP_POR_MINUTO 
    minutos = 10
    juros_esperados = (saldo_base * taxa * minutos).round(2) 

    saldo_esperado_apos_juros = -1000.00 - juros_esperados 
    movimentacoes_antes = @conta_vip.movimentacoes.count
    timestamp_inicio_periodo_antes = @conta_vip.inicio_periodo_negativo
    
    assert @conta_vip.aplicar_juros_saldo_negativo_vip!, "Não retornou true ao aplicar juros"
    
    @conta_vip.reload
    assert_equal saldo_esperado_apos_juros, @conta_vip.saldo.round(2), "Saldo não foi atualizado corretamente com juros"
    assert_equal movimentacoes_antes + 1, @conta_vip.movimentacoes.count, "Não criou movimentação de juros"
    
    movimentacao_juros = @conta_vip.movimentacoes.last
    assert_equal "JUROS_VIP", movimentacao_juros.tipo_transacao
    assert_equal -juros_esperados, movimentacao_juros.valor.round(2)
    assert_includes movimentacao_juros.descricao, "#{minutos} min"

    assert_in_delta Time.current, @conta_vip.inicio_periodo_negativo, 1.second, "inicio_periodo_negativo não foi atualizado"
    assert_equal -1000.00, @conta_vip.saldo_base_juros_negativo, "saldo_base_juros_negativo foi alterado indevidamente pelo método de juros"
  end
end
