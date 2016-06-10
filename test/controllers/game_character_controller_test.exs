defmodule EdgeBuilder.Controllers.GameCharacterControllerTest do
  use EdgeBuilder.ConnCase

  alias Factories.CharacterFactory
  alias Factories.GameFactory
  alias Factories.UserFactory
  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.GameCharacter

  describe "search" do
    it "returns characters whose name contains the specified string" do
      game = GameFactory.create_game
      CharacterFactory.create_character(name: "Boba Fett")
      CharacterFactory.create_character(name: "Luke Skywalker")
      CharacterFactory.create_character(name: "Anakin Skywalker")

      conn = conn() |> authenticate_as(UserFactory.default_user) |> get("g/#{game.permalink}/c/search", %{search: "sky"})

      assert conn.status == 200
      assert String.contains?(conn.resp_body, "Anakin Skywalker")
      assert String.contains?(conn.resp_body, "Luke Skywalker")
      assert !String.contains?(conn.resp_body, "Boba Fett")
    end

    it "displays add links for each character" do
      game = GameFactory.create_game
      CharacterFactory.create_character(name: "Luke Skywalker")

      conn = conn() |> authenticate_as(UserFactory.default_user) |> get("g/#{game.permalink}/c/search", %{search: "sky"})

      assert String.contains?(conn.resp_body, "Add")
    end
  end

  describe "create" do
    it "attaches a character sheet to a game" do
      game = GameFactory.create_game
      character = CharacterFactory.create_character

      conn() |> authenticate_as(UserFactory.default_user) |> post("/g/#{game.permalink}/c", %{
        "character" => %{
          "id" => character.id,
        },
      })

      assert Character.for_game(game.id) == [character]
    end

    it "only allows you to add a character once" do
      game = GameFactory.create_game
      character = CharacterFactory.create_character

      conn() |> authenticate_as(UserFactory.default_user) |> post("/g/#{game.permalink}/c", %{
        "character" => %{
          "id" => character.id,
        },
      })

      conn() |> authenticate_as(UserFactory.default_user) |> post("/g/#{game.permalink}/c", %{
        "character" => %{
          "id" => character.id,
        },
      })

      assert length(Character.for_game(game.id)) == 1
    end

    it "requires authentication" do
      game = GameFactory.create_game

      conn = conn() |> post("/g/#{game.permalink}/c", %{
        "character" => %{
          "id" => 123,
        },
      })

      assert requires_authentication?(conn)
    end

    it "requires the current user to match the game's owning user" do
      owner = UserFactory.default_user
      other = UserFactory.create_user(username: "other")
      game = GameFactory.create_game(user_id: owner.id)
      character = CharacterFactory.create_character(user_id: other.id)

      conn = conn() |> authenticate_as(other) |> post("/g/#{game.permalink}/c", %{
        "character" => %{
          "id" => character.id,
        },
      })

      assert conn.status == 302
      assert is_redirect_to?(conn, "/")
    end
  end

  describe "delete" do
    it "removes a character sheet from a game" do
      game = GameFactory.create_game
      boba = CharacterFactory.create_character(name: "Boba Fett")
      %GameCharacter{
        game_id: game.id,
        character_id: boba.id,
      } |> Repo.insert!

      conn() |> authenticate_as(UserFactory.default_user) |> delete("/g/#{game.permalink}/c/#{boba.permalink}")

      assert Character.for_game(game.id) == []
    end

    it "requires authentication" do
      game = GameFactory.create_game

      conn = conn() |> delete("/g/#{game.permalink}/c/123")

      assert requires_authentication?(conn)
    end

    it "requires the current user to match the game's owning user" do
      owner = UserFactory.default_user
      other = UserFactory.create_user(username: "other")
      game = GameFactory.create_game(user_id: owner.id)

      conn = conn() |> authenticate_as(other) |> delete("/g/#{game.permalink}/c/123")

      assert conn.status == 302
      assert is_redirect_to?(conn, "/")
    end
  end
end
