defmodule Haystack.Tokenizer.TokenTest do
  use ExUnit.Case, async: true

  alias Haystack.Tokenizer.Token

  doctest Token

  describe "new/2" do
    test "should create token" do
      token = Token.new("haystack", offset: 0, length: 8)

      assert token.v == "haystack"
      assert token.offset == 0
      assert token.length == 8
    end
  end
end
