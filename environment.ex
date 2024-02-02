defmodule Env do

  def new() do [] end

  def add(id, str, env) do
    EnvList.add(env, id, str)
  end

  def lookup(id, env) do
    EnvList.lookup(env, id)
  end

  def remove(ids, env) do
    EnvList.remove()
  end

# {:atm, :a}
# {{:atm, :a}, {{:var, x}, {:atm, :b}}}

#{:var, x}

end

defmodule Eager do

  def eval_expr({:atm, id}, _) do {:ok, id}  end

  def eval_expr({:var, id}, env) do
    case EnvList.lookup(env, id) do
      nil ->
        :error
      {_, str} ->
        {:ok, str}
    end

  end

  def eval_expr({:cons, e1, e2}, env) do
    case eval_expr(e1, env) do
      :error ->
        :error
      {:ok, result_e1} ->
        case eval_expr(e2, env) do
          :error ->
            :error
          {:ok, result_e2} ->
            {:ok, {result_e1, result_e2}}
        end
    end
  end


  def eval_match(:ignore, _, env) do
    {:ok, env}
  end

  def eval_match({:atm, id}, id, env) do
    {:ok, env}
  end

  def eval_match({:var, id}, str, env) do
    case EnvList.lookup(env, id) do
      nil ->
        {:ok, EnvList.add(env, id, str)}
      {_, ^str} ->
        {:ok, env}
      {_, _} ->
        :fail
    end
  end

  def eval_match({:cons, hp, tp}, {hs, ts}, env) do
    case eval_match(hp, hs, env) do
      :fail ->
        :fail
      {:ok, env} ->
        eval_match(tp, ts, env)
    end
  end


  def eval_match(_, _, _) do
    :fail
  end



end
