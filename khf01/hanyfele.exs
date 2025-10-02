defmodule Khf1 do

  @moduledoc """
  Hányféle módon állítható elő a célérték
  @author "Egyetemi Hallgató <egy.hallg@edu.bme.hu>"
  @date   "2025-09-xx"
  """
  @type ertek() :: integer() # az összeg előállítására felhasználható érték (0 < ertek)
  @type darab() :: integer() # az értékből rendelkezésre álló maximális darabszám (0 ≤ darabszám)
  @type ertekek() :: %{ertek() => darab()}

  @spec hanyfele(ertekek :: ertekek(), celertek :: integer()) :: ennyifele :: integer()
  # ennyifele a celertek összes különböző előállításainak száma ertekek felhasználásával
  def hanyfele(ertekek, celertek) do
    # A bárhányszor használható értékeket maximalizálom, hogy ha minden érték elfogyott leálhasson a rekurzió
    modositott_ertekek = Map.new(ertekek, fn {k,v} ->
      if v == 0, do: {k, div(celertek, k)}, else: {k, v}
    end)
    # Memoization-höz használt cache az alproblémáknak
    memo = Map.new()
    hanyfele(modositott_ertekek, celertek, memo)
  end

  # Rekurzió alapeset, sikerült összerakni a célértéket
  defp hanyfele(_ertekek, 0, _memo), do: 1
  # Nem jön ki a célérték
  defp hanyfele(_ertekek, celertek, _memo) when celertek < 0, do: 0
  # Elfogytak a felhasználható értékek, nem lehet semmit kitenni belőlük
  defp hanyfele(ertekek, celertek, memo) do
    if Map.has_key?(memo, {ertekek, celertek}) do
      Map.get(memo, {ertekek, celertek})
    else
      if Enum.all?(ertekek, fn {_ertek, db} -> db == 0 end) do
        0
      else
        eredmeny = ertekek
          |> Enum.reject(fn {_ertek, db} -> db == 0 end)
          |> Enum.reduce(0, fn {ertek, _db}, kombinaciok ->
            uj_celertek = celertek - ertek
            uj_ertekek = Map.update!(ertekek, ertek, fn db -> db - 1 end)
            kombinaciok + hanyfele(uj_ertekek, uj_celertek, memo)
          end)
        Map.put(memo, {ertekek, celertek}, eredmeny)
        eredmeny
      end
    end
  end
end
