defmodule Factories.GameFactory do
  use Factories.BaseFactory

  alias Factories.UserFactory
  alias EdgeBuilder.Models.Game
  alias EdgeBuilder.Repo

  @defaults %{
    name: "A New Hope",
    description: "A whiny kid gets off the desert planet he has been stuck on"
  }

  def create_game(overrides \\ []) do
    if is_nil(overrides[:name]) do
      overrides = Keyword.put(overrides, :name, @defaults[:name] <> Integer.to_string(next_counter))
    end
    params = Enum.into(overrides, @defaults)
    user_id = params[:user_id] || UserFactory.default_user.id

    Game.changeset(%Game{}, user_id, parameterize(params)) |> Repo.insert!
  end

  def default_parameters do
    @defaults |> parameterize
  end
end
