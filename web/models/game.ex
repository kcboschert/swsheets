defmodule EdgeBuilder.Models.Game do
  use EdgeBuilder.Web, :model

  @derive {Phoenix.Param, key: :permalink}
  schema "games" do
    field :url_slug, :string, read_after_writes: true
    field :permalink, :string, virtual: true
    field :name, :string
    field :description, :string

    timestamps
    belongs_to :user, User
  end

  before_insert Ecto.Changeset, :delete_change, [:url_slug]
  before_update Ecto.Changeset, :delete_change, [:url_slug]
  after_insert __MODULE__, :_set_permalink_for_changeset
  after_load __MODULE__, :_set_permalink

  defp required_fields, do: [:name, :user_id]
  defp optional_fields, do: [:description]

  def changeset(game, user_id, params \\ %{}) do
    game
    |> cast(Map.put(params, "user_id", user_id), required_fields, optional_fields)
  end

  def full_game(permalink) do
    url_slug = String.replace(permalink, ~r/-.*/, "")

    Repo.one!(
      from g in __MODULE__,
        where: g.url_slug == ^url_slug
    )
  end

  def _set_permalink_for_changeset(changeset) do
    update_in(changeset.model, &_set_permalink/1)
  end

  def _set_permalink(game) do
    Map.put(game, :permalink, "#{game.url_slug}-#{urlify(game.name)}")
  end

  defp urlify(name) do
    String.replace(name, ~r/\W/, "-")
    |> String.slice(0, 15)
    |> String.downcase
  end
end
