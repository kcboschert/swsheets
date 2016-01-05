defmodule EdgeBuilder.GameCharacterTest do
  use EdgeBuilder.TestCase

  alias Factories.CharacterFactory
  alias Factories.GameFactory
  alias EdgeBuilder.Models.GameCharacter
  alias EdgeBuilder.Repo

  @valid_attrs %{character_id: 42, game_id: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = GameCharacter.changeset(%GameCharacter{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = GameCharacter.changeset(%GameCharacter{}, @invalid_attrs)
    refute changeset.valid?
  end

  describe "for_game_and_character" do
    it "retrieves the specified relationship between character and game" do
      game = GameFactory.create_game
      boba = CharacterFactory.create_character(name: "Boba Fett")

      game_character = %GameCharacter{
        game_id: game.id,
        character_id: boba.id,
      } |> Repo.insert!

      assert GameCharacter.for_game_and_character(game.id, boba.id) == game_character
    end
  end
end
