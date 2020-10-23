
NP - non-deterministic ploynomial time
np complete - 

complexity classes
- NL - nondeterministic logartihic-space
  P - polynomial time
  NP - nondeterministic poloynomial time - can't be completed in polynomial time. testable in polynomial time
  PSPACE - can be solved by a polynomial amount of space
  EXPTIME - expontential time
  EXPSPACE - exponential space

θ - Theta - average
Ω - Omega -best
O - Order - Worst

O(1) - constant time
O(n) linear time
O(n^2) - order of n squared - quadratic time i
O(n^k) - polynomial time
O(n log n) logarithmic time - order of n log n
O(log n)^k - polylogaritmic time order of log n squared
O( n log^k n) - quasilinear  time / log-linear time
o(n+k) order of n plus k
o(nk) order of n times k

Algorithm 	Time Complexity
  	  	Best 		Average 	Worst
Selection Sort 	Ω(n^2) 		θ(n^2) 		O(n^2)
Bubble Sort 	Ω(n) 		θ(n^2) 		O(n^2)
Insertion Sort 	Ω(n) 		θ(n^2) 		O(n^2)
Heap Sort 	Ω(n log(n)) 	θ(n log(n)) 	O(n log(n))
Quick Sort 	Ω(n log(n)) 	θ(n log(n)) 	O(n^2)
Merge Sort 	Ω(n log(n)) 	θ(n log(n)) 	O(n log(n))
Bucket Sort 	Ω(n+k) 		θ(n+k) 		O(n^2)
Radix Sort 	Ω(nk) 		θ(nk) 		O(nk)

Algorithm 	Time Complexity 	Space Complexity
		Best 		Average 	Worst 	Worst
Quicksort 	Ω(n log(n)) 	θ(n log(n)) 	O(n^2) 		O(log(n))
Mergesort 	Ω(n log(n)) 	θ(n log(n)) 	O(n log(n)) 	O(n)
Timsort 	Ω(n) 		θ(n log(n)) 	O(n log(n)) 	O(n)
Heapsort 	Ω(n log(n)) 	θ(n log(n)) 	O(n log(n)) 	O(1)
Bubble Sort 	Ω(n) 		θ(n^2) 		O(n^2) 		O(1)
Insertion Sort 	Ω(n) 		θ(n^2) 		O(n^2) 		O(1)
Selection Sort 	Ω(n^2) 		θ(n^2) 		O(n^2) 		O(1)
Tree Sort 	Ω(n log(n)) 	θ(n log(n)) 	O(n^2) 		O(n)
Shell Sort 	Ω(n log(n)) 	θ(n(log(n))^2) 	O(n(log(n))^2) 	O(1)
Bucket Sort 	Ω(n+k) 		θ(n+k) 		O(n^2) 		O(n)
Radix Sort 	Ω(nk) 		θ(nk) 		O(nk) 		O(n+k)
Counting Sort 	Ω(n+k) 		θ(n+k) 		O(n+k) 		O(k)
Cubesort 	Ω(n) 		θ(n log(n)) 	O(n log(n)) 	O(n)

Data Structure 		Time Complexity 														Space Complexity
			Average 						Worst 									Worst
			Access 		Search 	Insertion 	Deletion 	Access 	Search 	Insertion 	Deletion
Array 			θ(1) 		θ(n) 		θ(n) 		θ(n) 		O(1) 		O(n) 		O(n) 		O(n) 		O(n)
Stack 			θ(n) 		θ(n) 		θ(1) 		θ(1) 		O(n) 		O(n) 		O(1) 		O(1) 		O(n)
Queue 			θ(n) 		θ(n) 		θ(1) 		θ(1) 		O(n) 		O(n) 		O(1) 		O(1) 		O(n)
Singly-Linked List 	θ(n) 		θ(n) 		θ(1) 		θ(1) 		O(n) 		O(n) 		O(1) 		O(1) 		O(n)
Doubly-Linked List 	θ(n) 		θ(n) 		θ(1) 		θ(1) 		O(n) 		O(n) 		O(1) 		O(1) 		O(n)
Skip List 		θ(log(n)) 	θ(log(n)) 	θ(log(n)) 	θ(log(n)) 	O(n) 		O(n) 		O(n) 		O(n) 		O(n log(n))
Hash Table	 	N/A 		θ(1) 		θ(1) 		θ(1) 		N/A 		O(n) 		O(n) 		O(n) 		O(n)
Binary Search Tree 	θ(log(n)) 	θ(log(n)) 	θ(log(n)) 	θ(log(n)) 	O(n) 		O(n) 		O(n) 		O(n) 		O(n)
Cartesian Tree 		N/A 		θ(log(n)) 	θ(log(n)) 	θ(log(n)) 	N/A 		O(n) 		O(n) 		O(n) 		O(n)
B-Tree 			θ(log(n)) 	θ(log(n)) 	θ(log(n)) 	θ(log(n)) 	O(log(n)) 	O(log(n)) 	O(log(n)) 	O(log(n)) 	O(n)
Red-Black Tree 		θ(log(n)) 	θ(log(n)) 	θ(log(n)) 	θ(log(n)) 	O(log(n)) 	O(log(n)) 	O(log(n)) 	O(log(n)) 	O(n)
Splay Tree 		N/A 		θ(log(n)) 	θ(log(n)) 	θ(log(n)) 	N/A 		O(log(n)) 	O(log(n)) 	O(log(n)) 	O(n)
AVL Tree 		θ(log(n)) 	θ(log(n)) 	θ(log(n)) 	θ(log(n)) 	O(log(n)) 	O(log(n)) 	O(log(n)) 	O(log(n)) 	O(n)
KD Tree 		θ(log(n)) 	θ(log(n)) 	θ(log(n)) 	θ(log(n)) 	O(n) 		O(n) 		O(n) 		O(n) 		O(n)


bubble sort
===========
  - walks list, compares adjacent elements, swapping if necissary, repeat until done

insetion sort
=============
  - walks the list, grabs element, finds the proper place, inserts it there.


heap sort
=========
  - walks the list, inserting every element into a priority queue or heap, then basically calls getmax() or getmin and places each element.


quicksort
=========
 * pick a pivot point, partition (all values less than pivot are before, all more are after) sort the sub arrays recursively.
 * the pivot point is the crucial part.
  * picking on the left will give you worst time complexity for already sorted lists

optimizations
^^^^^^^^^^^^^
O(log n) space - recur into the smaller, followed by the larger
  - this allows your larger array to be tail-call optimized, which any decent C compiler should do.
  - granted there is a time/space trade off.  You could divide the array into 1, and N-1 items, 

mergesort
=========

top down
^^^^^^^^

recursive

divide the list into sub lists until all that remain are single elements, merge the elements back up into sub lists until a sorted list is all that remains


bottom up
^^^^^^^^^
iteratively

treats the list as an array of single element sublists; then iterativly merges the sub-lists 


bucket sort
===========

distribute items into "buckets" or "bins", then sort each bucket individually.

radix sort
==========

bucket or non comparitive
