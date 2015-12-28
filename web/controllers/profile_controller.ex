defmodule EdgeBuilder.ProfileController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.Game
  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Models.Vehicle
  alias EdgeBuilder.Repo
  import Ecto.Query, only: [from: 2]

  plug Plug.Authentication, except: [:show]

  def show(conn, %{"id" => username}) do
    user = User.by_username(username)
    characters = Repo.all(from c in Character, where: c.user_id == ^user.id, order_by: [desc: c.updated_at])
    vehicles = Repo.all(from v in Vehicle, where: v.user_id == ^user.id, order_by: [desc: v.updated_at])

    render conn, :show,
      user: user,
      characters: characters,
      vehicles: vehicles
  end

  def my_creations(conn, _params) do
    user = Repo.get(User, current_user_id(conn))
    characters = Repo.all(from c in Character, where: c.user_id == ^user.id, order_by: [desc: c.updated_at])
    vehicles = Repo.all(from v in Vehicle, where: v.user_id == ^user.id, order_by: [desc: v.updated_at])
    games = Repo.all(from g in Game, where: g.user_id == ^user.id, order_by: [desc: g.updated_at])

    render conn, :my_creations,
      user: user,
      characters: characters,
      games: games,
      vehicles: vehicles
  end
end
