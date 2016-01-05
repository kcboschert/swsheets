defmodule EdgeBuilder.Models.GameCharacter do
  use EdgeBuilder.Web, :model

  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.Game

  schema "game_characters" do
    belongs_to :character, Character
    belongs_to :game, Game
  end

  @required_fields ~w(game_id character_id)
  @optional_fields ~w()

  def changeset(game_character, params \\ :empty) do
    game_character
    |> cast(params, @required_fields, @optional_fields)
  end

  def for_game_and_character(game_id, character_id) do
    Repo.one(
      from gc in __MODULE__,
      where: gc.game_id == ^game_id and gc.character_id == ^character_id
    )
  end
end
