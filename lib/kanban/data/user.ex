defmodule Kanban.Data.User do
  @moduledoc """
  User changeset
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Kanban.Data.{Task}

  @primary_key false
  embedded_schema do
    # field :id, :binary_id, autogenerate: &Ecto.UUID.generate/0
    field(:name, :string)
    field(:password, :string, redact: true)
    embeds_many(:tasks, Task)
  end

  def changeset(user, params) do
    user
    |> cast(params, ~w[name password]a)
    |> cast_embed(:tasks, with: &Task.changeset/2)
    |> validate_required(~w[name]a)
  end

  def create(params) when is_list(params),
    do: params |> Map.new() |> create()

  def create(%{} = params) do
    __MODULE__
    |> struct
    |> changeset(params)
    |> apply_action(:insert)
  end

  def create_default do
    create(
      name: "John",
      password: "secret"
    )
  end
end
