defmodule Kanban.Data.IssueTest do
  use ExUnit.Case, async: true

  alias Kanban.Data.{Issue}

  describe "create/1" do
    test "success: issue with pending state created" do
      params = %{
        title: "Issue title",
        project: %{title: "Project title"},
        user: %{name: "Name", password: "secret"}
      }

      assert {:ok,
              %Issue{
                title: "Issue title",
                project: %{},
                user: %{},
                state: "pending"
              }} = Issue.create(params)
    end

    test "failure: with empty params issue is not created" do
      assert {:error, %Ecto.Changeset{valid?: false}} = Issue.create(%{})
    end
  end
end
