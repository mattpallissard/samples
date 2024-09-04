from collections import defaultdict, deque

def create_graph():
    """Create a new graph represented by adjacency list and vertex values"""
    return {
        'edges': defaultdict(list),
        'values': {}
    }

def add_vertex(graph, vertex, value):
    """Add a vertex with an associated value to the graph"""
    graph['values'][vertex] = value
    if vertex not in graph['edges']:
        graph['edges'][vertex] = []

def add_edge(graph, vertex1, vertex2):
    """Add an edge between vertex1 and vertex2"""
    graph['edges'][vertex1].append(vertex2)

def dfs_search(graph, start_vertex, target_value):
    """Depth-First Search to find a vertex with target_value"""
    visited = set()
    path = []
    
    def dfs_recursive(vertex):
        if graph['values'][vertex] == target_value:
            return vertex
        
        visited.add(vertex)
        path.append(vertex)
        
        for neighbor in graph['edges'][vertex]:
            if neighbor not in visited:
                result = dfs_recursive(neighbor)
                if result is not None:
                    return result
        
        return None
    
    result = dfs_recursive(start_vertex)
    return result, path

def bfs_search(graph, start_vertex, target_value):
    """Breadth-First Search to find a vertex with target_value"""
    visited = set()
    queue = deque()
    path = []
    
    visited.add(start_vertex)
    queue.append(start_vertex)
    
    while queue:
        vertex = queue.popleft()
        path.append(vertex)
        
        if graph['values'][vertex] == target_value:
            return vertex, path
        
        for neighbor in graph['edges'][vertex]:
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append(neighbor)
    
    return None, path

def dfs_traverse(graph, start_vertex):
    """Simple DFS traversal without search"""
    visited = set()
    path = []
    
    def dfs_recursive(vertex):
        visited.add(vertex)
        path.append(vertex)
        for neighbor in graph['edges'][vertex]:
            if neighbor not in visited:
                dfs_recursive(neighbor)
    
    dfs_recursive(start_vertex)
    return path

def bfs_traverse(graph, start_vertex):
    """Simple BFS traversal without search"""
    visited = set()
    queue = deque()
    path = []
    
    visited.add(start_vertex)
    queue.append(start_vertex)
    
    while queue:
        vertex = queue.popleft()
        path.append(vertex)
        
        for neighbor in graph['edges'][vertex]:
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append(neighbor)
    
    return path

# Example usage
if __name__ == "__main__":
    # Create a graph
    g = create_graph()
    
    # Add vertices with values
    add_vertex(g, 0, "A")
    add_vertex(g, 1, "B")
    add_vertex(g, 2, "C")
    add_vertex(g, 3, "D")
    add_vertex(g, 4, "E")
    
    # Add edges
    add_edge(g, 0, 1)
    add_edge(g, 0, 2)
    add_edge(g, 1, 2)
    add_edge(g, 1, 3)
    add_edge(g, 2, 4)

    print("Graph structure:")
    for vertex in g['edges']:
        print(f"Vertex {vertex} -> {g['edges'][vertex]}")
    
    # Demonstrate search vs traversal
    print("\nSearch for value 'D':")
    found_vertex, search_path = dfs_search(g, 0, "D")
    print(f"DFS Search - Found at vertex: {found_vertex}, Path taken: {search_path}")
    
    print("\nSimple traversal:")
    traverse_path = dfs_traverse(g, 0)
    print(f"DFS Traverse - Path: {traverse_path}")
