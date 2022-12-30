defmodule Kanban.Data.Project do
  @moduledoc """
  Project changeset
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Kanban.Data.Task

  @primary_key false
  embedded_schema do
    # field :id, :binary_id, autogenerate: &Ecto.UUID.generate/0
    field(:title, :string)
    field(:description, :string)
    embeds_many(:tasks, Task)
    # has_many :tasks, Task
  end

  def changeset(project, params) do
    project
    |> cast(params, ~w[title description]a)
    # |> cast_assoc(:tasks, with: &Task.changeset/2)
    |> validate_required(~w[title]a)
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
      title: "Project title",
      description: "Please description here"
    )
  end
end
