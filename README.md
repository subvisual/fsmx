# Fsmx

[ecto-multi]: https://hexdocs.pm/ecto/Ecto.Multi.html
[bamboo]: https://github.com/thoughtbot/bamboo
[sage]: https://github.com/Nebo15/sage

A Finite-state machine implementation in Elixir, with opt-in Ecto friendliness.

Highlights:

- Plays nicely with both bare Elixir structs and Ecto changesets
- Ability to wrap transitions inside an Ecto.Multi for atomic updates
- Guides you in the right direction when it comes to [side effects](#a-note-on-side-effects)

---

- [Installation](#installation)
- [Usage](#usage)
  - [Simple state machine](#simple-state-machine)
  - [Callbacks before transitions](#callbacks-before-transitions)
  - [Validating transitions](#validating-transitions)
  - [Decoupling logic from data](#decoupling-logic-from-data)
- [Ecto support](#ecto-support)
  - [Transition changesets](#transition-changesets)
  - [Transition with Ecto.Multi](#transition-with-ecto-multi)
- [A note on side effects](#a-note-on-side-effects)
- [Contributing](#contributing)

## Installation

Add fsmx to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fsmx, "~> 0.2.0"}
  ]
end
```

## Usage

### Simple state machine

```elixir
defmodule App.StateMachine do
  defstruct [:state, :data]

  use Fsmx.Struct, transitions: %{
    "one" => ["two", "three"],
    "two" => ["three", "four"],
    "three" => "four",
    "four" => :*, # can transition to any state
    :* => ["five"] # can transition from any state to "five"
  }
end
```

Use it via the `Fsmx.transition/2` function:

```elixir
struct = %App.StateMachine{state: "one", data: nil}

Fsmx.transition(struct, "two")
# {:ok, %App.StateMachine{state: "two"}}

Fsmx.transition(struct, "four")
# {:error, "invalid transition from one to four"}
```

### Callbacks before transitions

You can implement a `before_transition/3` callback to mutate the struct when before a transition happens.
You only need to pattern-match on the scenarios you want to catch. No need to add a catch-all/do-nothing function at the
end (the library already does that for you).

```elixir
defmodule App.StateMachine do
  # ...

  def before_transition(struct, "two", _destination_state) do
    {:ok, %{struct | data: %{foo: :bar}}}
  end
end
```

Usage:

```elixir
struct = %App.StateMachine{state: "two", data: nil}

Fsmx.transition(struct, "three")
# {:ok, %App.StateMachine{state: "three", data: %{foo: :bar}}
```

### Validating transitions

The same `before_transition/3` callback can be used to add custom validation logic, by returning an `{:error, _}` tuple
when needed:

```elixir
defmodule App.StateMachine do
  # ...


  def before_transition(%{data: nil}, _initial_state, "four") do
    {:error, "cannot reach state four without data"}
  end
end
```

Usage:

```elixir
struct = %App.StateMachine{state: "two", data: nil}

Fsmx.transition(struct, "four")
# {:error, "cannot reach state four without data"}
```

### Decoupling logic from data

Since logic can grow a lot, and fall out of scope in your structs/schemas, it's often useful to separate
all that business logic into a separate module:

```elixir
defmodule App.StateMachine do
  defstruct [:state]

  use Fsmx.Struct, fsm: App.BusinessLogic
end

defmodule App.BusinessLogic do
  use Fsmx.Fsm, transitions: %{
    "one" => ["two", "three"],
    "two" => ["three", "four"],
    "three" => "four"
  }

  # callbacks go here now
  def before_transition(struct, "two", _destination_state) do
    {:ok, %{struct | data: %{foo: :bar}}}
  end

  def before_transition(%{data: nil}, _initial_state, "four") do
    {:error, "cannot reach state four without data"}
  end
end
```

### Multiple state machines in the same struct

Not all structs have a single state machine, sometimes you might need more,
using different fields for that effect. Here's how you can do it:

```elixir
defmodule App.StateMachine do
  defstruct [:state, :other_state, :data]

  use Fsmx.Struct, transitions: %{
    "one" => ["two", "three"],
    "two" => ["three", "four"],
    "three" => "four",
    "four" => :*, # can transition to any state
    :* => ["five"] # can transition from any state to "five"
  }

  use Fsmx.Struct,
    state_field: :other_state,
    transitions: %{
        "initial" => ["middle", "middle2"],
        "middle" => "middle2",
        :* => "final"
    }
end
```

Use it via the `Fsmx.transition/3` function:

```elixir
struct = %App.StateMachine{state: "one", other_state: "initial", data: nil}

Fsmx.transition(struct, "two")
# {:ok, %App.StateMachine{state: "two", other_state: "initial"}}

Fsmx.transition(struct, "final", field: :other_state)
# {:ok, %App.StateMachine{state: "one", other_state: "final"}}
```

## Ecto support

Support for Ecto is built in, as long as `ecto` is in your `mix.exs` dependencies. With it, you get the ability to
define state machines using Ecto schemas, and the `Fsmx.Ecto` module:

```elixir
defmodule App.StateMachineSchema do
  use Ecto.Schema

  schema "state_machine" do
    field :state, :string, default: "one"
    field :data, :map
  end

  use Fsmx.Struct, transitions: %{
    "one" => ["two", "three"],
    "two" => ["three", "four"],
    "three" => "four"
  }
end
```

You can then mutate your state machine in one of two ways:

### 1. Transition changesets

Returns a changeset that mutates the `:state` field (or `{:error, _}` if the transition is invalid).

```elixir
{:ok, schema} = %App.StateMachineSchema{state: "one"} |> Repo.insert()

Fsmx.transition_changeset(schema, "two")
# #Ecto.Changeset<changes: %{state: "two"}>
```

You can customize the changeset function, and again pattern match on specific transitions, and additional params:

```elixir
defmodule App.StateMachineSchema do
  # ...

  # only include sent data on transitions from "one" to "two"
  def transition_changeset(changeset, "one", "two", params) do
    # changeset already includes a :state field change
    changeset
    |> cast(params, [:data])
    |> validate_required([:data])
  end
```

Usage:

```elixir
{:ok, schema} = %App.StateMachineSchema{state: "one"} |> Repo.insert()

Fsmx.transition_changeset(schema, "two", %{"data"=> %{foo: :bar}})
# #Ecto.Changeset<changes: %{state: "two", data: %{foo: :bar}>
```

### 2. Transition with Ecto.Multi

**Note: Please read [a note on side effects](#a-note-on-side-effects) first. Your future self will thank you.**

If a state transition is part of a larger operation, and you want to guarantee atomicity of the whole operation, you can
plug a state transition into an [`Ecto.Multi`][ecto-multi]. The same changeset seen above will be used here:

```elixir
{:ok, schema} = %App.StateMachineSchema{state: "one"} |> Repo.insert()

Ecto.Multi.new()
|> Fsmx.transition_multi(schema, "transition-id", "two", %{"data" => %{foo: :bar}})
|> Repo.transaction()
```

When using `Ecto.Multi`, you also get an additional `after_transition_multi/3` callback, where you can append additional
operations the resulting transaction, such as dealing with side effects (but again, please know that [side effects are
tricky](#a-note-on-side-effects))

```elixir
defmodule App.StateMachineSchema do
  def after_transition_multi(schema, _from, "four") do
    Mailer.notify_admin(schema)
    |> Bamboo.deliver_later()

    {:ok, nil}
  end
end
```

Note that `after_transition_multi/3` callbacks still run inside the database transaction, so be careful with expensive
operations. In this example `Bamboo.deliver_later/1` (from the awesome [Bamboo][bamboo] package) doesn't spend time sending the actual email, it just spawns a task to do it asynchronously.

## A note on side effects

Side effects are tricky. Database transactions are meant to guarantee atomicity, but side effects often touch beyond the
database. Sending emails when a task is complete is a straight-forward example.

When you run side effects within an `Ecto.Multi` you need to be aware that, should the transaction later be rolled
back, there's no way to un-send that email.

If the side effect is the last operation within your `Ecto.Multi`, you're probably 99% fine, which works for a lot of cases.
But if you have more complex transactions, or if you do need 99.9999% consistency guarantees (because, let's face
it, 100% is a pipe dream), then this simple library might not be for you.

Consider looking at [`Sage`][sage], for instance.

```elixir
# this is *probably* fine
Ecto.Multi.new()
|> Fsmx.transition_multi(schema, "transition-id", "two", %{"data" => %{foo: :bar}})
|> Repo.transaction()

# this is dangerous, because your transition callback
# will run before the whole database transaction has run
Ecto.Multi.new()
|> Fsmx.transition_multi(schema, "transition-id", "two", %{"data" => %{foo: :bar}})
|> Ecto.Multi.update(:update, a_very_unreliable_changeset())
|> Repo.transaction()
```

## Contributing

Feel free to contribute. Either by opening an issue, a Pull Request, or contacting the
[team](mailto:miguel@subvisual.com) directly

If you found a bug, please open an issue. You can also open a PR for bugs or new
features. PRs will be reviewed and subject to our style guide and linters.

# About

`Fsmx` is maintained by [Subvisual](http://subvisual.com).

[<img alt="Subvisual logo" src="https://raw.githubusercontent.com/subvisual/guides/master/github/templates/subvisual_logo_with_name.png" width="350px" />](https://subvisual.com)
