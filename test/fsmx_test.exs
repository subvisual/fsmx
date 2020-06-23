defmodule FsmxTest do
  use ExUnit.Case
  doctest Fsmx

  alias Fsmx.TestStructs.{Simple, WithCallbacks}

  describe "transition/2" do
    test "can do simple transitions" do
      one = %Simple{state: "1"}

      {:ok, two} = Fsmx.transition(one, "2")

      assert %Simple{state: "2"} = two

      {:ok, three} = Fsmx.transition(two, "3")

      assert %Simple{state: "3"} = three
    end

    test "fails to perform invalid transitions" do
      one = %Simple{state: "1"}

      assert {:error, msg} = Fsmx.transition(one, "3")

      assert msg == "invalid transition of Elixir.Fsmx.TestStructs.Simple from 1 to 3"
    end
  end

  describe "transition/2 with callbacks" do
    test "calls before_transition/2 on struct" do
    end
  end
end
