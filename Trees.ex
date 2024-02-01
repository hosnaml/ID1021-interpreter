defmodule EnvList do


  def new() do
    []
  end

  def add(list, key, value) do
    [{key, value}|list]
    #list ++ {key, value}
  end

  #? If the element is found.
  def lookup([{key, value}|_], key) do
    {key, value}
  end

  #? This base case is for when you reach the last one
  #? and the list is empty in the arguments.
  def lookup([] ,key) do
    :nil
  end

  def lookup([h | t] ,key) do
    lookup(t, key)
  end

  def remove(map, key) do
    remove(map, key, [])
  end

  def remove([{key, _} | t], key, coll) do
    coll ++ t
  end

  def remove([], key, _) do
    :nil
  end

  def remove([h | t], key, coll) do
    remove(t, key, [h | coll])
  end

end



defmodule EnvTree do


  def new() do
    {}
  end

  #Base case for empty node or a leaf.
  def add(nil, key, value) do
    {:node,key,value,nil,nil}
  end

  def add({:node, nil, _, _, _} = node, nil, value) do
    {:node, nil, value, nil, nil}
  end

  def add({}, key, value) do
    {:node,key,value,nil,nil}
  end

  def add({:node, key, _, left, right}, key, value) do
    {:node, key, value, left, right}
  end

  def add({:node, k, v, left, right}, key, value) when key < k do
    {:node, k, v, add(left, key, value), right}
  end

  def add({:node, k, v, left, right}, key, value) when key > k do
    {:node, k, v, left , add(right, key , value)}
  end



  #The base case.
  def lookup(nil, key) do
    nil
  end

  def lookup({:node, key, value, left, right}, key) do
    {key, value}
  end
  #If we didn't find it in root, we go left.
  def lookup({:node, k, _, left, right}, key) when key < k do
    lookup(left,key)
  end

  def lookup({:node, k, _, left, right}, key)  do
    lookup(right,key)
  end

  def remove(nil, _) do  nil  end

  #?The right one with no left matches the key then the right one
  #?comes up and replace the one mathcing so that right branch ia returned
  #?and is gonna be replaced in the other function.
  def remove({:node, key, _, nil, right}, key) do right end


  def remove({:node, key, _, left, nil}, key) do left end


  def remove({:node, key, _, left, right}, key)  do
    {key, value, rest} = leftmost(right)
    {:node,key, value, left, rest }
  end


  def remove({:node, k, v, left, right}, key) when key < k do
     {:node, k, v, remove(left, key), right}
  end


  def remove({:node, k, v, left, right}, key) do
     {:node, k, v, left, remove(right, key)}
  end



  def leftmost({:node, key, value, nil, rest}) do
    {key, value, rest}
  end

  def leftmost({:node, k, v, left, right}) do
    {key, value, rest} = leftmost(left)
    {key, value, {:node, k, v, rest, right}}

  end


end
