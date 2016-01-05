defmodule EdgeBuilder.Models.CharacterTest do
  use EdgeBuilder.TestCase

  alias Factories.CharacterFactory
  alias Factories.GameFactory
  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.GameCharacter
  alias EdgeBuilder.Repo

  describe "url_slug" do
    it "has an 9 character lower-case slug after creation" do
      character = CharacterFactory.create_character

      assert String.match?(character.url_slug, ~r/[0-9a-z]{9}/)
    end
  end

  describe "permalink" do
    it "is a combination of the character name and url_slug" do
      character = CharacterFactory.create_character(name: "steve")

      assert character.permalink == "#{character.url_slug}-steve"
    end

    it "works regardless of special characters in the character's name" do
      character = CharacterFactory.create_character(name: "K'l<a> <p>")

      assert character.permalink == "#{character.url_slug}-k-l-a---p-"
    end

    it "trims very long names" do
      character = CharacterFactory.create_character(name: "thisstringisthirtyonecharacters")

      assert character.permalink == "#{character.url_slug}-thisstringisthi"
    end

    it "works on load too" do
      character = CharacterFactory.create_character(name: "steve")
      character = Repo.get(Character, character.id)

      assert character.permalink == "#{character.url_slug}-steve"
    end
  end

  describe "full_character" do
    it "finds a character by url slug" do
      character = CharacterFactory.create_character

      found_character = Character.full_character("#{character.url_slug}-does-not-matter")

      assert character.id == found_character.id
    end
  end

  describe "portrait_url" do
    it "changes imgur page url to image url" do
      character = CharacterFactory.create_character(portrait_url: "http://imgur.com/gallery/OjCH1Th")
      assert character.portrait_url == "http://i.imgur.com/OjCH1Th.jpg"
    end
  end

  describe "for_game" do
    it "retrieves all characters for a game" do
      game = GameFactory.create_game
      boba = CharacterFactory.create_character(name: "Boba Fett")
      han = CharacterFactory.create_character(name: "Han Solo")

      %GameCharacter{
        game_id: game.id,
        character_id: boba.id,
      } |> Repo.insert!

      %GameCharacter{
        game_id: game.id,
        character_id: han.id,
      } |> Repo.insert!

      assert Character.for_game(game.id) == [boba, han]
    end
  end
end
