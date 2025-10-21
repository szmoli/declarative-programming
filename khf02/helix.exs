defmodule Khf2 do
  @moduledoc """
  Számtekercs kiterítése
  @author "Szmoleniczki Ákos <szmoleniczki.akos@edu.bme.hu>"
  @date   "2025-10-04"
  """

  # Alapadatok
  # tábla mérete (0 < n)
  @type size() :: integer()
  # ciklus hossza (0 < m <= n)
  @type cycle() :: integer()
  # mező értéke (0 < v <= m vagy "")
  @type value() :: integer()

  # Mezőkoordináták
  # sor száma (1-től n-ig)
  @type row() :: integer()
  # oszlop száma (1-től n-ig)
  @type col() :: integer()
  # mező koordinátái
  @type field() :: {row(), col()}

  # Feladványleírók
  # mező és értéke
  @type field_value() :: {field(), value()}
  # mező és opcionális értéke
  @type field_opt_value() :: {field(), value() | nil}

  # 1. elem: méret, 2. elem: ciklushossz,
  @type list_desc() :: [String.t()]
  # többi elem esetleg: mezők és értékük

  @spec helix(ps :: list_desc()) :: gs :: [field_opt_value()]
  # A ps szöveges feladványleíró-lista szerinti számtekercs kiterített listája gs
  # Csak N és M adott
  def helix([size_str | [_cycle_str]]) do
    size = size_str |> String.trim() |> String.to_integer()
    Enum.reverse(helix(1, size, 1, size, %{}, []))
  end

  # N és M mellett valahány mező értéke is adott
  def helix([size_str | [_cycle_str | field_value_strs]]) do
    size = size_str |> String.trim() |> String.to_integer()
    # Bemenet: ["  x1  y1 v1 ", " x2     y2 v2", ...]
    # Kell: %{{x, y} => v}
    # Map-hez kell: [{{x, y}, v}, ...]
    field_values =
      field_value_strs
      |> Enum.map(&String.split/1)
      |> Enum.map(fn [row, col, val] ->
        {{String.to_integer(row), String.to_integer(col)}, String.to_integer(val)}
      end)
      |> Map.new()

    Enum.reverse(helix(1, size, 1, size, field_values, []))
  end

  @spec helix(top :: integer(), bottom :: integer(), left :: integer(), right :: integer(), field_values :: %{field_value() => integer()}, acc :: [field_opt_value()]) :: [field_opt_value()]
  # Iteratívan bejárjuk a mátrixot a külső rétegtől befelé
  # finito
  defp helix(top, bottom, left, right, field_values, acc) when bottom < top and right < left do
    acc
  end
  # 1x1
  defp helix(top, bottom, left, right, field_values, acc) when bottom - top == 0 and right - left == 0 do
    field = {top, left}
    [{field, Map.get(field_values, field)} | acc]
  end
  # 2x2
  defp helix(top, bottom, left, right, field_values, acc) when bottom - top == 1 and right - left == 1 do
    field1 = {top, left}
    field2 = {top, right}
    field3 = {bottom, right}
    field4 = {bottom, left}
    val1 = Map.get(field_values, field1)
    val2 = Map.get(field_values, field2)
    val3 = Map.get(field_values, field3)
    val4 = Map.get(field_values, field4)
    res1 = {field1, val1}
    res2 = {field2, val2}
    res3 = {field3, val3}
    res4 = {field4, val4}
    [res4|[res3|[res2|[res1|acc]]]]
  end
  # nagyobb
  defp helix(top, bottom, left, right, field_values, acc) do
    acc =
      left..right
      |> Enum.reduce(acc, fn col, acc ->
        [{{top, col}, Map.get(field_values, {top, col})} | acc]
      end)

    acc =
      (top + 1)..bottom
      |> Enum.reduce(acc, fn row, acc ->
        [{{row, right}, Map.get(field_values, {row, right})} | acc]
      end)

    acc =
      (right - 1)..left
      |> Enum.reduce(acc, fn col, acc ->
        [{{bottom, col}, Map.get(field_values, {bottom, col})} | acc]
      end)

    acc =
      (bottom - 1)..(top + 1)
      |> Enum.reduce(acc, fn row, acc ->
        [{{row, left}, Map.get(field_values, {row, left})} | acc]
      end)

    helix(top + 1, bottom - 1, left + 1, right - 1, field_values, acc)
  end
end
