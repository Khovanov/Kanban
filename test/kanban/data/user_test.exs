defmodule Kanban.Data.UserTest do
  use ExUnit.Case, async: true

  alias Kanban.Data.{User}

  describe "create/1" do
    test "success: user created" do
      params = %{
        name: "Name",
        password: "secret"
      }

      assert {:ok, %User{name: "Name", password: "secret"}} = User.create(params)
    end

    test "failure: with empty params user is not created" do
      assert {:error, %Ecto.Changeset{valid?: false}} = User.create(%{})
    end
  end
end
