defmodule KanbanTest do
  use ExUnit.Case
  doctest Kanban

  test "greets the world" do
    assert Kanban.hello() == :world
  end
end
