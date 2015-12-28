defmodule EdgeBuilder.Controllers.GameControllerTest do
  use EdgeBuilder.ConnCase

  alias Factories.GameFactory
  alias Factories.UserFactory
  alias EdgeBuilder.Models.Game
  alias EdgeBuilder.Repo

  describe "new" do
    it "renders the character edit form for a new character" do
      conn = conn() |> authenticate_as(UserFactory.default_user) |> get("/g/new")

      assert conn.status == 200
      assert String.contains?(conn.resp_body, "New Game")
    end

    it "requires authentication" do
      conn = conn() |> get("/g/new")

      assert requires_authentication?(conn)
    end
  end

  describe "create" do
    it "creates a game" do
      conn() |> authenticate_as(UserFactory.default_user) |> post("/g", %{
        "game" => %{
          "name" => "A New New Hope",
          "description" => "Like the old one, but newer",
        },
      })

      game = Repo.all(Game) |> Enum.at(0)

      assert game.user_id == UserFactory.default_user.id
      assert game.name == "A New New Hope"
      assert game.description == "Like the old one, but newer"
    end

    it "redirects to the game show page" do
      params = GameFactory.default_parameters
      conn = conn() |> authenticate_as(UserFactory.default_user) |> post("/g", %{"game" => params})

      game = Repo.one!(from g in Game, where: g.name == ^params["name"])

      assert is_redirect_to?(conn, EdgeBuilder.Router.Helpers.game_path(conn, :show, game))
    end
  end

  describe "show" do
    it "displays the game information" do
      game = GameFactory.create_game

      conn = conn() |> get("/g/#{game.permalink}")

      assert conn.status == 200
      assert String.contains?(conn.resp_body, game.name)
    end

    it "displays edit and delete buttons when viewed by the owner" do
      game = GameFactory.create_game(user_id: UserFactory.default_user.id)

      conn = conn() |> authenticate_as(UserFactory.default_user) |> get("/g/#{game.permalink}")

      assert String.contains?(conn.resp_body, "Edit")
      assert String.contains?(conn.resp_body, "Delete")
    end
  end

  describe "index" do
    it "displays a link to create a new game" do
      conn = conn() |> get("/g")

      assert conn.status == 200
      assert String.contains?(conn.resp_body, EdgeBuilder.Router.Helpers.game_path(conn, :index))
    end

    it "displays links for each game regardless of creator" do
      games = [
        GameFactory.create_game(name: "A New Hope", user_id: UserFactory.default_user.id),
        GameFactory.create_game(name: "The Empire Strikes Back", user_id: UserFactory.create_user.id)
      ]

      conn = conn() |> get("/g")

      for game <- games do
        assert String.contains?(conn.resp_body, game.name)
        assert String.contains?(conn.resp_body, EdgeBuilder.Router.Helpers.game_path(conn, :show, game))
      end
    end
  end

  describe "edit" do
    it "renders the game edit form" do
      game = GameFactory.create_game(user_id: UserFactory.default_user.id)

      conn = conn() |> authenticate_as(UserFactory.default_user) |> get("/g/#{game.permalink}/edit")

      assert conn.status == 200
      assert String.contains?(conn.resp_body, game.name)
      assert String.contains?(conn.resp_body, game.description)
    end
  end

  describe "update" do
    it "updates the game's attributes" do
      game = GameFactory.create_game(name: "asdasd", description: "gogogo")

      conn() |> authenticate_as(UserFactory.default_user) |> put("/g/#{game.permalink}", %{"game" => %{"name" => "Return of the Jedi", "description" => "Ewoks and stuff"}})

      game = Repo.get(Game, game.id)

      assert game.name == "Return of the Jedi"
      assert game.description == "Ewoks and stuff"
    end

    it "redirects to the character show page" do
      game = GameFactory.create_game

      conn = conn() |> authenticate_as(UserFactory.default_user) |> put("/g/#{game.permalink}", %{"game" => %{"name" => "Return of the Jedi", "description" => "Ewoks and stuff"}})
      assert conn.status == 302
      assert is_redirect_to?(conn, EdgeBuilder.Router.Helpers.game_path(conn, :show, game))
    end
  end

  describe "delete" do
    it "deletes a game" do
      game = GameFactory.create_game

      conn() |> authenticate_as(UserFactory.default_user) |> delete("/g/#{game.permalink}")

      assert is_nil(Repo.get(Game, game.id))
    end

    it "requires authentication" do
      conn = conn() |> delete("/g/123")

      assert requires_authentication?(conn)
    end

    it "requires the current user to match the owning user" do
      owner = UserFactory.default_user
      other = UserFactory.create_user(username: "other")
      game = GameFactory.create_game(user_id: owner.id)

      conn = conn() |> authenticate_as(other) |> delete("/g/#{game.permalink}")

      assert is_redirect_to?(conn, "/")
    end
  end
end
