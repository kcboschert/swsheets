defmodule EdgeBuilder.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def up do
    create table(:games) do
      add :name, :string, null: false
      add :description, :string
      add :user_id, :integer, null: false
      timestamps
    end

    execute "
      CREATE FUNCTION new_game_url_slug() RETURNS text AS $$
      DECLARE
        new_slug text;
        done bool;
      BEGIN
        done := false;
        WHILE NOT done LOOP
          new_slug := lower(substring(regexp_replace(encode(gen_random_bytes(32), 'base64'), '[^a-zA-Z0-9]+', '', 'g'), 0, 10));
          done := NOT exists(SELECT 1 FROM games WHERE url_slug = new_slug);
        END LOOP;
        RETURN new_slug;
      END;
      $$ LANGUAGE PLPGSQL VOLATILE;
    "

    execute "ALTER TABLE games ADD COLUMN url_slug varchar(10) DEFAULT new_game_url_slug()"
  end

  def down do
    Enum.each [:games], fn(table_name) ->
      drop table(table_name)
    end
  end
end
