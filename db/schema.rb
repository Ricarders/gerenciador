# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_03_215949) do
  create_table "contas", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.decimal "saldo", precision: 18, scale: 2, default: "0.0", null: false
    t.bigint "correntista_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "inicio_periodo_negativo"
    t.decimal "saldo_base_juros_negativo", precision: 18, scale: 2
    t.index ["correntista_id"], name: "index_contas_on_correntista_id"
  end

  create_table "correntistas", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "nome", null: false
    t.string "numero_conta", null: false
    t.string "password_digest", null: false
    t.string "perfil", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["numero_conta"], name: "index_correntistas_on_numero_conta", unique: true
  end

  create_table "movimentacoes", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conta_id", null: false
    t.string "descricao", null: false
    t.decimal "valor", precision: 18, scale: 2, null: false
    t.string "tipo_transacao", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conta_id"], name: "index_movimentacoes_on_conta_id"
  end

  add_foreign_key "contas", "correntistas"
  add_foreign_key "movimentacoes", "contas"
end
