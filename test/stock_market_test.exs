defmodule StockMarketTest do
  use ExUnit.Case
  doctest StockMarket

  test "greets the world" do
    assert StockMarket.hello() == :world
  end
end
