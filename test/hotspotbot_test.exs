defmodule HotspotbotTest do
  use ExUnit.Case
  doctest Hotspotbot

  test "greets the world" do
    assert Hotspotbot.hello() == :world
  end
end
