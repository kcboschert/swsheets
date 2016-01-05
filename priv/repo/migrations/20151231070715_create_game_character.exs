defmodule EdgeBuilder.Repo.Migrations.CreateGameCharacter do
  use Ecto.Migration

  def change do
    create table(:game_characters) do
      add :game_id, :integer
      add :character_id, :integer
    end

    create unique_index(:game_characters, [:game_id, :character_id], name: :game_characters_game_id_character_id_index)
  end
end
