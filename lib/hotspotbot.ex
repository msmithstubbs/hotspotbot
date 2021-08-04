defmodule Hotspotbot do
  @moduledoc """
  Documentation for `Hotspotbot`.
  """

  @url "https://www.qld.gov.au/health/conditions/health-alerts/coronavirus-covid-19/current-status/contact-tracing"

  @doc """
  Hello world.

  ## Examples

      iex> Hotspotbot.hello()
      :world

  """
  def hello do
    :world
  end

  def run do
    with {:ok, response} <- HTTPoison.get(@url),
         {:ok, document} <- Floki.parse_document(response.body) do
      extract(document)
      |> IO.inspect()
    end
  end

  def extract(document) do
    [
      close: "div[id^=qld_close_contacts_table] table",
      casual: "div[id^=qld_casual] table",
      low_risk: "div[id^=qld_low_risk] table"
    ]
    |> Enum.map(fn {key, selector} ->
      data =
        Floki.find(document, selector)
        |> parse_table()

      {key, data}
    end)
  end

  def parse_table(table) do
    table
    |> Floki.find("tbody > tr")
    |> Enum.map(fn tr ->
      %{
        date: Floki.attribute(tr, "data-date") |> Enum.join(" "),
        lgas: Floki.attribute(tr, "data-lgas") |> Enum.join(" "),
        location: Floki.attribute(tr, "data-location") |> Enum.join(" ") |> URI.decode(),
        address: Floki.attribute(tr, "data-address") |> Enum.join(" ") |> URI.decode(),
        suburb: Floki.attribute(tr, "data-suburb") |> Enum.join(" ") |> URI.decode(),
        datetext: Floki.attribute(tr, "data-datetext") |> Enum.join(" ") |> URI.decode(),
        timetext: Floki.attribute(tr, "data-timetext") |> Enum.join(" ") |> URI.decode(),
        added: Floki.attribute(tr, "data-added") |> Enum.join(" ")
      }
    end)
  end
end
