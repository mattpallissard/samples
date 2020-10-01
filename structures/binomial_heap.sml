Control.Print.printDepth := 100;

signature ORDERED =
sig
  type T
  val eq    : T * T -> bool
  val lt    : T * T -> bool
  val leq   : T * T -> bool
end

structure OrderedInt: ORDERED =
struct
  type T = int
  val eq = (op =)
  val lt = (op <)
  val leq = (op >)
  val sub = (op -)
end

signature HEAP =
sig
  structure Elem: ORDERED
  type Heap
  type Tree
  val empty   : Heap
  val isEmpty : Heap -> bool
  val rank    : Tree -> int
  val root    : Tree -> Elem.T
  val link    : Tree * Tree -> Tree
  val findMin : Heap -> Elem.T
  val findMin2 : Heap -> Elem.T
  val insert  : Elem.T * Heap -> Heap
end

functor BinomialHeap(Element: ORDERED): HEAP =
struct
  structure Elem = Element
  datatype Tree = Node of int * Elem.T * Tree list
  type Heap = Tree list

  val empty = []
  fun isEmpty i = null i

  fun rank(Node(r, x, c)) = r
  fun root(Node(r, x, c)) = x

  fun link(t1 as Node(r1, x1, c1), t2 as Node(_, x2, c2)) =
    if Elem.leq(x1, x2) then Node(r1+1, x1, t2 :: c1)
    else Node(r1+1, x2, t1 :: c2)

  fun insTree(t, []) = [t]
    | insTree(t, ts as t' :: ts') =
    if rank t < rank t' then t :: ts else insTree(link(t, t'), ts')

  fun insert(x, ts) = insTree(Node(0, x, []), ts)

  fun merge(ts1, []) = ts1
    | merge([], ts2) = ts2
    | merge(ts1 as t1 :: ts1', ts2 as t2 :: ts2') =
    if rank t1 < rank t2 then t1 :: merge (ts1', ts2)
    else if rank t2 < rank t1 then t2 :: merge (ts1, ts2')
    else insTree(link(t1, t2), merge (ts1', ts2'))

  fun removeMinTree [] = raise Empty
    | removeMinTree [t] = (t, [])
    | removeMinTree (t :: ts) =
    let val (t', ts') = removeMinTree ts
    in if Elem.leq (root t, root t') then (t, ts) else (t', t :: ts') end

  fun findMin ts =
    let
      val(t, _) = removeMinTree ts
    in root t end

  fun findMin2 [] = raise Empty
    | findMin2 [t] = root t
    | findMin2 (t::ts) =
      if Elem.leq (root t, findMin2 ts) then root t else findMin2 ts

  fun deleteMin ts =
    let val(Node(_, x, ts1), ts2) = removeMinTree ts
    in merge(rev ts1, ts2) end

end

structure I =  BinomialHeap(OrderedInt)
val i = I.insert(2,
        I.insert(0,
        I.insert(3,
        I.insert(1, I.empty))))


val j = I.findMin(i)
val k = I.findMin2(i)
