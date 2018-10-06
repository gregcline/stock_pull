defmodule FetchInfo do
  HTTPoison.start()

  def fetch_info(file) do
    info =
      file
      |> StockMarket.get_symbols()
      |> Task.async_stream(&StockMarket.query_site/1)
      |> StockMarket.format_results()

    Path.expand("./companies_by_perf.csv")
    |> File.write!("symbol,year,quarter\n" <> info)
  end
end

FetchInfo.fetch_info("./companylist.csv")
