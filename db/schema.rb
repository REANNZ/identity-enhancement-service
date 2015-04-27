# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150427034024) do

  create_table "api_subject_role_assignments", force: :cascade do |t|
    t.integer  "api_subject_id", limit: 4, null: false
    t.integer  "role_id",        limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_subject_role_assignments", ["api_subject_id", "role_id"], name: "index_api_subject_role_assignments_on_api_subject_id_and_role_id", unique: true, using: :btree

  create_table "api_subjects", force: :cascade do |t|
    t.integer  "provider_id",  limit: 4,                  null: false
    t.string   "x509_cn",      limit: 255,                null: false
    t.string   "description",  limit: 255, default: "",   null: false
    t.string   "contact_name", limit: 255,                null: false
    t.string   "contact_mail", limit: 255,                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "enabled",      limit: 1,   default: true, null: false
  end

  add_index "api_subjects", ["x509_cn"], name: "index_api_subjects_on_x509_cn", unique: true, using: :btree

  create_table "audits", force: :cascade do |t|
    t.integer  "auditable_id",    limit: 4
    t.string   "auditable_type",  limit: 255
    t.integer  "associated_id",   limit: 4
    t.string   "associated_type", limit: 255
    t.integer  "user_id",         limit: 4
    t.string   "user_type",       limit: 255
    t.string   "username",        limit: 255
    t.string   "action",          limit: 255
    t.text     "audited_changes", limit: 65535
    t.integer  "version",         limit: 4,     default: 0
    t.string   "comment",         limit: 255
    t.string   "remote_address",  limit: 255
    t.string   "request_uuid",    limit: 255
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], name: "associated_index", using: :btree
  add_index "audits", ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
  add_index "audits", ["created_at"], name: "index_audits_on_created_at", using: :btree
  add_index "audits", ["request_uuid"], name: "index_audits_on_request_uuid", using: :btree
  add_index "audits", ["user_id", "user_type"], name: "user_index", using: :btree

  create_table "available_attributes", force: :cascade do |t|
    t.string   "name",        limit: 255, null: false
    t.string   "value",       limit: 255, null: false
    t.string   "description", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "available_attributes", ["name", "value"], name: "index_available_attributes_on_name_and_value", unique: true, using: :btree

  create_table "invitations", force: :cascade do |t|
    t.integer  "provider_id",  limit: 4,                   null: false
    t.integer  "subject_id",   limit: 4
    t.string   "identifier",   limit: 255,                 null: false
    t.string   "name",         limit: 255,                 null: false
    t.string   "mail",         limit: 255,                 null: false
    t.boolean  "used",         limit: 1,   default: false, null: false
    t.datetime "expires",                                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_sent_at",                             null: false
  end

  add_index "invitations", ["identifier"], name: "index_invitations_on_identifier", unique: true, using: :btree
  add_index "invitations", ["subject_id"], name: "index_invitations_on_subject_id", unique: true, using: :btree

  create_table "permissions", force: :cascade do |t|
    t.integer  "role_id",    limit: 4,   null: false
    t.string   "value",      limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "permissions", ["role_id", "value"], name: "index_permissions_on_role_id_and_value", unique: true, using: :btree

  create_table "permitted_attributes", force: :cascade do |t|
    t.integer  "provider_id",            limit: 4, null: false
    t.integer  "available_attribute_id", limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "permitted_attributes", ["provider_id", "available_attribute_id"], name: "permitted_attributes_unique_attribute", unique: true, using: :btree

  create_table "provided_attributes", force: :cascade do |t|
    t.integer  "permitted_attribute_id", limit: 4,   null: false
    t.integer  "subject_id",             limit: 4,   null: false
    t.string   "name",                   limit: 255, null: false
    t.string   "value",                  limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "provided_attributes", ["subject_id", "permitted_attribute_id"], name: "provided_attributes_unique_attribute", unique: true, using: :btree

  create_table "providers", force: :cascade do |t|
    t.string   "name",        limit: 255,                null: false
    t.string   "description", limit: 255, default: "",   null: false
    t.string   "identifier",  limit: 255,                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public",      limit: 1,   default: true, null: false
  end

  add_index "providers", ["identifier"], name: "index_providers_on_identifier", unique: true, using: :btree

  create_table "provisioned_subjects", force: :cascade do |t|
    t.integer  "subject_id",  limit: 4, null: false
    t.integer  "provider_id", limit: 4, null: false
    t.datetime "expires_at"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "provisioned_subjects", ["subject_id", "provider_id"], name: "index_provisioned_subjects_on_subject_id_and_provider_id", unique: true, using: :btree

  create_table "requested_enhancements", force: :cascade do |t|
    t.integer  "subject_id",     limit: 4,                    null: false
    t.integer  "provider_id",    limit: 4,                    null: false
    t.string   "message",        limit: 4096,                 null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.boolean  "actioned",       limit: 1,    default: false, null: false
    t.integer  "actioned_by_id", limit: 4
  end

  create_table "roles", force: :cascade do |t|
    t.integer  "provider_id", limit: 4,   null: false
    t.string   "name",        limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["provider_id"], name: "index_roles_on_provider_id", using: :btree

  create_table "subject_role_assignments", force: :cascade do |t|
    t.integer  "subject_id", limit: 4, null: false
    t.integer  "role_id",    limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subject_role_assignments", ["subject_id", "role_id"], name: "index_subject_role_assignments_on_subject_id_and_role_id", unique: true, using: :btree

  create_table "subjects", force: :cascade do |t|
    t.string   "name",         limit: 255,                 null: false
    t.string   "mail",         limit: 255,                 null: false
    t.string   "targeted_id",  limit: 255
    t.string   "shared_token", limit: 255
    t.boolean  "complete",     limit: 1,   default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "enabled",      limit: 1,   default: true,  null: false
  end

  add_index "subjects", ["mail"], name: "index_subjects_on_mail", unique: true, using: :btree
  add_index "subjects", ["shared_token"], name: "index_subjects_on_shared_token", unique: true, using: :btree
  add_index "subjects", ["targeted_id"], name: "index_subjects_on_targeted_id", using: :btree

end
