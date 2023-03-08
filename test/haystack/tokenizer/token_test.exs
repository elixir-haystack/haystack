defmodule Haystack.Tokenizer.TokenTest do
  use ExUnit.Case, async: true

  alias Haystack.Tokenizer.Token

  doctest Token

  describe "new/2" do
    test "should create token" do
      token = Token.new("abc", start: 0, length: 3)

      assert token.v == "abc"
      assert token.start == 0
      assert token.length == 3
    end
  end
end
