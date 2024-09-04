def preorder_traverse(node):
    """Print tree values in pre-order traversal (root, left, right)."""
    if not node:
        return
    print(node['value'])
    preorder_traverse(node['left'])
    preorder_traverse(node['right'])

def inorder_traverse(node):
    """Print tree values in in-order traversal (left, root, right)."""
    if not node:
        return
    inorder_traverse(node['left'])
    print(node['value'])
    inorder_traverse(node['right'])

def postorder_traverse(node):
    """Print tree values in post-order traversal (left, right, root)."""
    if not node:
        return
    postorder_traverse(node['left'])
    postorder_traverse(node['right'])
    print(node['value'])

def height(node):
    """Calculate the height of the tree."""
    if not node:
        return -1
    return 1 + max(height(node['left']), height(node['right']))

def count_nodes(node):
    """Count the total number of nodes in the tree."""
    if not node:
        return 0
    return 1 + count_nodes(node['left']) + count_nodes(node['right'])

def make_node(value):
    """Create a new binary tree node."""
    return {
        'value': value,
        'left': None,
        'right': None
    }

def insert_left(node, value):
    """Insert a value as the left child of the given node."""
    if not node:
        return None
    new_node = make_node(value)
    node['left'] = new_node
    return new_node

def insert_right(node, value):
    """Insert a value as the right child of the given node."""
    if not node:
        return None
    new_node = make_node(value)
    node['right'] = new_node
    return new_node

def find_value(node, target):
    """Search for a value in the tree (using pre-order traversal)."""
    if not node:
        return False
    if node['value'] == target:
        return True
    return find_value(node['left'], target) or find_value(node['right'], target)

# Example usage
if __name__ == "__main__":
    # Create and build a sample tree
    #       1
    #      / \
    #     2   3
    #    / \   \
    #   4   5   6
    
    root = make_node(1)
    node2 = insert_left(root, 2)
    node3 = insert_right(root, 3)
    node4 = insert_left(node2, 4)
    node5 = insert_right(node2, 5)
    node6 = insert_right(node3, 6)
    
    print("Pre-order traversal:")
    preorder_traverse(root)
    
    print("\nIn-order traversal:")
    inorder_traverse(root)
    
    print("\nPost-order traversal:")
    postorder_traverse(root)
    
    print(f"\nTree height: {height(root)}")
    print(f"Total nodes: {count_nodes(root)}")
    print(f"Contains 5? {find_value(root, 5)}")
    print(f"Contains 7? {find_value(root, 7)}")
