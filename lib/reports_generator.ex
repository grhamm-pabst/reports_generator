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

  def get_unique_food_and_max_id(filename) do
    filename
    |> Parser.parse_files()
    |> Stream.map(fn [id, food, price] -> [String.to_integer(id), food, price] end)
    |> Enum.reduce(%{max_id: 0, unique_foods: []}, fn line, acc -> update_acc(line, acc) end)
  end

  defp update_acc([id, food, _price], acc) do
    acc =
      case acc[:max_id] < id do
        true -> Map.put(acc, :max_id, id)
        false -> acc
      end

    acc =
      case !Enum.member?(acc[:unique_foods], food) do
        true -> Map.put(acc, :unique_foods, acc[:unique_foods] ++ [food])
        false -> acc
      end

    acc
  end
end
