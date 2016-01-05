defmodule EdgeBuilder.GameTest do
  use EdgeBuilder.TestCase

  alias Factories.CharacterFactory
  alias Factories.GameFactory
  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.Game
  alias EdgeBuilder.Models.GameCharacter
  alias EdgeBuilder.Repo

  describe "url_slug" do
    it "has an 9 character lower-case slug after creation" do
      game = GameFactory.create_game

      assert String.match?(game.url_slug, ~r/[0-9a-z]{9}/)
    end
  end

  describe "permalink" do
    it "is a combination of the game name and url_slug" do
      game = GameFactory.create_game(name: "steve")

      assert game.permalink == "#{game.url_slug}-steve"
    end

    it "works regardless of special characters in the game's name" do
      game = GameFactory.create_game(name: "K'l<a> <p>")

      assert game.permalink == "#{game.url_slug}-k-l-a---p-"
    end

    it "trims very long names" do
      game = GameFactory.create_game(name: "thisstringisthirtyonecharacters")

      assert game.permalink == "#{game.url_slug}-thisstringisthi"
    end

    it "works on load too" do
      game = GameFactory.create_game(name: "steve")
      game = Repo.get(Game, game.id)

      assert game.permalink == "#{game.url_slug}-steve"
    end
  end

  describe "full_game" do
    it "finds a game by url slug" do
      game = GameFactory.create_game

      found_game = Game.full_game("#{game.url_slug}-does-not-matter")

      assert game.id == found_game.id
    end
  end

  describe "remove_character" do
    it "removes the character sheet from the game" do
      game = GameFactory.create_game
      boba = CharacterFactory.create_character(name: "Boba Fett")
      %GameCharacter{
        game_id: game.id,
        character_id: boba.id,
      } |> Repo.insert!

      Game.remove_character(game, boba.permalink)

      assert Character.for_game(game.id) == []
    end
  end
end
