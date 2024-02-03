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

  def closure(keys, env) do
    closure_recursive(keys, env, [])
  end

  def closure_recursive([], _, acc), do: [acc]
  def closure_recursive([key|rest], env, acc) do
    case lookup(env, key) do
      nil ->
        :error
      value ->
        closure_recursive(rest, env, [{key, value} | acc])
    end
  end



  def args(pars, args, env) do
    #list.zip addes the list as a tuple to the environment.
    list.zip([pars,args]) ++ env
  end


end

defmodule Prgm do
  def append() do
    {[:x, :y],
      [{:case, {:var, :x},
        [{:clause, {:atm, []}, [{:var, :y}]},
         {:clause, {:cons, {:var, :hd}, {:var, :tl}},
          [{:cons,
            {:var, :hd},
            {:apply, {:fun, :append}, [{:var, :tl}, {:var, :y}]}}]
          }]
      }]
    }
  end
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

  def eval_expr({:lambda, par, free, seq}, env) do
    case EnvList.closure(free, env) do
      :error ->
        :error
      closure ->
        {:ok, {:closure, par, seq, closure}}
    end
  end

  def eval_expr({:apply, expr, args}, env) do
    case eval_expr(expr, env) do
      :error ->
        :error
      {:ok, {:closure, par, seq, closure}} ->
        case eval_args(args, env)  do
          :error ->
            :error
          {:ok, strs} ->
            env = Env.args(par, strs, closure)
            eval_seq(seq, env)
        end
    end
  end

  def eval_expr({:fun, id}, env)  do
    {par, seq} = apply(Prgm, id, [])
    {:ok,  {:closure, par, seq, Env.new()}}
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

  @spec extract_vars(pattern) :: [variable]

  def extract_vars(pattern) do
    extract_vars(pattern, [])
  end

  @spec extract_vars(pattern, [variable]) :: [variable]

  def extract_vars({:atm, _}, vars) do vars end
  def extract_vars(:ignore, vars) do vars end
  def extract_vars({:var, var}, vars) do
    [var | vars]
  end
  def extract_vars({:cons, head, tail}, vars) do
    extract_vars(tail, extract_vars(head, vars))
  end






end
