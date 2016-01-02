defmodule EdgeBuilder.GameController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Models.Game
  alias EdgeBuilder.Models.User
  import EdgeBuilder.Router.Helpers
  import Ecto.Query, only: [from: 2]

  plug Plug.Authentication, except: [:show, :index]

  def new(conn, _params) do
    render_new conn
  end

  def create(conn, %{"game" => game_params}) do
    game = Game.changeset(%Game{}, current_user_id(conn), game_params)

    if game.valid? do
      game = EdgeBuilder.Repo.insert!(game)

      redirect conn, to: game_path(conn, :show, game)
    else
      render_new conn,
        game: game,
        errors: game.errors
    end
  end

  def index(conn, params) do
    page = Repo.paginate((from g in Game, order_by: [desc: g.inserted_at]), page: params["page"])

    render conn, :index,
      title: "Games",
      games: page.entries,
      page_number: page.page_number,
      total_pages: page.total_pages
  end

  def show(conn, %{"id" => id}) do
    game = Game.full_game(id)
    user = Repo.get!(User, game.user_id)

    render conn, :show,
      game: game,
      user: user,
      viewed_by_owner: is_owner?(conn, game)
  end

  def edit(conn, %{"id" => id}) do
    game = Game.full_game(id)

    if !is_owner?(conn, game) do
      redirect conn, to: "/"
    else
      render_edit conn,
        game: game |> Game.changeset(current_user_id(conn))
    end
  end

  def update(conn, %{"id" => id, "game" => game_params}) do
    game = Game.full_game(id)

    if !is_owner?(conn, game) do
      redirect conn, to: "/"
    else
      game = game |> Game.changeset(current_user_id(conn), game_params)

      if game.valid? do
        game = EdgeBuilder.Repo.update!(game)

        redirect conn, to: game_path(conn, :show, game)
      else
        render_edit conn,
          game: game,
          errors: game.errors
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    game = Game.full_game(id)

    if !is_owner?(conn, game) do
      redirect conn, to: "/"
    else
      Repo.delete!(game)
      redirect conn, to: profile_path(conn, :my_creations)
    end
  end

  defp render_new(conn, assignments \\ []) do
    assignments = Keyword.merge(assignments, [
      title: "New Game",
      game: (if is_nil(assignments[:game]), do: %Game{} |> Game.changeset(current_user_id(conn)), else: assignments[:game])
    ])

    render conn, :new, assignments
  end

  defp render_edit(conn, assignments) do
    assignments = Keyword.merge(assignments, [
      title: "Editing #{Ecto.Changeset.get_field(assignments[:game], :name)}",
      game: assignments[:game]
    ])

    render conn, :edit, assignments
  end
end
