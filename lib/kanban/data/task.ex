defmodule Kanban.Data.Task do
  @moduledoc """
  Task changeset
  """

  use Ecto.Schema

  alias Kanban.Data.{Project, User}

  import Ecto.Changeset

  @default_due_days 5

  @primary_key false
  embedded_schema do
    # field :id, :binary_id, autogenerate: &Ecto.UUID.generate/0
    field(:title, :string)
    field(:description, :string)
    field(:state, :string, default: "idle")
    field(:time_spent, :integer, default: 0)
    field(:due, :utc_datetime)
    embeds_one(:project, Project)
    embeds_one(:user, User, on_replace: :delete)
    # belongs_to :user, User
    # belongs_to :project, Project
  end

  def changeset(task, params) do
    task
    |> cast(params, ~w[title description due]a)
    |> cast_embed(:project, with: &Project.changeset/2)
    |> cast_embed(:user, with: &User.changeset/2)
    |> validate_required(~w[title due]a)
    |> validate_inclusion(:state, ~w[idle doing done]a)
  end

  def create(params) when is_list(params),
    do: params |> Map.new() |> create()

  def create(%{} = params) do
    __MODULE__
    |> struct
    |> changeset(params)
    |> apply_action(:insert)
  end

  def update_user(task, name, password) do
    task
    |> change(%{user: %{name: name, password: password}})
    |> apply_action(:update)
  end

  def create_default do
    create(
      title: "Task title",
      description: "Please description here",
      due: Timex.shift(Timex.now(), days: @default_due_days),
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
