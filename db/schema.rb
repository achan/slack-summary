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

ActiveRecord::Schema[8.0].define(version: 2026_02_18_174653) do
  create_table "action_items", force: :cascade do |t|
    t.integer "summary_id", null: false
    t.integer "workspace_id", null: false
    t.text "channel_id", null: false
    t.text "description", null: false
    t.text "assignee_user_id"
    t.text "source_ts"
    t.text "status", default: "open", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_action_items_on_status"
    t.index ["summary_id"], name: "index_action_items_on_summary_id"
    t.index ["workspace_id"], name: "index_action_items_on_workspace_id"
  end

  create_table "channels", force: :cascade do |t|
    t.integer "workspace_id", null: false
    t.text "channel_id", null: false
    t.text "channel_name"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workspace_id", "channel_id"], name: "index_channels_on_workspace_id_and_channel_id", unique: true
    t.index ["workspace_id"], name: "index_channels_on_workspace_id"
  end

  create_table "events", force: :cascade do |t|
    t.integer "workspace_id", null: false
    t.text "event_id", null: false
    t.text "channel_id", null: false
    t.text "event_type"
    t.text "user_id"
    t.text "ts"
    t.text "thread_ts"
    t.json "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_events_on_event_id", unique: true
    t.index ["workspace_id", "channel_id", "created_at"], name: "index_events_on_workspace_id_and_channel_id_and_created_at"
    t.index ["workspace_id"], name: "index_events_on_workspace_id"
  end

  create_table "summaries", force: :cascade do |t|
    t.integer "workspace_id", null: false
    t.text "channel_id", null: false
    t.datetime "period_start"
    t.datetime "period_end"
    t.text "summary_text"
    t.text "model_used"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workspace_id"], name: "index_summaries_on_workspace_id"
  end

  create_table "workspaces", force: :cascade do |t|
    t.text "team_id", null: false
    t.text "team_name"
    t.text "user_token"
    t.text "signing_secret"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_workspaces_on_team_id", unique: true
  end

  add_foreign_key "action_items", "summaries"
  add_foreign_key "action_items", "workspaces"
  add_foreign_key "channels", "workspaces"
  add_foreign_key "events", "workspaces"
  add_foreign_key "summaries", "workspaces"
end
