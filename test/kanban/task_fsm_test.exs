defmodule Kanban.TaskFSMTest do
  use ExUnit.Case, async: true
  doctest Kanban.TaskFSM

  alias Kanban.Data.Task
  alias Kanban.TaskFSM

  @sleep_test_ms 1

  setup do
    {:ok, pid} = TaskFSM.start_link(%Task{state: "idle"})

    {:ok, pid: pid}
  end

  describe "start/1" do
    test "returns :ok and change task state", %{pid: pid} do
      assert :ok == TaskFSM.start(pid)
      assert TaskFSM.state(pid) == "doing"
    end
  end

  describe "finish/1" do
    setup %{pid: pid} do
      TaskFSM.start(pid)
    end

    test "returns :ok and change task state", %{pid: pid} do
      assert :ok == TaskFSM.finish(pid)
      assert TaskFSM.state(pid) == "done"
    end
  end

  describe "drop/1" do
    setup %{pid: pid} do
      TaskFSM.start(pid)
      TaskFSM.finish(pid)
    end

    test "returns :ok and stop process", %{pid: pid} do
      assert :ok == TaskFSM.drop(pid)

      Process.sleep(@sleep_test_ms)

      assert Process.alive?(pid) == false
    end
  end
end
