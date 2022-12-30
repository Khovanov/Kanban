defmodule Kanban.Data.TaskTest do
  use ExUnit.Case, async: true

  alias Kanban.Data.{Task}

  describe "create/1" do
    test "success: task with idle state created" do
      params = %{
        title: "Task title",
        due: ~U[2023-01-04 08:51:19Z],
        project: %{title: "Project title"},
        user: %{name: "Name", password: "secret"}
      }

      assert {:ok,
              %Task{
                title: "Task title",
                due: ~U[2023-01-04 08:51:19Z],
                project: %{},
                user: %{},
                state: "idle"
              }} = Task.create(params)
    end

    test "failure: with empty params task is not created" do
      assert {:error, %Ecto.Changeset{valid?: false}} = Task.create(%{})
    end
  end

  describe "update_user/2" do
    setup do
      params = %{
        title: "Task title",
        due: ~U[2023-01-04 08:51:19Z],
        project: %{title: "Project title"},
        user: %{name: "Petr", password: "pwd"}
      }

      {:ok, task} = Task.create(params)

      {:ok, task: task}
    end

    test "success: update task", %{task: task} do
      assert {:ok,
              %Task{
                user: %{name: "Ivan", password: "secret"}
              }} = Task.update_user(task, "Ivan", "secret")
    end
  end
end
