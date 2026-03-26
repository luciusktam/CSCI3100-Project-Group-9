# db/migrate/20260326171500_enable_pg_search_for_listings.rb
class EnablePgSearchForListings < ActiveRecord::Migration[8.1]
  def change
    enable_extension "pg_trgm" unless extension_enabled?("pg_trgm")

    add_index :listings, :title, using: :gin, opclass: :gin_trgm_ops
    add_index :listings, :description, using: :gin, opclass: :gin_trgm_ops

    add_index :listings, :category unless index_exists?(:listings, :category)
    add_index :listings, :condition unless index_exists?(:listings, :condition)
    add_index :listings, :location unless index_exists?(:listings, :location)
  end
end
