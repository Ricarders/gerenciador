# Gerenciador de Conta Corrente

Este é um projeto Rails desenvolvido como parte de um desafio de processo seletivo, implementando um sistema básico de gerenciamento de contas correntes.

## Funcionalidades Implementadas

* Identificação/Login do correntista
* Visualização de Saldo
* Extrato de movimentações
* Operação de Saque (com regras diferenciadas para perfis Normal e VIP, incluindo juros para saldo negativo VIP)
* Operação de Depósito
* Operação de Transferência entre contas (com limites e taxas por perfil)
* Solicitação de visita do gerente (funcionalidade VIP com taxa)
* Troca de usuário (Logout)

## Tecnologias e Versões Utilizadas

* **Ruby:** 3.3.1
* **Rails:** 8.0.2
* **Banco de Dados:** MySQL (ou MariaDB como substituto compatível)
* **Gerenciador de Versões Ruby (recomendado):** rbenv (ou RVM)
* **Runtime JavaScript:** Node.js

## Pré-requisitos

Antes de começar, garanta que você tem o seguinte instalado no seu ambiente de desenvolvimento (recomendamos um ambiente Linux, como o WSL com Fedora ou Ubuntu):

1.  **Ruby** (versão 3.3.1, preferencialmente gerenciado via rbenv ou RVM)
2.  **Bundler** (gem do Ruby: `gem install bundler`)
3.  **Node.js** (versão LTS é recomendada)
4.  **MySQL Server** (versão 8.x) ou **MariaDB Server** (versão 10.x ou superior)
5.  **Git**

## Configuração do Ambiente de Desenvolvimento

1.  **Clone o Repositório (se aplicável, ou copie os arquivos do projeto):**
    ```bash
    # Exemplo se estivesse no Git:
    # git clone URL_DO_REPOSITORIO
    # cd gerenciador
    ```
    (Para este desafio, você provavelmente entregará os arquivos .zip, então esta etapa seria "descompactar o projeto em uma pasta").

2.  **Instale as Dependências do Ruby (Gems):**
    Navegue até a pasta raiz do projeto (`gerenciador`) e execute:
    ```bash
    bundle install
    ```

3.  **Configure o Banco de Dados:**
    * Copie o arquivo de exemplo `config/database.yml.example` para `config/database.yml` (se você fornecer um `.example`). Caso contrário, edite diretamente o `config/database.yml`.
    * No arquivo `config/database.yml`, ajuste as seções `development` e `test` com as suas credenciais de acesso ao MySQL/MariaDB. Você precisará informar:
        * `username`: O usuário que você criou para a aplicação (ex: `ric_rails` ou `gerenciador_user`).
        * `password`: A senha para esse usuário.
        * `host`: Geralmente `localhost` ou `127.0.0.1` se o banco de dados estiver rodando localmente.
        * (Opcional) `socket`: Se o seu MySQL/MariaDB no Linux usar um arquivo de socket para conexões locais, você pode precisar especificá-lo. Ex: `/var/run/mysqld/mysqld.sock`.

    Exemplo para a seção `default` (que `development` e `test` herdam):
    ```yaml
    default: &default
      adapter: mysql2
      encoding: utf8mb4
      pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
      username: SEU_USUARIO_MYSQL # Substitua
      password: SUA_SENHA_MYSQL   # Substitua
      host: localhost
    ```

4.  **Crie os Bancos de Dados:**
    No terminal, na pasta raiz do projeto:
    ```bash
    rails db:create
    ```

5.  **Execute as Migrations:**
    Para criar as tabelas no banco de dados:
    ```bash
    rails db:migrate
    ```

6.  **Popule o Banco com Dados Iniciais (Seeds):**
    Isso criará os correntistas pré-cadastrados para teste:
    ```bash
    rails db:seed
    ```

## Executando a Aplicação

1.  **Inicie o Servidor Rails:**
    No terminal, na pasta raiz do projeto:
    ```bash
    rails server -b 0.0.0.0
    ```
    O `-b 0.0.0.0` é importante se você estiver rodando no WSL para acessar a aplicação do navegador no Windows.

2.  **Acesse no Navegador:**
    Abra seu navegador e vá para: `http://localhost:3000`

## Correntistas Pré-Cadastrados para Teste

Os seguintes correntistas são criados pelo comando `rails db:seed`:

1.  **Correntista Normal:**
    * **Nome:** Cliente Normal da Silva
    * **Número da Conta (Login):** `11111`
    * **Senha:** `1234`
    * **Perfil:** Normal
    * **Saldo Inicial (aproximado):** R$ 1.000,00

2.  **Correntista VIP:**
    * **Nome:** Cliente VIP de Souza
    * **Número da Conta (Login):** `22222`
    * **Senha:** `5678`
    * **Perfil:** VIP
    * **Saldo Inicial (aproximado):** R$ 50.000,00

## Considerações Adicionais (Opcional)

* A lógica de juros para saldo negativo de clientes VIP é calculada de forma *event-driven* (quando ocorrem operações ou visualizações relevantes na conta), como uma simplificação da regra "0.1% por minuto" para o escopo deste desafio.
* A interface do usuário foi estilizada com CSS básico para melhor apresentação.

---

*(Fim do README.md)*
