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

ActiveRecord::Schema[8.1].define(version: 2026_01_08_150534) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.bigint "author_id"
    t.string "author_type"
    t.text "body"
    t.datetime "created_at", null: false
    t.string "namespace"
    t.bigint "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "fund_load_restrictions_customers", primary_key: "uuid", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "ext_customer_id", null: false
    t.datetime "updated_at", null: false
    t.index ["ext_customer_id"], name: "idx_flr_customers_ext_customer_id", unique: true
  end

  create_table "fund_load_restrictions_rules", force: :cascade do |t|
    t.jsonb "config", default: {}, null: false
    t.datetime "created_at", null: false
    t.boolean "enabled", default: true, null: false
    t.string "name", null: false
    t.string "rule_type", null: false
    t.datetime "updated_at", null: false
    t.index ["enabled"], name: "idx_flr_rules_enabled"
    t.index ["rule_type"], name: "idx_flr_rules_type"
  end

  create_table "fund_load_restrictions_sanctions", primary_key: "uuid", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.jsonb "config", default: {}, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "sanction_type", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "idx_flr_sanctions_active"
    t.index ["name"], name: "idx_flr_sanctions_name", unique: true
    t.index ["sanction_type"], name: "idx_flr_sanctions_type"
  end

  create_table "fund_load_restrictions_submission_sanction_results", primary_key: "uuid", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "sanction_id", null: false
    t.uuid "submission_id", null: false
    t.datetime "updated_at", null: false
    t.index ["sanction_id"], name: "idx_flr_submission_sanction_results_sanction_id"
    t.index ["submission_id", "sanction_id"], name: "idx_flr_submission_sanction_results_unique", unique: true
    t.index ["submission_id"], name: "idx_flr_submission_sanction_results_submission_id"
  end

  create_table "fund_load_restrictions_submission_velocity_limit_results", primary_key: "uuid", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "accepted", default: false, null: false
    t.datetime "created_at", null: false
    t.string "decline_reason"
    t.uuid "rule_id", null: false
    t.uuid "submission_id", null: false
    t.datetime "updated_at", null: false
    t.index ["rule_id"], name: "idx_flr_vel_results_rule_id"
    t.index ["submission_id", "rule_id"], name: "idx_flr_vel_results_unique", unique: true
    t.index ["submission_id"], name: "idx_flr_vel_results_submission_id"
  end

  create_table "fund_load_restrictions_submissions", primary_key: "uuid", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "accepted", default: false, null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "USD", null: false
    t.uuid "customer_id", null: false
    t.integer "load_amount_cents", default: 0, null: false
    t.datetime "load_datetime", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "idx_flr_submissions_customer_uuid"
  end

  create_table "fund_load_restrictions_velocity_limit_rules", primary_key: "uuid", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.jsonb "config", default: {}, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "idx_flr_velocity_limit_rules_active"
    t.index ["name"], name: "idx_flr_velocity_limit_rules_name", unique: true
  end

  add_foreign_key "fund_load_restrictions_submission_sanction_results", "fund_load_restrictions_sanctions", column: "sanction_id", primary_key: "uuid"
  add_foreign_key "fund_load_restrictions_submission_sanction_results", "fund_load_restrictions_submissions", column: "submission_id", primary_key: "uuid"
  add_foreign_key "fund_load_restrictions_submission_velocity_limit_results", "fund_load_restrictions_submissions", column: "submission_id", primary_key: "uuid"
  add_foreign_key "fund_load_restrictions_submission_velocity_limit_results", "fund_load_restrictions_velocity_limit_rules", column: "rule_id", primary_key: "uuid"
  add_foreign_key "fund_load_restrictions_submissions", "fund_load_restrictions_customers", column: "customer_id", primary_key: "uuid"
end
