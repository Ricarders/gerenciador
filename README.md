# Gerenciador de Conta Corrente

Este é um projeto Rails desenvolvido por Ricardo Silva como parte de um desafio de processo seletivo, implementando um sistema básico de gerenciamento de contas correntes.

**Aplicação Online:** https://gerenciador-bancario.onrender.com/
> **Nota Importante sobre a Aplicação Online:**
> O projeto está hospedado no plano gratuito do Render.com. Isso significa que o serviço "hiberna" após 15 minutos de inatividade. **A primeira visita à aplicação pode demorar alguns minutos para carregar** enquanto o servidor "acorda". Após o carregamento inicial, a navegação será rápida.

---

## Funcionalidades Implementadas

* Identificação/Login do correntista.
* Visualização de Saldo.
* Extrato detalhado de movimentações (data/hora, descrição, valor).
* Operação de Saque com regras específicas:
    * Correntista Normal: não pode sacar além do saldo.
    * Correntista VIP: pode sacar e ficar com saldo negativo.
    * Lógica de juros para saldo negativo VIP (0.1% por minuto sobre o saldo base negativo).
* Operação de Depósito.
* Operação de Transferência entre contas:
    * Limite de R$1000,00 e taxa de R$8,00 para perfil Normal.
    * Sem limite de valor e taxa de 0,8% para perfil VIP.
    * Registo nos extratos de origem e destino, incluindo taxas.
* Solicitação de visita do gerente (funcionalidade exclusiva para VIPs, com taxa de R$50,00).
* Troca de usuário (Logout).
* Interface web com CSS básico para melhor apresentação.
* Testes unitários para os modelos.

## Tecnologias e Versões Utilizadas

* **Ruby:** 3.3.1
* **Rails:** 8.0.2
* **Banco de Dados (Desenvolvimento):** MySQL (ou MariaDB como substituto compatível)
* **Banco de Dados (Produção):** PostgreSQL (no Render.com)
* **Gerenciador de Versões Ruby (recomendado):** rbenv (ou RVM)
* **Runtime JavaScript:** Node.js
* **Ambiente de Desenvolvimento:** Linux (WSL)

## Pré-requisitos (Ambiente de Desenvolvimento Local)

Antes de começar, garanta que você tem o seguinte instalado no seu ambiente (ambiente Linux recomendado):

1.  **Ruby** 3.3.1 (gerenciado via rbenv é o ideal).
2.  **Bundler** (`gem install bundler`).
3.  **Node.js** (versão LTS).
4.  **Servidor MySQL** (8.x) ou **MariaDB** (10.x+).
5.  **Git**.
6.  **Bibliotecas de desenvolvimento para MySQL/MariaDB**.

## Configuração do Ambiente de Desenvolvimento Local

1.  **Clone o Repositório ou Descompacte os Arquivos:**

2.  **Navegue até a Pasta do Projeto:**
    ```bash
    cd gerenciador
    ```

3.  **Instale as Dependências do Ruby (Gems):**
    ```bash
    bundle install
    ```

4.  **Configure o Banco de Dados (`config/database.yml`):**
    * Edite o arquivo `config/database.yml`.
    * Na seção `default:` (ou `development:`), ajuste `username` e `password` com as suas credenciais de acesso ao MySQL/MariaDB local.
    * Exemplo:
        ```yaml
        default: &default
          adapter: mysql2
          encoding: utf8mb4
          pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
          username: *COLOQUE AQUI SEU USUÁRIO LOCAL*
          password: *COLOQUE AQUI SUA SENHA*
          host: localhost
        ```

5.  **Crie os Bancos de Dados de Desenvolvimento e Teste:**
    ```bash
    rails db:create
    ```

6.  **Execute as Migrations:**
    ```bash
    rails db:migrate
    ```

7.  **Popule o Banco com Dados Iniciais (Seeds):**
    ```bash
    rails db:seed
    ```

## Executando a Aplicação Localmente

1.  **Inicie o Servidor Rails:**
    ```bash
    rails server -b 0.0.0.0
    ```

2.  **Acesse no Navegador:**
    Abra seu navegador e vá para: `http://localhost:3000`

## Correntistas Pré-Cadastrados para Teste (Criados pelo `db:seed`)

1.  **Correntista Normal:**
    * **Nome:** Cliente Normal da Silva
    * **Número da Conta (Login):** `11111`
    * **Senha:** `1234`
    * **Perfil:** Normal
    * **Saldo Inicial:** R$ 1.000,00

2.  **Correntista VIP:**
    * **Nome:** Cliente VIP de Souza
    * **Número da Conta (Login):** `22222`
    * **Senha:** `5678`
    * **Perfil:** VIP
    * **Saldo Inicial:** R$ 50.000,00

## Sobre a Lógica de Juros

A lógica de juros para saldo negativo de clientes VIP é calculada de forma *event-driven* (quando ocorrem operações ou visualizações relevantes na conta), para que não seja necessário um novo cálculo de juros a cada minuto. O saldo base para cálculo de juros é atualizado após operações de saque ou depósito que alterem o montante da dívida.
