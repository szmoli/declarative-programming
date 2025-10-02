defmodule Khf1 do
  def hanyfele(ertekek, celertek) do
    dp = List.duplicate(0, celertek + 1) |> List.replace_at(0, 1)

    Enum.reduce(ertekek, dp, fn {coin, count}, dp_acc ->
      if count == 0 do
        # Unlimited coin - forward iteration
        for amount <- coin..celertek, reduce: dp_acc do
          acc -> List.update_at(acc, amount, &(&1 + Enum.at(acc, amount - coin)))
        end
      else
        # Limited coin - backward iteration
        for amount <- celertek..0//-1, reduce: dp_acc do
          acc when amount >= coin ->
            ways =
              Enum.reduce(1..min(count, div(amount, coin)), 0, fn k, sum ->
                sum + Enum.at(acc, amount - k * coin)
              end)

            List.update_at(acc, amount, &(&1 + ways))

          acc ->
            acc
        end
      end
    end)
    |> Enum.at(celertek)
  end
end
