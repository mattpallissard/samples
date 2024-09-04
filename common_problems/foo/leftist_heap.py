def make_node(value):
    """Create a new heap node."""
    return {
        'value': value,
        'dist': 0,
        'left': None,
        'right': None
    }

def distance(node):
    """Get the distance of a node."""
    return node['dist'] if node else -1

def merge(heap1, heap2):
    """Merge two leftist heaps."""
    if not heap1:
        return heap2
    if not heap2:
        return heap1
    
    # Ensure heap1 has the smaller root
    if heap1['value'] > heap2['value']:
        heap1, heap2 = heap2, heap1
    
    # Recursively merge right subtree with heap2
    heap1['right'] = merge(heap1['right'], heap2)
    
    # Maintain leftist property
    if distance(heap1['right']) > distance(heap1['left']):
        heap1['left'], heap1['right'] = heap1['right'], heap1['left']
    
    # Update distance
    heap1['dist'] = 1 + distance(heap1['right'])
    
    return heap1

def insert(heap, value):
    """Insert a value into the heap."""
    new_node = make_node(value)
    return merge(heap, new_node) if heap else new_node

def get_min(heap):
    """Get the minimum value from the heap without removing it."""
    return heap['value'] if heap else None

def pop(heap):
    """Remove and return the minimum value from the heap."""
    if not heap:
        return None, None
    min_value = heap['value']
    new_heap = merge(heap['left'], heap['right'])
    return min_value, new_heap

def dump(heap):
    """Print the heap values in pre-order traversal."""
    if not heap:
        return
    print(heap['value'])
    dump(heap['left'])
    dump(heap['right'])

# Example usage
if __name__ == "__main__":
    # Initialize heap
    heap = insert(None, 0)
    heap = insert(heap, 2)
    heap = insert(heap, 3)
    heap = insert(heap, 4)
    heap = insert(heap, 5)
    
    print("\nPopping values:")
    for _ in range(3):
        value, heap = pop(heap)
        print(value)
