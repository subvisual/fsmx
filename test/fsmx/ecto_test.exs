defmodule Fsmx.EctoTest do
  use Fsmx.EctoCase

  alias Ecto.Multi
  alias Fsmx.Repo
  alias Fsmx.TestEctoSchemas.{Simple, WithCallbacks, WithSeparateFsm, MultiState}

  describe "transition_changeset/2" do
    test "returns a changeset" do
      one = %Simple{state: "1"}

      two_changeset = Fsmx.transition_changeset(one, "2", [])

      assert %Ecto.Changeset{} = two_changeset
    end

    test "returns a changeset with atom state" do
      one = %Simple{state: "2"}

      changeset = Fsmx.transition_changeset(one, :"3", [])

      assert %Ecto.Changeset{} = changeset
    end

    test "does not change the state directly" do
      one = %Simple{state: "1"}

      two_changeset = Fsmx.transition_changeset(one, "2", [])

      assert two_changeset.data.state == "1"
    end

    test "includes a change of the state field" do
      one = %Simple{state: "1"}

      two_changeset = Fsmx.transition_changeset(one, "2", [])

      assert Ecto.Changeset.get_change(two_changeset, :state) == "2"
    end

    test "works the same with multiple states" do
      one = %MultiState{state: "1", other_state: "1"}

      two_changeset = Fsmx.transition_changeset(one, "2", [], field: :other_state)

      assert Ecto.Changeset.get_change(two_changeset, :other_state) == "2"
    end
  end

  describe "transition/2 with callbacks" do
    test "calls before_transition/3 on struct" do
      one = %WithCallbacks.ValidBefore{state: "1", before: false}

      two = Fsmx.transition_changeset(one, "2")

      assert %WithCallbacks.ValidBefore{before: "1"} = two.data
    end

    test "fails if before_transition/3 returns an error" do
      one = %WithCallbacks.InvalidBefore{state: "1", before: false}

      changeset = Fsmx.transition_changeset(one, "2")

      refute changeset.valid?
      assert changeset.errors == [state: {"transition_changeset failed: before_failed", []}]
    end

    test "call before_transition/4 on struct with new state" do
      one = %WithCallbacks.MultiStateValidBefore{state: "1", other_state: "1", before: false}

      two = Fsmx.transition_changeset(one, "2")
      assert %WithCallbacks.MultiStateValidBefore{before: "1"} = two.data

      new_two = Fsmx.transition_changeset(one, "2", %{}, field: :other_state)
      assert %WithCallbacks.MultiStateValidBefore{before: "2"} = new_two.data
    end
  end

  describe "transition/2 with separate fsm module" do
    test "works just the same" do
      one = %WithSeparateFsm{state: "1"}

      two = Fsmx.transition_changeset(one, "2")

      assert %WithSeparateFsm{before: "1"} = two.data
    end
  end

  describe "transition_multi/5" do
    test "adds a transition changeset to the given multi" do
      one = %Simple{state: "1"}

      multi = Fsmx.transition_multi(Multi.new(), one, "transition", "2")

      assert %Ecto.Multi{operations: operations} = multi

      assert [_, {"transition", {:changeset, two_changeset, []}}] = operations
      assert %Ecto.Changeset{} = two_changeset
      assert two_changeset.data.state == "1"
      assert Ecto.Changeset.get_change(two_changeset, :state) == "2"
    end

    test "adds a run callback to the given multi" do
      one = %Simple{state: "1"}

      multi =
        Multi.new()
        |> Fsmx.transition_multi(one, "transition", "2")

      assert %Ecto.Multi{operations: operations} = multi
      assert [{"transition-callback", {:run, _}}, _] = operations
    end

    test "transitions the schema when running the multi" do
      {:ok, schema} = %Simple{state: "1"} |> Repo.insert()

      Multi.new()
      |> Fsmx.transition_multi(schema, "transition", "2")
      |> Repo.transaction()

      updated_schema = Repo.get(Simple, schema.id)

      assert %Simple{state: "2"} = updated_schema
    end

    test "calls after_transition_multi/3 callbacks" do
      {:ok, schema} = %WithCallbacks.ValidAfterMulti{state: "1"} |> Repo.insert()

      Multi.new()
      |> Fsmx.transition_multi(schema, "transition", "2")
      |> Repo.transaction()

      updated_schema = Repo.get(WithCallbacks.ValidAfterMulti, schema.id)

      assert %WithCallbacks.ValidAfterMulti{state: "2"} = updated_schema
      assert_receive :after_transition_multi_called
    end

    test "transaction is rolled back if after_transition_multi/3 callback fails" do
      {:ok, schema} = %WithCallbacks.InvalidAfterMulti{state: "1"} |> Repo.insert()

      result =
        Multi.new()
        |> Fsmx.transition_multi(schema, "transition", "2")
        |> Repo.transaction()

      assert {:error, "transition-callback", :after_transition_multi_failed, _} = result

      updated_schema = Repo.get(WithCallbacks.InvalidAfterMulti, schema.id)

      assert %WithCallbacks.InvalidAfterMulti{state: "1"} = updated_schema
    end

    test "adds a transition changeset to the given multi for a new state" do
      one = %MultiState{state: "1", other_state: "1"}

      multi = Fsmx.transition_multi(Multi.new(), one, "transition", "2", %{}, field: :other_state)

      assert %Ecto.Multi{operations: operations} = multi

      assert [_, {"transition", {:changeset, two_changeset, []}}] = operations
      assert %Ecto.Changeset{} = two_changeset
      assert two_changeset.data.other_state == "1"
      assert Ecto.Changeset.get_change(two_changeset, :other_state) == "2"
    end
  end
end
