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

  #?To handle case expression.
  def eval_expr({:case, expr, cls}, env) do
    case eval_expr(expr, env) do
      :error ->
        :error
      {:ok, str} ->
        eval_cls(cls, str, env)
    end
  end

  def eval_cls([], _, _, _) do
    :error
  end

  def eval_cls([{:clause, ptr, seq} | cls], str, env) do

    case eval_match(ptr,str, eval_scope(ptr,env)) do
      :fail ->
        eval_cls(cls, str, env)
      {:ok, env} ->
        eval_seq(..., ...)
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

  def eval_scope(pattern, env) do
    EnvList.remove(extract_vars(pattern), env)
  end

  def eval_seq([exp], env) do
    eval_expr(exp, env)
  end

  def eval_seq([{:match, pattern, exp} | seq], env) do
    case eval_expr(exp, env) do
      :error ->
        :error
      {:ok, str} ->
        env = eval_scope(pattern, env)

        case eval_match(pattern, str, env ) do
          :fail ->
            :error
          {:ok, env} ->
            eval_seq(seq, env)
        end
    end
  end

  def extract_vars() do

  end


end
