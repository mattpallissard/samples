            pairs:    make([]KeyValue, 0),
            children: make([]*Node, 0),
            leaf:     true,
            t:        t,
        },
        t: t,
    }
}

// Search searches for a key in the B-tree and returns its value and existence
func (tree *BTree) Search(key int) (interface{}, bool) {
    return search(tree.root, key)
}

func search(node *Node, key int) (interface{}, bool) {
    i := 0
    for i < len(node.pairs) && key > node.pairs[i].Key {
        i++
    }

    if i < len(node.pairs) && key == node.pairs[i].Key {
        return node.pairs[i].Value, true
    }

    if node.leaf {
        return nil, false
    }

    return search(node.children[i], key)
}

// Insert inserts a key-value pair into the B-tree
func (tree *BTree) Insert(key int, value interface{}) {
    root := tree.root

    if len(root.pairs) == 2*tree.t-1 {
        newRoot := &Node{
            pairs:    make([]KeyValue, 0),
            children: make([]*Node, 0),
            leaf:     false,
            t:        tree.t,
        }
        tree.root = newRoot
        newRoot.children = append(newRoot.children, root)
        splitChild(newRoot, 0)
        insertNonFull(newRoot, key, value)
    } else {
        insertNonFull(root, key, value)
    }
}

// splitChild splits the child node at index i of parent
func splitChild(parent *Node, i int) {
    t := parent.t
    child := parent.children[i]
    newNode := &Node{
        pairs:    make([]KeyValue, t-1),
        children: make([]*Node, 0),
        leaf:     child.leaf,
        t:        t,
    }

    // Copy the last t-1 pairs of child to newNode
    for j := 0; j < t-1; j++ {
        newNode.pairs = append(newNode.pairs, child.pairs[j+t])
    }

    // Copy the last t children of child to newNode
    if !child.leaf {
        for j := 0; j < t; j++ {
            newNode.children = append(newNode.children, child.children[j+t])
        }
    }

    // Reduce the number of pairs in child
    child.pairs = child.pairs[:t-1]

    // Create space for the new child
    parent.children = append(parent.children, nil)
    copy(parent.children[i+2:], parent.children[i+1:])
    parent.children[i+1] = newNode

    // Move middle pair to parent
    parent.pairs = append(parent.pairs, child.pairs[t-1])
    copy(parent.pairs[i+1:], parent.pairs[i:])
    parent.pairs[i] = child.pairs[t-1]
}

// insertNonFull inserts a key-value pair into a non-full node
func insertNonFull(node *Node, key int, value interface{}) {
    i := len(node.pairs) - 1

    if node.leaf {
        // Make space for new pair
        node.pairs = append(node.pairs, KeyValue{})
        for i >= 0 && key < node.pairs[i].Key {
            node.pairs[i+1] = node.pairs[i]
            i--
        }
        node.pairs[i+1] = KeyValue{Key: key, Value: value}
    } else {
        // Find the child which is going to have the new key
        for i >= 0 && key < node.pairs[i].Key {
            i--
        }
        i++

        if len(node.children[i].pairs) == 2*node.t-1 {
            splitChild(node, i)
            if key > node.pairs[i].Key {
                i++
            }
        }
        insertNonFull(node.children[i], key, value)
    }
}

// Update updates the value associated with a key if it exists
func (tree *BTree) Update(key int, value interface{}) bool {
    return update(tree.root, key, value)
}

func update(node *Node, key int, value interface{}) bool {
    i := 0
    for i < len(node.pairs) && key > node.pairs[i].Key {
        i++
    }

    if i < len(node.pairs) && key == node.pairs[i].Key {
        node.pairs[i].Value = value
        return true
    }

    if node.leaf {
        return false
    }

    return update(node.children[i], key, value)
}

// GetAll returns all key-value pairs in the tree in order
func (tree *BTree) GetAll() []KeyValue {
    pairs := make([]KeyValue, 0)
    getAllInOrder(tree.root, &pairs)
    return pairs
}

func getAllInOrder(node *Node, pairs *[]KeyValue) {
    if node == nil {
        return
    }

    for i := 0; i < len(node.pairs); i++ {
        if !node.leaf {
            getAllInOrder(node.children[i], pairs)
        }
        *pairs = append(*pairs, node.pairs[i])
    }

    if !node.leaf {
        getAllInOrder(node.children[len(node.pairs)], pairs)
    }
}
