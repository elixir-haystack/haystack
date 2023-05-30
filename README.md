# Haystack

<!-- MDOC !-->

[![Build Status](https://github.com/elixir-haystack/haystack/actions/workflows/ci.yml/badge.svg)](https://github.com/elixir-haystack/haystack/actions) [![Coverage Status](https://coveralls.io/repos/github/elixir-haystack/haystack/badge.svg?branch=main)](https://coveralls.io/github/elixir-haystack/haystack?branch=main)

**Haystack is a simple, extendable search engine written in Elixir.**

## Installation

Haystack can be installed by adding `haystack` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:haystack, "~> 0.1.0"}
  ]
end
```

The entry point to Haystack is the `Haystack` module. This module is responsible for managing the various indexes you have as part of the project as well as any future configuration or high level concerns.

These concerns are encapsulated in the `%Haystack{}` struct:

```elixir
haystack = Haystack.new()
```

Currently, the `Haystack` module has a single `index/3` function that accepts the name of the index as an atom and a callback function to apply changes to the index. If the index does not already exist, Haystack will create one and pass it into the callback so you can configure or use it:

```elixir
Haystack.index(haystack, :animals, fn index ->
  index
end)
```

Once you have an `index`, the first thing you need to do is specify the fields of the index:

```elixir
alias Haystack.Index

Haystack.index(haystack, :animals, fn index ->
  index
  |> Index.ref(Index.Field.term("id"))
  |> Index.field(Index.Field.new("name"))
  |> Index.field(Index.Field.new("description"))
end)
```

The `ref` is the identifier of the document. You can create as many fields on the document as you want. When you add documents to the index, Haystack will automatically extract the fields you have configured.

You can also provide nested fields using dot syntax:

```elixir
alias Haystack.Index

Haystack.index(haystack, :people, fn index ->
  index
  |> Index.ref(Index.Field.term("id"))
  |> Index.field(Index.Field.new("name"))
  |> Index.field(Index.Field.new("address.postcode"))
end)
```

Each Haystack index has a configurable storage implementation. By default the storage implementation is essentially a map, which is great for testing and prototyping, but probably not a good solution if you want to use Haystack as part of a real application. You can configure a custom storage implementation on the index:

```elixir
alias Haystack.{Index, Storage}

Haystack.index(haystack, :animals, fn index ->
  index
  |> Index.ref(Index.Field.term("id"))
  |> Index.field(Index.Field.new("name"))
  |> Index.field(Index.Field.new("description"))
  |> Index.storage(Storage.ETS.new())
end)
```

The ETS storage implementation is provided as one of the default implementations that ships with Haystack out of the box. If you would like to extend Haystack with your own storage implementation, it's very easy to do so.

Finally, the most important part of a library that provides full-text search is the ability to query the indexes. Here is the most basic version of applying queries:

```elixir
Haystack.index(haystack, :animals, &Index.search(&1, "Red Panda"))
```

This would search the `:animals` index for the phrase `"Red Panda"`. Haystack also offers a powerful way to build and run search queries.
