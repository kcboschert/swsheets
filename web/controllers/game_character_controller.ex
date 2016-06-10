defmodule EdgeBuilder.GameCharacterController do
  use EdgeBuilder.Web, :controller
  require Logger

  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.Game
  alias EdgeBuilder.Models.GameCharacter
  import Ecto.Query, only: [from: 2]

  plug Plug.Authentication

  def search(conn, params = %{"game_id" => game_id, "search" => search_params}) do
    game = Game.full_game(game_id)
    page = Repo.paginate((
        from c in Character,
        where: fragment("name ILIKE ?", ^"%#{search_params}%"),
        order_by: [asc: c.name]
      ),
      page: params["page"]
    )

    render conn, :search,
      title: "Characters",
      characters: page.entries,
      page_number: page.page_number,
      total_pages: page.total_pages,
      game: game
  end

  def create(conn, params = %{"game_id" => game_id, "character" => character_params}) do
    game = Game.full_game(game_id)

    if !is_owner?(conn, game) do
      redirect conn, to: "/"
    else
      existing = GameCharacter.for_game_and_character(game.id, character_params["id"])
      if !is_nil(existing) do
        redirect conn, to: game_path(conn, :show, game)
      else
        game_character = GameCharacter.changeset(
          %GameCharacter{}, %{game_id: game.id, character_id: character_params["id"]}
        )

        if game_character.valid? do
          Repo.insert!(game_character)

          redirect conn, to: game_path(conn, :show, game)
        else
          redirect conn, to: game_path(conn, :show, game),
            errors: game_character.errors
        end
      end
    end
  end

  def delete(conn, %{"game_id" => game_id, "id" => character_id}) do
    game = Game.full_game(game_id)

    if !is_owner?(conn, game) do
      redirect conn, to: "/"
    else
      Game.remove_character(game, character_id)
      redirect conn, to: game_path(conn, :show, game)
    end
  end
end
