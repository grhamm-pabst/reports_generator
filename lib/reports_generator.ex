defmodule ReportsGenerator do
  alias ReportsGenerator.Parser

  @options ["foods", "users"]

  @avaiable_foods [
    "açaí",
    "churrasco",
    "esfirra",
    "hambúrguer",
    "pastel",
    "pizza",
    "prato_feito",
    "sushi"
  ]
  def build(filename) do
    filename
    |> Parser.parse_files()
    |> Enum.reduce(report_acc(), fn line, report ->
      sum_values(line, report)
    end)
  end

  def build_from_many(filenames) when not is_list(filenames) do
    {:error, "Please provide a list of reports"}
  end

  def build_from_many(filenames) do
    result =
      filenames
      |> Task.async_stream(&build/1)
      |> Enum.reduce(report_acc(), fn {:ok, result}, report -> sum_reports(report, result) end)

    {:ok, result}
  end

  def fetch_higher_cost(report, option) when option in @options,
    do: {:ok, Enum.max_by(report[option], fn {_id, value} -> value end)}

  def fetch_higher_cost(_report, _option), do: {:error, "Invalid option"}

  defp sum_values([id, food_name, price], %{"foods" => foods, "users" => users}) do
    users = Map.put(users, id, users[id] + price)
    foods = Map.put(foods, food_name, foods[food_name] + 1)

    build_report(foods, users)
  end

  defp sum_reports(
         %{"foods" => foods1, "users" => users1},
         %{"foods" => foods2, "users" => users2}
       ) do
    foods = merge_maps(foods1, foods2)
    users = merge_maps(users1, users2)

    build_report(foods, users)
  end

  defp merge_maps(map_1, map_2) do
    Map.merge(map_1, map_2, fn _key, value1, value2 -> value1 + value2 end)
  end

  defp report_acc do
    users = Enum.into(1..30, %{}, &{Integer.to_string(&1), 0})
    foods = Enum.into(@avaiable_foods, %{}, &{&1, 0})
    build_report(foods, users)
  end

  defp build_report(foods, users), do: %{"foods" => foods, "users" => users}

  # defp get_max_user_id(filename) do
  #   filename
  #   |> Parser.parse_files()
  #   |> Enum.map(fn [id, _food_name, _price] -> String.to_integer(id) end)
  #   |> Enum.max()
  # end

  # defp get_food_names(filename) do
  #   filename
  #   |> Parser.parse_files()
  #   |> Enum.map(fn [_id, food_name, _price] -> food_name end)
  #   |> Enum.uniq()
  # end
end
