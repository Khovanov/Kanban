defmodule Kanban.Data.ProjectTest do
  use ExUnit.Case, async: true

  alias Kanban.Data.{Project}

  describe "create/1" do
    test "success: project created" do
      params = %{
        title: "Title"
      }

      assert {:ok, %Project{title: "Title"}} = Project.create(params)
    end

    test "failure: with empty params project is not created" do
      assert {:error, %Ecto.Changeset{valid?: false}} = Project.create(%{})
    end
  end
end
