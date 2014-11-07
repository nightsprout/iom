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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20141029184108) do

  create_table "activities", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "addr", :primary_key => "gid", :force => true do |t|
    t.integer "tlid",      :limit => 8
    t.string  "fromhn",    :limit => 12
    t.string  "tohn",      :limit => 12
    t.string  "side",      :limit => 1
    t.string  "zip",       :limit => 5
    t.string  "plus4",     :limit => 4
    t.string  "fromtyp",   :limit => 1
    t.string  "totyp",     :limit => 1
    t.integer "fromarmid"
    t.integer "toarmid"
    t.string  "arid",      :limit => 22
    t.string  "mtfcc",     :limit => 5
    t.string  "statefp",   :limit => 2
  end

  add_index "addr", ["tlid", "statefp"], :name => "idx_tiger_addr_tlid_statefp"
  add_index "addr", ["zip"], :name => "idx_tiger_addr_zip"

  create_table "addrfeat", :primary_key => "gid", :force => true do |t|
    t.integer "tlid",       :limit => 8
    t.string  "statefp",    :limit => 2,                                   :null => false
    t.string  "aridl",      :limit => 22
    t.string  "aridr",      :limit => 22
    t.string  "linearid",   :limit => 22
    t.string  "fullname",   :limit => 100
    t.string  "lfromhn",    :limit => 12
    t.string  "ltohn",      :limit => 12
    t.string  "rfromhn",    :limit => 12
    t.string  "rtohn",      :limit => 12
    t.string  "zipl",       :limit => 5
    t.string  "zipr",       :limit => 5
    t.string  "edge_mtfcc", :limit => 5
    t.string  "parityl",    :limit => 1
    t.string  "parityr",    :limit => 1
    t.string  "plus4l",     :limit => 4
    t.string  "plus4r",     :limit => 4
    t.string  "lfromtyp",   :limit => 1
    t.string  "ltotyp",     :limit => 1
    t.string  "rfromtyp",   :limit => 1
    t.string  "rtotyp",     :limit => 1
    t.string  "offsetl",    :limit => 1
    t.string  "offsetr",    :limit => 1
    t.spatial "the_geom",   :limit => {:srid=>4269, :type=>"line_string"}
  end

  add_index "addrfeat", ["the_geom"], :name => "idx_addrfeat_geom_gist", :spatial => true
  add_index "addrfeat", ["tlid"], :name => "idx_addrfeat_tlid"
  add_index "addrfeat", ["zipl"], :name => "idx_addrfeat_zipl"
  add_index "addrfeat", ["zipr"], :name => "idx_addrfeat_zipr"

  create_table "audiences", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "bg", :id => false, :force => true do |t|
    t.integer "gid",                                                       :null => false
    t.string  "statefp",  :limit => 2
    t.string  "countyfp", :limit => 3
    t.string  "tractce",  :limit => 6
    t.string  "blkgrpce", :limit => 1
    t.string  "bg_id",    :limit => 12,                                    :null => false
    t.string  "namelsad", :limit => 13
    t.string  "mtfcc",    :limit => 5
    t.string  "funcstat", :limit => 1
    t.float   "aland"
    t.float   "awater"
    t.string  "intptlat", :limit => 11
    t.string  "intptlon", :limit => 12
    t.spatial "the_geom", :limit => {:srid=>4269, :type=>"multi_polygon"}
  end

  create_table "changes_history_records", :force => true do |t|
    t.integer  "user_id"
    t.datetime "when"
    t.text     "how"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "what_id"
    t.string   "what_type"
    t.boolean  "reviewed",         :default => false
    t.string   "who_email"
    t.string   "who_organization"
  end

  add_index "changes_history_records", ["user_id", "what_type", "when"], :name => "index_changes_history_records_on_user_id_and_what_type_and_when"

  create_table "clusters", :force => true do |t|
    t.string "name"
  end

  create_table "clusters_projects", :id => false, :force => true do |t|
    t.integer "cluster_id"
    t.integer "project_id"
  end

  add_index "clusters_projects", ["cluster_id"], :name => "index_clusters_projects_on_cluster_id"
  add_index "clusters_projects", ["project_id"], :name => "index_clusters_projects_on_project_id"

  create_table "countries", :force => true do |t|
    t.string  "name"
    t.string  "code"
    t.float   "center_lat"
    t.float   "center_lon"
    t.spatial "the_geom",         :limit => {:srid=>4326, :type=>"multi_polygon"}
    t.string  "wiki_url"
    t.text    "wiki_description"
    t.string  "iso2_code"
    t.string  "iso3_code"
    t.text    "the_geom_geojson"
  end

  add_index "countries", ["name"], :name => "index_countries_on_name"
  add_index "countries", ["the_geom"], :name => "index_countries_on_the_geom", :spatial => true

  create_table "countries_projects", :id => false, :force => true do |t|
    t.integer "country_id"
    t.integer "project_id"
  end

  add_index "countries_projects", ["country_id"], :name => "index_countries_projects_on_country_id"
  add_index "countries_projects", ["project_id"], :name => "index_countries_projects_on_project_id"

  create_table "county", :id => false, :force => true do |t|
    t.integer "gid",                                                       :null => false
    t.string  "statefp",  :limit => 2
    t.string  "countyfp", :limit => 3
    t.string  "countyns", :limit => 8
    t.string  "cntyidfp", :limit => 5,                                     :null => false
    t.string  "name",     :limit => 100
    t.string  "namelsad", :limit => 100
    t.string  "lsad",     :limit => 2
    t.string  "classfp",  :limit => 2
    t.string  "mtfcc",    :limit => 5
    t.string  "csafp",    :limit => 3
    t.string  "cbsafp",   :limit => 5
    t.string  "metdivfp", :limit => 5
    t.string  "funcstat", :limit => 1
    t.integer "aland",    :limit => 8
    t.float   "awater"
    t.string  "intptlat", :limit => 11
    t.string  "intptlon", :limit => 12
    t.spatial "the_geom", :limit => {:srid=>4269, :type=>"multi_polygon"}
  end

  add_index "county", ["countyfp"], :name => "idx_tiger_county"
  add_index "county", ["gid"], :name => "uidx_county_gid", :unique => true

  create_table "county_lookup", :id => false, :force => true do |t|
    t.integer "st_code",               :null => false
    t.string  "state",   :limit => 2
    t.integer "co_code",               :null => false
    t.string  "name",    :limit => 90
  end

  add_index "county_lookup", ["state"], :name => "county_lookup_state_idx"

  create_table "countysub_lookup", :id => false, :force => true do |t|
    t.integer "st_code",               :null => false
    t.string  "state",   :limit => 2
    t.integer "co_code",               :null => false
    t.string  "county",  :limit => 90
    t.integer "cs_code",               :null => false
    t.string  "name",    :limit => 90
  end

  add_index "countysub_lookup", ["state"], :name => "countysub_lookup_state_idx"

  create_table "cousub", :id => false, :force => true do |t|
    t.integer "gid",                                                                                      :null => false
    t.string  "statefp",  :limit => 2
    t.string  "countyfp", :limit => 3
    t.string  "cousubfp", :limit => 5
    t.string  "cousubns", :limit => 8
    t.string  "cosbidfp", :limit => 10,                                                                   :null => false
    t.string  "name",     :limit => 100
    t.string  "namelsad", :limit => 100
    t.string  "lsad",     :limit => 2
    t.string  "classfp",  :limit => 2
    t.string  "mtfcc",    :limit => 5
    t.string  "cnectafp", :limit => 3
    t.string  "nectafp",  :limit => 5
    t.string  "nctadvfp", :limit => 5
    t.string  "funcstat", :limit => 1
    t.decimal "aland",                                                     :precision => 14, :scale => 0
    t.decimal "awater",                                                    :precision => 14, :scale => 0
    t.string  "intptlat", :limit => 11
    t.string  "intptlon", :limit => 12
    t.spatial "the_geom", :limit => {:srid=>4269, :type=>"multi_polygon"}
  end

  add_index "cousub", ["gid"], :name => "uidx_cousub_gid", :unique => true
  add_index "cousub", ["the_geom"], :name => "tige_cousub_the_geom_gist", :spatial => true

  create_table "data_denormalization", :id => false, :force => true do |t|
    t.integer  "project_id"
    t.string   "project_name",        :limit => 2000
    t.text     "project_description"
    t.integer  "organization_id"
    t.string   "organization_name",   :limit => 2000
    t.date     "end_date"
    t.text     "regions"
    t.string   "regions_ids",         :limit => nil
    t.text     "countries"
    t.string   "countries_ids",       :limit => nil
    t.text     "sectors"
    t.string   "sector_ids",          :limit => nil
    t.text     "clusters"
    t.string   "cluster_ids",         :limit => nil
    t.string   "donors_ids",          :limit => nil
    t.boolean  "is_active"
    t.integer  "site_id"
    t.datetime "created_at"
    t.date     "start_date"
    t.text     "activities"
    t.string   "activities_ids",      :limit => nil
    t.text     "audiences"
    t.string   "audiences_ids",       :limit => nil
    t.text     "diseases"
    t.string   "diseases_ids",        :limit => nil
    t.integer  "level"
  end

  add_index "data_denormalization", ["created_at"], :name => "index_data_denormalization_on_created_at"
  add_index "data_denormalization", ["is_active"], :name => "index_data_denormalization_on_is_active"
  add_index "data_denormalization", ["organization_id"], :name => "index_data_denormalization_on_organization_id"
  add_index "data_denormalization", ["project_id"], :name => "index_data_denormalization_on_project_id"
  add_index "data_denormalization", ["project_name"], :name => "index_data_denormalization_on_project_name"
  add_index "data_denormalization", ["site_id"], :name => "index_data_denormalization_on_site_id"

  create_table "direction_lookup", :id => false, :force => true do |t|
    t.string "name",   :limit => 20, :null => false
    t.string "abbrev", :limit => 3
  end

  add_index "direction_lookup", ["abbrev"], :name => "direction_lookup_abbrev_idx"

  create_table "diseases", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "diseases_projects", :id => false, :force => true do |t|
    t.integer "disease_id"
    t.integer "project_id"
  end

  add_index "diseases_projects", ["disease_id"], :name => "index_diseases_projects_on_disease_id"
  add_index "diseases_projects", ["project_id"], :name => "index_diseases_projects_on_project_id"

  create_table "donations", :force => true do |t|
    t.integer "donor_id"
    t.integer "project_id"
    t.float   "amount"
    t.date    "date"
    t.integer "office_id"
  end

  add_index "donations", ["donor_id"], :name => "index_donations_on_donor_id"
  add_index "donations", ["project_id"], :name => "index_donations_on_project_id"

  create_table "donors", :force => true do |t|
    t.string   "name",                      :limit => 2000
    t.text     "description"
    t.string   "website"
    t.string   "twitter"
    t.string   "facebook"
    t.string   "contact_person_name"
    t.string   "contact_company"
    t.string   "contact_person_position"
    t.string   "contact_email"
    t.string   "contact_phone_number"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.text     "site_specific_information"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "donors", ["name"], :name => "index_donors_on_name"

  create_table "edges", :primary_key => "gid", :force => true do |t|
    t.string  "statefp",    :limit => 2
    t.string  "countyfp",   :limit => 3
    t.integer "tlid",       :limit => 8
    t.decimal "tfidl",                                                           :precision => 10, :scale => 0
    t.decimal "tfidr",                                                           :precision => 10, :scale => 0
    t.string  "mtfcc",      :limit => 5
    t.string  "fullname",   :limit => 100
    t.string  "smid",       :limit => 22
    t.string  "lfromadd",   :limit => 12
    t.string  "ltoadd",     :limit => 12
    t.string  "rfromadd",   :limit => 12
    t.string  "rtoadd",     :limit => 12
    t.string  "zipl",       :limit => 5
    t.string  "zipr",       :limit => 5
    t.string  "featcat",    :limit => 1
    t.string  "hydroflg",   :limit => 1
    t.string  "railflg",    :limit => 1
    t.string  "roadflg",    :limit => 1
    t.string  "olfflg",     :limit => 1
    t.string  "passflg",    :limit => 1
    t.string  "divroad",    :limit => 1
    t.string  "exttyp",     :limit => 1
    t.string  "ttyp",       :limit => 1
    t.string  "deckedroad", :limit => 1
    t.string  "artpath",    :limit => 1
    t.string  "persist",    :limit => 1
    t.string  "gcseflg",    :limit => 1
    t.string  "offsetl",    :limit => 1
    t.string  "offsetr",    :limit => 1
    t.decimal "tnidf",                                                           :precision => 10, :scale => 0
    t.decimal "tnidt",                                                           :precision => 10, :scale => 0
    t.spatial "the_geom",   :limit => {:srid=>4269, :type=>"multi_line_string"}
  end

  add_index "edges", ["countyfp"], :name => "idx_tiger_edges_countyfp"
  add_index "edges", ["the_geom"], :name => "idx_tiger_edges_the_geom_gist", :spatial => true
  add_index "edges", ["tlid"], :name => "idx_edges_tlid"

  create_table "faces", :primary_key => "gid", :force => true do |t|
    t.decimal "tfid",                                                        :precision => 10, :scale => 0
    t.string  "statefp00",  :limit => 2
    t.string  "countyfp00", :limit => 3
    t.string  "tractce00",  :limit => 6
    t.string  "blkgrpce00", :limit => 1
    t.string  "blockce00",  :limit => 4
    t.string  "cousubfp00", :limit => 5
    t.string  "submcdfp00", :limit => 5
    t.string  "conctyfp00", :limit => 5
    t.string  "placefp00",  :limit => 5
    t.string  "aiannhfp00", :limit => 5
    t.string  "aiannhce00", :limit => 4
    t.string  "comptyp00",  :limit => 1
    t.string  "trsubfp00",  :limit => 5
    t.string  "trsubce00",  :limit => 3
    t.string  "anrcfp00",   :limit => 5
    t.string  "elsdlea00",  :limit => 5
    t.string  "scsdlea00",  :limit => 5
    t.string  "unsdlea00",  :limit => 5
    t.string  "uace00",     :limit => 5
    t.string  "cd108fp",    :limit => 2
    t.string  "sldust00",   :limit => 3
    t.string  "sldlst00",   :limit => 3
    t.string  "vtdst00",    :limit => 6
    t.string  "zcta5ce00",  :limit => 5
    t.string  "tazce00",    :limit => 6
    t.string  "ugace00",    :limit => 5
    t.string  "puma5ce00",  :limit => 5
    t.string  "statefp",    :limit => 2
    t.string  "countyfp",   :limit => 3
    t.string  "tractce",    :limit => 6
    t.string  "blkgrpce",   :limit => 1
    t.string  "blockce",    :limit => 4
    t.string  "cousubfp",   :limit => 5
    t.string  "submcdfp",   :limit => 5
    t.string  "conctyfp",   :limit => 5
    t.string  "placefp",    :limit => 5
    t.string  "aiannhfp",   :limit => 5
    t.string  "aiannhce",   :limit => 4
    t.string  "comptyp",    :limit => 1
    t.string  "trsubfp",    :limit => 5
    t.string  "trsubce",    :limit => 3
    t.string  "anrcfp",     :limit => 5
    t.string  "ttractce",   :limit => 6
    t.string  "tblkgpce",   :limit => 1
    t.string  "elsdlea",    :limit => 5
    t.string  "scsdlea",    :limit => 5
    t.string  "unsdlea",    :limit => 5
    t.string  "uace",       :limit => 5
    t.string  "cd111fp",    :limit => 2
    t.string  "sldust",     :limit => 3
    t.string  "sldlst",     :limit => 3
    t.string  "vtdst",      :limit => 6
    t.string  "zcta5ce",    :limit => 5
    t.string  "tazce",      :limit => 6
    t.string  "ugace",      :limit => 5
    t.string  "puma5ce",    :limit => 5
    t.string  "csafp",      :limit => 3
    t.string  "cbsafp",     :limit => 5
    t.string  "metdivfp",   :limit => 5
    t.string  "cnectafp",   :limit => 3
    t.string  "nectafp",    :limit => 5
    t.string  "nctadvfp",   :limit => 5
    t.string  "lwflag",     :limit => 1
    t.string  "offset",     :limit => 1
    t.float   "atotal"
    t.string  "intptlat",   :limit => 11
    t.string  "intptlon",   :limit => 12
    t.spatial "the_geom",   :limit => {:srid=>4269, :type=>"multi_polygon"}
  end

  add_index "faces", ["countyfp"], :name => "idx_tiger_faces_countyfp"
  add_index "faces", ["tfid"], :name => "idx_tiger_faces_tfid"
  add_index "faces", ["the_geom"], :name => "tiger_faces_the_geom_gist", :spatial => true

  create_table "featnames", :primary_key => "gid", :force => true do |t|
    t.integer "tlid",       :limit => 8
    t.string  "fullname",   :limit => 100
    t.string  "name",       :limit => 100
    t.string  "predirabrv", :limit => 15
    t.string  "pretypabrv", :limit => 50
    t.string  "prequalabr", :limit => 15
    t.string  "sufdirabrv", :limit => 15
    t.string  "suftypabrv", :limit => 50
    t.string  "sufqualabr", :limit => 15
    t.string  "predir",     :limit => 2
    t.string  "pretyp",     :limit => 3
    t.string  "prequal",    :limit => 2
    t.string  "sufdir",     :limit => 2
    t.string  "suftyp",     :limit => 3
    t.string  "sufqual",    :limit => 2
    t.string  "linearid",   :limit => 22
    t.string  "mtfcc",      :limit => 5
    t.string  "paflag",     :limit => 1
    t.string  "statefp",    :limit => 2
  end

  add_index "featnames", ["tlid", "statefp"], :name => "idx_tiger_featnames_tlid_statefp"

  create_table "geocode_settings", :id => false, :force => true do |t|
    t.text "name",       :null => false
    t.text "setting"
    t.text "unit"
    t.text "category"
    t.text "short_desc"
  end

  create_table "layer_styles", :force => true do |t|
    t.string "title"
    t.string "name"
  end

  create_table "layers", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.text     "credits"
    t.datetime "date"
    t.float    "min"
    t.float    "max"
    t.string   "units"
    t.boolean  "status"
    t.string   "cartodb_table"
    t.text     "sql"
    t.string   "long_title"
  end

  create_table "loader_lookuptables", :id => false, :force => true do |t|
    t.integer "process_order",                        :default => 1000,  :null => false
    t.text    "lookup_name",                                             :null => false
    t.text    "table_name"
    t.boolean "single_mode",                          :default => true,  :null => false
    t.boolean "load",                                 :default => true,  :null => false
    t.boolean "level_county",                         :default => false, :null => false
    t.boolean "level_state",                          :default => false, :null => false
    t.boolean "level_nation",                         :default => false, :null => false
    t.text    "post_load_process"
    t.boolean "single_geom_mode",                     :default => false
    t.string  "insert_mode",           :limit => 1,   :default => "c",   :null => false
    t.text    "pre_load_process"
    t.string  "columns_exclude",       :limit => nil
    t.text    "website_root_override"
  end

  create_table "loader_platform", :id => false, :force => true do |t|
    t.string "os",                     :limit => 50, :null => false
    t.text   "declare_sect"
    t.text   "pgbin"
    t.text   "wget"
    t.text   "unzip_command"
    t.text   "psql"
    t.text   "path_sep"
    t.text   "loader"
    t.text   "environ_set_command"
    t.text   "county_process_command"
  end

  create_table "loader_variables", :id => false, :force => true do |t|
    t.string "tiger_year",     :limit => 4, :null => false
    t.text   "website_root"
    t.text   "staging_fold"
    t.text   "data_schema"
    t.text   "staging_schema"
  end

  create_table "media_resources", :force => true do |t|
    t.integer  "position",                 :default => 0
    t.integer  "element_id"
    t.integer  "element_type"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_filesize"
    t.datetime "picture_updated_at"
    t.string   "video_url"
    t.text     "video_embed_html"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.string   "caption"
    t.string   "video_thumb_file_name"
    t.string   "video_thumb_content_type"
    t.integer  "video_thumb_file_size"
    t.datetime "video_thumb_updated_at"
  end

  add_index "media_resources", ["element_type", "element_id"], :name => "index_media_resources_on_element_type_and_element_id"

  create_table "medicines", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "medicines_projects", :id => false, :force => true do |t|
    t.integer "medicine_id"
    t.integer "project_id"
  end

  add_index "medicines_projects", ["medicine_id"], :name => "index_medicines_projects_on_medicine_id"
  add_index "medicines_projects", ["project_id"], :name => "index_medicines_projects_on_project_id"

  create_table "offices", :force => true do |t|
    t.integer  "donor_id"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.float    "budget"
    t.string   "website"
    t.integer  "national_staff"
    t.string   "twitter"
    t.string   "facebook"
    t.string   "hq_address"
    t.string   "contact_email"
    t.string   "contact_phone_number"
    t.string   "donation_address"
    t.string   "zip_code"
    t.string   "city"
    t.string   "state"
    t.string   "donation_phone_number"
    t.string   "donation_website"
    t.text     "site_specific_information"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "international_staff"
    t.string   "contact_name"
    t.string   "contact_position"
    t.string   "contact_zip"
    t.string   "contact_city"
    t.string   "contact_state"
    t.string   "contact_country"
    t.string   "donation_country"
    t.integer  "estimated_people_reached"
    t.float    "private_funding"
    t.float    "usg_funding"
    t.float    "other_funding"
    t.float    "private_funding_spent"
    t.float    "usg_funding_spent"
    t.float    "other_funding_spent"
    t.float    "spent_funding_on_relief"
    t.float    "spent_funding_on_reconstruction"
    t.integer  "percen_relief"
    t.integer  "percen_reconstruction"
    t.string   "media_contact_name"
    t.string   "media_contact_position"
    t.string   "media_contact_phone_number"
    t.string   "media_contact_email"
    t.string   "main_data_contact_name"
    t.string   "main_data_contact_position"
    t.string   "main_data_contact_phone_number"
    t.string   "main_data_contact_email"
    t.string   "main_data_contact_zip"
    t.string   "main_data_contact_city"
    t.string   "main_data_contact_state"
    t.string   "main_data_contact_country"
    t.string   "organization_id"
  end

  add_index "organizations", ["name"], :name => "index_organizations_on_name"

  create_table "organizations_projects", :id => false, :force => true do |t|
    t.integer "organization_id"
    t.integer "project_id"
  end

  add_index "organizations_projects", ["organization_id"], :name => "index_organizations_projects_on_organization_id"
  add_index "organizations_projects", ["project_id"], :name => "index_organizations_projects_on_project_id"

  create_table "pagc_gaz", :force => true do |t|
    t.integer "seq"
    t.text    "word"
    t.text    "stdword"
    t.integer "token"
    t.boolean "is_custom", :default => true, :null => false
  end

  create_table "pagc_lex", :force => true do |t|
    t.integer "seq"
    t.text    "word"
    t.text    "stdword"
    t.integer "token"
    t.boolean "is_custom", :default => true, :null => false
  end

  create_table "pagc_rules", :force => true do |t|
    t.text    "rule"
    t.boolean "is_custom", :default => true
  end

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "site_id"
    t.boolean  "published"
    t.string   "permalink"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "parent_id"
    t.integer  "order_index"
  end

  add_index "pages", ["parent_id"], :name => "index_pages_on_parent_id"
  add_index "pages", ["permalink"], :name => "index_pages_on_permalink"
  add_index "pages", ["site_id"], :name => "index_pages_on_site_id"

  create_table "partners", :force => true do |t|
    t.integer  "site_id"
    t.string   "name"
    t.string   "url"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "label"
  end

  add_index "partners", ["site_id"], :name => "index_partners_on_site_id"

  create_table "place", :id => false, :force => true do |t|
    t.integer "gid",                                                       :null => false
    t.string  "statefp",  :limit => 2
    t.string  "placefp",  :limit => 5
    t.string  "placens",  :limit => 8
    t.string  "plcidfp",  :limit => 7,                                     :null => false
    t.string  "name",     :limit => 100
    t.string  "namelsad", :limit => 100
    t.string  "lsad",     :limit => 2
    t.string  "classfp",  :limit => 2
    t.string  "cpi",      :limit => 1
    t.string  "pcicbsa",  :limit => 1
    t.string  "pcinecta", :limit => 1
    t.string  "mtfcc",    :limit => 5
    t.string  "funcstat", :limit => 1
    t.integer "aland",    :limit => 8
    t.integer "awater",   :limit => 8
    t.string  "intptlat", :limit => 11
    t.string  "intptlon", :limit => 12
    t.spatial "the_geom", :limit => {:srid=>4269, :type=>"multi_polygon"}
  end

  add_index "place", ["gid"], :name => "uidx_tiger_place_gid", :unique => true
  add_index "place", ["the_geom"], :name => "tiger_place_the_geom_gist", :spatial => true

  create_table "place_lookup", :id => false, :force => true do |t|
    t.integer "st_code",               :null => false
    t.string  "state",   :limit => 2
    t.integer "pl_code",               :null => false
    t.string  "name",    :limit => 90
  end

  add_index "place_lookup", ["state"], :name => "place_lookup_state_idx"

  create_table "projects", :force => true do |t|
    t.string   "name",                                    :limit => 2000
    t.text     "description"
    t.integer  "primary_organization_id"
    t.text     "implementing_organization"
    t.text     "partner_organizations"
    t.text     "cross_cutting_issues"
    t.date     "start_date"
    t.date     "end_date"
    t.float    "budget"
    t.text     "target"
    t.integer  "estimated_people_reached",                :limit => 8
    t.string   "contact_person"
    t.string   "contact_email"
    t.string   "contact_phone_number"
    t.text     "site_specific_information"
    t.datetime "created_at",                                                                          :null => false
    t.datetime "updated_at",                                                                          :null => false
    t.spatial  "the_geom",                                :limit => {:srid=>4326, :type=>"geometry"}
    t.text     "activities"
    t.string   "intervention_id"
    t.text     "additional_information"
    t.string   "awardee_type"
    t.date     "date_provided"
    t.date     "date_updated"
    t.string   "contact_position"
    t.string   "website"
    t.text     "verbatim_location"
    t.text     "calculation_of_number_of_people_reached"
    t.text     "project_needs"
    t.text     "idprefugee_camp"
    t.string   "organization_id"
  end

  add_index "projects", ["end_date"], :name => "index_projects_on_end_date"
  add_index "projects", ["name"], :name => "index_projects_on_name"
  add_index "projects", ["primary_organization_id"], :name => "index_projects_on_primary_organization_id"
  add_index "projects", ["the_geom"], :name => "index_projects_on_the_geom", :spatial => true

  create_table "projects_activities", :id => false, :force => true do |t|
    t.integer "activity_id"
    t.integer "project_id"
  end

  add_index "projects_activities", ["activity_id"], :name => "index_projects_activities_on_activity_id"
  add_index "projects_activities", ["project_id"], :name => "index_projects_activities_on_project_id"

  create_table "projects_audiences", :id => false, :force => true do |t|
    t.integer "audience_id"
    t.integer "project_id"
  end

  add_index "projects_audiences", ["audience_id"], :name => "index_projects_audiences_on_audience_id"
  add_index "projects_audiences", ["project_id"], :name => "index_projects_audiences_on_project_id"

  create_table "projects_regions", :id => false, :force => true do |t|
    t.integer "region_id"
    t.integer "project_id"
  end

  add_index "projects_regions", ["project_id"], :name => "index_projects_regions_on_project_id"
  add_index "projects_regions", ["region_id"], :name => "index_projects_regions_on_region_id"

  create_table "projects_sectors", :id => false, :force => true do |t|
    t.integer "sector_id"
    t.integer "project_id"
  end

  add_index "projects_sectors", ["project_id"], :name => "index_projects_sectors_on_project_id"
  add_index "projects_sectors", ["sector_id"], :name => "index_projects_sectors_on_sector_id"

  create_table "projects_sites", :id => false, :force => true do |t|
    t.integer "project_id"
    t.integer "site_id"
  end

  add_index "projects_sites", ["project_id", "site_id"], :name => "index_projects_sites_on_project_id_and_site_id", :unique => true
  add_index "projects_sites", ["project_id"], :name => "index_projects_sites_on_project_id"
  add_index "projects_sites", ["site_id"], :name => "index_projects_sites_on_site_id"

  create_table "projects_synchronizations", :force => true do |t|
    t.text     "projects_file_data"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "projects_tags", :id => false, :force => true do |t|
    t.integer "tag_id"
    t.integer "project_id"
  end

  add_index "projects_tags", ["project_id"], :name => "index_projects_tags_on_project_id"
  add_index "projects_tags", ["tag_id"], :name => "index_projects_tags_on_tag_id"

  create_table "regions", :force => true do |t|
    t.string  "name"
    t.integer "level"
    t.integer "country_id"
    t.integer "parent_region_id"
    t.float   "center_lat"
    t.float   "center_lon"
    t.string  "path"
    t.spatial "the_geom",         :limit => {:srid=>4326, :type=>"geometry"}
    t.integer "gadm_id"
    t.string  "wiki_url"
    t.text    "wiki_description"
    t.string  "code"
    t.text    "the_geom_geojson"
    t.text    "ia_name"
  end

  add_index "regions", ["country_id"], :name => "index_regions_on_country_id"
  add_index "regions", ["level"], :name => "index_regions_on_level"
  add_index "regions", ["name"], :name => "index_regions_on_name"
  add_index "regions", ["parent_region_id"], :name => "index_regions_on_parent_region_id"
  add_index "regions", ["the_geom"], :name => "index_regions_on_the_geom", :spatial => true

  create_table "resources", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.integer  "element_id"
    t.integer  "element_type"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.text     "site_specific_information"
  end

  add_index "resources", ["element_type", "element_id"], :name => "index_resources_on_element_type_and_element_id"

  create_table "secondary_unit_lookup", :id => false, :force => true do |t|
    t.string "name",   :limit => 20, :null => false
    t.string "abbrev", :limit => 5
  end

  add_index "secondary_unit_lookup", ["abbrev"], :name => "secondary_unit_lookup_abbrev_idx"

  create_table "sectors", :force => true do |t|
    t.string "name"
  end

  create_table "settings", :force => true do |t|
    t.text "data"
  end

  create_table "site_layers", :id => false, :force => true do |t|
    t.integer "site_id"
    t.integer "layer_id"
    t.integer "layer_style_id"
  end

  add_index "site_layers", ["layer_id"], :name => "index_site_layers_on_layer_id"
  add_index "site_layers", ["layer_style_id"], :name => "index_site_layers_on_layer_style_id"
  add_index "site_layers", ["site_id"], :name => "index_site_layers_on_site_id"

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.text     "short_description"
    t.text     "long_description"
    t.string   "contact_email"
    t.string   "contact_person"
    t.string   "url"
    t.string   "permalink"
    t.string   "google_analytics_id"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.integer  "theme_id"
    t.string   "blog_url"
    t.string   "word_for_clusters"
    t.string   "word_for_regions"
    t.boolean  "show_global_donations_raises",                                                :default => false
    t.integer  "project_classification",                                                      :default => 0
    t.integer  "geographic_context_country_id"
    t.integer  "geographic_context_region_id"
    t.integer  "project_context_cluster_id"
    t.integer  "project_context_sector_id"
    t.integer  "project_context_organization_id"
    t.string   "project_context_tags"
    t.datetime "created_at",                                                                                     :null => false
    t.datetime "updated_at",                                                                                     :null => false
    t.spatial  "geographic_context_geometry",     :limit => {:srid=>4326, :type=>"geometry"}
    t.string   "project_context_tags_ids"
    t.boolean  "status",                                                                      :default => false
    t.float    "visits",                                                                      :default => 0.0
    t.float    "visits_last_week",                                                            :default => 0.0
    t.string   "aid_map_image_file_name"
    t.string   "aid_map_image_content_type"
    t.integer  "aid_map_image_file_size"
    t.datetime "aid_map_image_updated_at"
    t.boolean  "navigate_by_country",                                                         :default => false
    t.boolean  "navigate_by_level1",                                                          :default => false
    t.boolean  "navigate_by_level2",                                                          :default => false
    t.boolean  "navigate_by_level3",                                                          :default => false
    t.text     "map_styles"
    t.float    "overview_map_lat"
    t.float    "overview_map_lon"
    t.integer  "overview_map_zoom"
    t.text     "internal_description"
    t.boolean  "featured",                                                                    :default => false
  end

  add_index "sites", ["geographic_context_geometry"], :name => "index_sites_on_geographic_context_geometry", :spatial => true
  add_index "sites", ["name"], :name => "index_sites_on_name"
  add_index "sites", ["status"], :name => "index_sites_on_status"
  add_index "sites", ["url"], :name => "index_sites_on_url"

  create_table "state", :id => false, :force => true do |t|
    t.integer "gid",                                                       :null => false
    t.string  "region",   :limit => 2
    t.string  "division", :limit => 2
    t.string  "statefp",  :limit => 2,                                     :null => false
    t.string  "statens",  :limit => 8
    t.string  "stusps",   :limit => 2,                                     :null => false
    t.string  "name",     :limit => 100
    t.string  "lsad",     :limit => 2
    t.string  "mtfcc",    :limit => 5
    t.string  "funcstat", :limit => 1
    t.integer "aland",    :limit => 8
    t.integer "awater",   :limit => 8
    t.string  "intptlat", :limit => 11
    t.string  "intptlon", :limit => 12
    t.spatial "the_geom", :limit => {:srid=>4269, :type=>"multi_polygon"}
  end

  add_index "state", ["gid"], :name => "uidx_tiger_state_gid", :unique => true
  add_index "state", ["stusps"], :name => "uidx_tiger_state_stusps", :unique => true
  add_index "state", ["the_geom"], :name => "idx_tiger_state_the_geom_gist", :spatial => true

  create_table "state_lookup", :id => false, :force => true do |t|
    t.integer "st_code",               :null => false
    t.string  "name",    :limit => 40
    t.string  "abbrev",  :limit => 3
    t.string  "statefp", :limit => 2
  end

  add_index "state_lookup", ["abbrev"], :name => "state_lookup_abbrev_key", :unique => true
  add_index "state_lookup", ["name"], :name => "state_lookup_name_key", :unique => true
  add_index "state_lookup", ["statefp"], :name => "state_lookup_statefp_key", :unique => true

  create_table "stats", :force => true do |t|
    t.integer "site_id"
    t.integer "visits"
    t.date    "date"
  end

  add_index "stats", ["site_id"], :name => "index_stats_on_site_id"

  create_table "street_type_lookup", :id => false, :force => true do |t|
    t.string  "name",   :limit => 50,                    :null => false
    t.string  "abbrev", :limit => 50
    t.boolean "is_hw",                :default => false, :null => false
  end

  add_index "street_type_lookup", ["abbrev"], :name => "street_type_lookup_abbrev_idx"

  create_table "tabblock", :id => false, :force => true do |t|
    t.integer "gid",                                                          :null => false
    t.string  "statefp",     :limit => 2
    t.string  "countyfp",    :limit => 3
    t.string  "tractce",     :limit => 6
    t.string  "blockce",     :limit => 4
    t.string  "tabblock_id", :limit => 16,                                    :null => false
    t.string  "name",        :limit => 20
    t.string  "mtfcc",       :limit => 5
    t.string  "ur",          :limit => 1
    t.string  "uace",        :limit => 5
    t.string  "funcstat",    :limit => 1
    t.float   "aland"
    t.float   "awater"
    t.string  "intptlat",    :limit => 11
    t.string  "intptlon",    :limit => 12
    t.spatial "the_geom",    :limit => {:srid=>4269, :type=>"multi_polygon"}
  end

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.integer "count", :default => 0
  end

  create_table "themes", :force => true do |t|
    t.string "name"
    t.string "css_file"
    t.string "thumbnail_path"
    t.text   "data"
  end

  create_table "tract", :id => false, :force => true do |t|
    t.integer "gid",                                                       :null => false
    t.string  "statefp",  :limit => 2
    t.string  "countyfp", :limit => 3
    t.string  "tractce",  :limit => 6
    t.string  "tract_id", :limit => 11,                                    :null => false
    t.string  "name",     :limit => 7
    t.string  "namelsad", :limit => 20
    t.string  "mtfcc",    :limit => 5
    t.string  "funcstat", :limit => 1
    t.float   "aland"
    t.float   "awater"
    t.string  "intptlat", :limit => 11
    t.string  "intptlon", :limit => 12
    t.spatial "the_geom", :limit => {:srid=>4269, :type=>"multi_polygon"}
  end

  create_table "users", :force => true do |t|
    t.string   "name",                                   :limit => 100, :default => ""
    t.string   "email",                                  :limit => 100
    t.string   "crypted_password",                       :limit => 40
    t.string   "salt",                                   :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",                         :limit => 40
    t.datetime "remember_token_expires_at"
    t.integer  "organization_id"
    t.string   "role"
    t.boolean  "blocked",                                               :default => false
    t.string   "site_id"
    t.text     "description"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.datetime "last_login"
    t.boolean  "six_months_since_last_login_alert_sent",                :default => false
    t.integer  "login_fails",                                           :default => 0
  end

  add_index "users", ["email"], :name => "index_users_on_email"

  create_table "zcta5", :id => false, :force => true do |t|
    t.integer "gid",                                                       :null => false
    t.string  "statefp",  :limit => 2,                                     :null => false
    t.string  "zcta5ce",  :limit => 5,                                     :null => false
    t.string  "classfp",  :limit => 2
    t.string  "mtfcc",    :limit => 5
    t.string  "funcstat", :limit => 1
    t.float   "aland"
    t.float   "awater"
    t.string  "intptlat", :limit => 11
    t.string  "intptlon", :limit => 12
    t.string  "partflg",  :limit => 1
    t.spatial "the_geom", :limit => {:srid=>4269, :type=>"multi_polygon"}
  end

  add_index "zcta5", ["gid"], :name => "uidx_tiger_zcta5_gid", :unique => true

  create_table "zip_lookup", :id => false, :force => true do |t|
    t.integer "zip",                   :null => false
    t.integer "st_code"
    t.string  "state",   :limit => 2
    t.integer "co_code"
    t.string  "county",  :limit => 90
    t.integer "cs_code"
    t.string  "cousub",  :limit => 90
    t.integer "pl_code"
    t.string  "place",   :limit => 90
    t.integer "cnt"
  end

  create_table "zip_lookup_all", :id => false, :force => true do |t|
    t.integer "zip"
    t.integer "st_code"
    t.string  "state",   :limit => 2
    t.integer "co_code"
    t.string  "county",  :limit => 90
    t.integer "cs_code"
    t.string  "cousub",  :limit => 90
    t.integer "pl_code"
    t.string  "place",   :limit => 90
    t.integer "cnt"
  end

  create_table "zip_lookup_base", :id => false, :force => true do |t|
    t.string "zip",     :limit => 5,  :null => false
    t.string "state",   :limit => 40
    t.string "county",  :limit => 90
    t.string "city",    :limit => 90
    t.string "statefp", :limit => 2
  end

  create_table "zip_state", :id => false, :force => true do |t|
    t.string "zip",     :limit => 5, :null => false
    t.string "stusps",  :limit => 2, :null => false
    t.string "statefp", :limit => 2
  end

  create_table "zip_state_loc", :id => false, :force => true do |t|
    t.string "zip",     :limit => 5,   :null => false
    t.string "stusps",  :limit => 2,   :null => false
    t.string "statefp", :limit => 2
    t.string "place",   :limit => 100, :null => false
  end

end
