def create_node(leaf=True, t=3):
    """Create a B-tree node as a dictionary"""
    return {
        'leaf': leaf,      # Is this node a leaf?
        't': t,            # Minimum degree
        'keys': [],        # Keys stored in node
        'values': [],      # Values corresponding to keys
        'children': []     # Child node references
    }

def is_full(node):
    """Check if a node is full"""
    return len(node['keys']) == 2 * node['t'] - 1

def create_btree(t=3):
    """Create a new B-tree with minimum degree t"""
    return {
        'root': create_node(leaf=True, t=t),
        't': t
    }

def search(btree, k, node=None):
    """Search for a key in the B-tree"""
    if node is None:
        node = btree['root']
        
    i = 0
    while i < len(node['keys']) and k > node['keys'][i]:
        i += 1
       
    if i < len(node['keys']) and k == node['keys'][i]:
        return (node, i)
       
    if node['leaf']:
        return None
       
    return search(btree, k, node['children'][i])

def split_child(btree, parent, child_idx):
    """Split a child node"""
    t = btree['t']
    child = parent['children'][child_idx]
    new_node = create_node(leaf=child['leaf'], t=t)
    
    # Find where median key should go in parent
    median_key = child['keys'][t-1]
    median_value = child['values'][t-1]
    insert_pos = child_idx
    while insert_pos < len(parent['keys']) and parent['keys'][insert_pos] < median_key:
        insert_pos += 1
        
    # Insert median key and value into parent at correct position
    parent['keys'].insert(insert_pos, median_key)
    parent['values'].insert(insert_pos, median_value)
    
    # Insert new node into children array after the insertion position
    parent['children'].insert(insert_pos + 1, new_node)
    
    # Copy the larger keys and values to the new node
    new_node['keys'] = child['keys'][t:]
    new_node['values'] = child['values'][t:]
    child['keys'] = child['keys'][:t-1]
    child['values'] = child['values'][:t-1]
    
    if not child['leaf']:
        new_node['children'] = child['children'][t:]
        child['children'] = child['children'][:t]

def insert_non_full(btree, node, k, v):
    """Insert a key-value pair into a non-full node"""
    i = len(node['keys']) - 1
    
    if node['leaf']:
        while i >= 0 and k < node['keys'][i]:
            i -= 1
        node['keys'].insert(i + 1, k)
        node['values'].insert(i + 1, v)
    else:
        while i >= 0 and k < node['keys'][i]:
            i -= 1
        i += 1
        
        if is_full(node['children'][i]):
            split_child(btree, node, i)
            if k > node['keys'][i]:
                i += 1
                
        insert_non_full(btree, node['children'][i], k, v)

def insert(btree, k, v):
    """Insert a key-value pair into the B-tree"""
    root = btree['root']
    
    if is_full(root):
        new_root = create_node(leaf=False, t=btree['t'])
        new_root['children'].append(btree['root'])
        btree['root'] = new_root
        split_child(btree, new_root, 0)
    
    insert_non_full(btree, btree['root'], k, v)

def get(btree, k):
    """Retrieve the value associated with a key"""
    result = search(btree, k)
    if result:
        node, idx = result
        return node['values'][idx]
    return None

def print_btree(node, level=0):
    """Print the B-tree structure"""
    pairs = [f"{k}:{v}" for k, v in zip(node['keys'], node['values'])]
    print('  ' * level + str(pairs))
    if not node['leaf']:
        for child in node['children']:
            print_btree(child, level + 1)

# Example usage:
btree = create_btree(t=3)

# Insert key-value pairs
pairs = [
    (10, "apple"),
    (20, "banana"),
    (5, "cherry"),
    (6, "date"),
    (12, "elderberry"),
    (30, "fig"),
    (7, "grape"),
    (17, "honeydew")
]

for key, value in pairs:
    insert(btree, key, value)

# Print the tree structure
print("B-tree structure (key:value):")
print_btree(btree['root'])

# Retrieve some values
print("\nLookup examples:")
print(f"Value for key 12: {get(btree, 12)}")
print(f"Value for key 7: {get(btree, 7)}")
print(f"Value for key 99: {get(btree, 99)}")  # Non-existent key
