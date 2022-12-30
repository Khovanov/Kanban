defmodule Kanban.TaskFSM do
  @moduledoc """
  Task FSM implementation

  ## Examples

      iex> {:ok, pid} = Kanban.TaskFSM.start_link(%Kanban.Data.Task{state: "idle"})
      iex> Kanban.TaskFSM.start(pid)
      :ok
      iex> Kanban.TaskFSM.state(pid)
      "doing"
      iex> Kanban.TaskFSM.finish(pid)
      :ok
      iex> Kanban.TaskFSM.drop(pid)
      :ok

  """

  use GenServer

  alias Kanban.Data.Task

  require Logger

  @doc """
  Start and link process.
  """
  def start_link(%Task{state: "idle"} = task) do
    GenServer.start_link(__MODULE__, task)
  end

  @doc """
  start task
  """
  def start(pid) do
    GenServer.cast(pid, {:transition, :start})
  end

  @doc """
  finish task
  """
  def finish(pid) do
    GenServer.cast(pid, {:transition, :finish})
  end

  @doc """
  drop task - stop process
  """
  def drop(pid) do
    GenServer.cast(pid, {:transition, :drop})
  end

  @doc """
  see task state
  """
  def state(pid) do
    GenServer.call(pid, :state)
  end

  @doc """
  Callback function for GenServer.init/1
  """
  @impl GenServer
  def init(task) do
    Logger.info(pid: self(), state: task.state)

    {:ok, task}
  end

  @doc """
  Callback function for GenServer.handle_cast/2

  send transition into task
  """
  @impl GenServer
  def handle_cast({:transition, :start}, %Task{state: "idle"} = task) do
    # Save to external storage
    Logger.info(pid: self(), state: "doing")
    {:noreply, %Task{task | state: "doing"}}
  end

  def handle_cast({:transition, :finish}, %Task{state: "doing"} = task) do
    # Save to external storage
    Logger.info(pid: self(), state: "done")
    {:noreply, %Task{task | state: "done"}}
  end

  def handle_cast({:transition, :drop}, %Task{state: "done"} = task) do
    # Remove from external storage
    Logger.info(pid: self(), msg: "Task dropped")
    {:stop, :normal, task}
  end

  def handle_cast({:transition, transition}, %Task{state: state} = task) do
    Logger.warn(pid: self(), error: {:not_allowed, transition, state})
    {:noreply, task}
  end

  @doc """
  Callback function for GenServer.handle_call/3

  show task state
  """
  @impl GenServer
  def handle_call(:state, _from, %Task{state: state} = task) do
    {:reply, state, task}
  end
end
