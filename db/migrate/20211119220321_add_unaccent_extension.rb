class AddUnaccentExtension < ActiveRecord::Migration[6.1]
  def up
    execute 'CREATE EXTENSION IF NOT EXISTS unaccent'
  end

  def down
    execute 'DROP EXTENSION unaccent'
  end
end
