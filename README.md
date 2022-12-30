# Kanban

**Simple kanban implementation**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `kanban` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:kanban, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/kanban](https://hexdocs.pm/kanban).

## Examples

```shell

iex -S mix

```

### Schemas

```elixir

alias Kanban.Data.{Project, Task, User, Issue}

# Create new default project
project = Project.create_default

# Create new default user
user = User.create_default

# Create new default task
{:ok, task} = Task.create_default

# update task user
Task.update_user(task, "New user", "new pwd")

# Create new default issue
issue = Issue.create_default


```

### Task transitions for finite-state machine (FSM)

```elixir
{:ok, task} = Task.create_default

# run process
{:ok, pid} = Kanban.TaskFSM.start_link(task)
# [info]  [pid: #PID<0.252.0>, state: "idle"]

# start task
Kanban.TaskFSM.start(pid)
# [info]  [pid: #PID<0.252.0>, state: "doing"]
# :ok

# check state
Kanban.TaskFSM.state(pid)
# "doing"

# finish task
Kanban.TaskFSM.finish(pid)
# [info]  [pid: #PID<0.252.0>, state: "done"]
# :ok

# check state
Kanban.TaskFSM.state(pid)
# "done"

# try wrong transition
Kanban.TaskFSM.start(pid)
# [warn]  [pid: #PID<0.252.0>, error: {:not_allowed, :start, "done"}]

# drop task
Kanban.TaskFSM.drop(pid)
# [info]  [pid: #PID<0.252.0>, msg: "Task dropped"]

Process.alive? pid
# false

```
### Issue transitions for finite-state machine (FSM)

```elixir

{:ok, issue} = Issue.create_default

# Cancel branch:
# run process
{:ok, pid} = Kanban.IssueFSM.start_link(issue)
# [info]  [pid: #PID<0.338.0>, state: "pending"]

# cancel issue
Kanban.IssueFSM.cancel(pid)
#  [info]  [pid: #PID<0.338.0>, state: "canceled"]
# :ok

# check state
Kanban.IssueFSM.state(pid)
# "canceled"

# drop task
Kanban.IssueFSM.drop(pid)
# [info]  [pid: #PID<0.338.0>, msg: "Issue dropped"]

Process.alive? pid
# false

# Resolve branch:
# run process
{:ok, pid} = Kanban.IssueFSM.start_link(issue)
# [info]  [pid: #PID<0.347.0>, state: "pending"]

# start issue
Kanban.IssueFSM.start(pid)
# [info]  [pid: #PID<0.347.0>, state: "progress"]
# :ok

# check state
Kanban.IssueFSM.state(pid)
# "progress"

# resolve issue
Kanban.IssueFSM.resolve(pid)
# [info]  [pid: #PID<0.347.0>, state: "resolved"]
# :ok

# check state
Kanban.IssueFSM.state(pid)
# "resolved"

# try wrong transition
Kanban.IssueFSM.cancel(pid)
# [warn]  [pid: #PID<0.347.0>, error: {:not_allowed, :cancel, "resolved"}]

# drop task
Kanban.IssueFSM.drop(pid)
#  [info]  [pid: #PID<0.347.0>, msg: "Issue dropped"]

Process.alive? pid
# false

```

## Testing

```shell

mix test

```

## Static code analysis

```shell

mix credo

```

## Check vulnerabilities

```shell

mix deps.audit

```
