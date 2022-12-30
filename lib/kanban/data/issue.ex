defmodule Kanban.Data.Issue do
  @moduledoc """
  Issue changeset
  """

  use Ecto.Schema

  alias Kanban.Data.{Project, User}

  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    # field :id, :binary_id, autogenerate: &Ecto.UUID.generate/0
    field(:title, :string)
    field(:description, :string)
    field(:state, :string, default: "pending")
    field(:priority, :string, default: "low")
    embeds_one(:project, Project)
    embeds_one(:user, User)
    # belongs_to :user, User
    # belongs_to :project, Project
  end

  def changeset(issue, params) do
    issue
    |> cast(params, ~w[title description priority]a)
    |> cast_embed(:project, with: &Project.changeset/2)
    |> cast_embed(:user, with: &User.changeset/2)
    |> validate_required(~w[title]a)
    |> validate_inclusion(:priority, ~w[low hi]s)
    |> validate_inclusion(:state, ~w[pending progress canceled resolved]a)
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
      title: "Issue title",
      description: "Please description here",
      project: build_default_params(Project),
      user: build_default_params(User)
    )
  end

  defp build_default_params(module) do
    module.create_default
    |> elem(1)
    |> Map.from_struct()
  end
end
