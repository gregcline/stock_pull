defmodule StockMarket do
  alias HTTPoison, as: HTTP
  alias HTTPoison.Response, as: Response

  @moduledoc """
  Documentation for StockMarket.
  """

  def get_symbols(file) do
    file
    |> Path.expand()
    |> File.stream!()
    |> CSV.decode(headers: true)
    |> Stream.map(fn {:ok, %{"Symbol" => symbol}} -> symbol end)
  end

  def query_site(symbol) do
    with {:ok, %Response{status_code: 200, body: body}} <-
           HTTP.get("https://www.finviz.com/quote.ashx?t=#{symbol}", [],
             ssl: [{:versions, [:"tlsv1.2"]}]
           ),
         %{"year" => year} <- Regex.named_captures(~r/Perf Year.+>(?<year>.+?)%<\/span>/, body),
         %{"quarter" => quarter} <-
           Regex.named_captures(~r/Perf Quarter.+>(?<quarter>.+?)%<\/span>/, body) do
      %{symbol: symbol, year: String.to_float(year), quarter: String.to_float(quarter)}
    else
      _ -> :error
    end
  end

  def format_results(results) do
    results
    |> Stream.map(fn {:ok, map} -> map end)
    |> Stream.filter(fn x -> x != :error end)
    |> Stream.filter(fn %{year: year, quarter: quarter} ->
      year >= 100 and quarter >= 25
    end)
    |> Enum.sort(fn m1, m2 -> m1.year >= m2.year end)
    |> Stream.map(fn %{symbol: s, year: y, quarter: q} -> [s, y, q] end)
    |> CSV.encode(delimiter: "\n")
    |> Enum.join("")
  end
end
