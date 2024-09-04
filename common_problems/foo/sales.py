from itertools import permutations
import numpy as np

class TSPSolver:
    def __init__(self, distances):
        """
        Initialize TSP solver with a distance matrix.
        
        Args:
            distances (list of lists): Square matrix where distances[i][j] is the distance
                                     from city i to city j.
        """
        self.distances = np.array(distances)
        self.n_cities = len(distances)
        
    def solve_brute_force(self):
        """
        Solve TSP using brute force method by checking all possible routes.
        Returns the shortest route and its total distance.
        """
        # Start with city 0 as the first city
        cities = list(range(1, self.n_cities))  # Exclude starting city
        shortest_route = None
        min_distance = float('inf') # set to infinity
        
        # Try all possible permutations of cities (excluding start/end city)
        for route in permutations(cities):
            route = (0,) + route + (0,)  # Add start/end city
            distance = self._calculate_route_distance(route)
            
            if distance < min_distance:
                min_distance = distance
                shortest_route = route
                
        return shortest_route, min_distance


    def solve_nearest_neighbor(self, start_city=0):
        """
        Solve TSP using Nearest Neighbor algorithm.
        
        Args:
            start_city (int): The city to start the tour from (default: 0)
            
        Returns:
            tuple: (route, total_distance) where route is a list of cities in visit order
        """
        unvisited = set(range(self.n_cities))
        route = [start_city]
        unvisited.remove(start_city)
        total_distance = 0
        
        current_city = start_city
        
        # Visit each city
        while unvisited:
            # Find the nearest unvisited city
            nearest_city = min(unvisited, 
                             key=lambda city: self.distances[current_city][city])
            
            # Add distance to total
            total_distance += self.distances[current_city][nearest_city]
            
            # Move to the nearest city
            current_city = nearest_city
            route.append(current_city)
            unvisited.remove(current_city)
        
        # Return to start city to complete the tour
        route.append(start_city)
        total_distance += self.distances[current_city][start_city]
        
        return route, total_distance
    
    def _calculate_route_distance(self, route):
        """Calculate total distance of a route."""
        return sum(self.distances[route[i]][route[i+1]] 
                  for i in range(len(route)-1))
    
    def print_solution(self, route, distance):
        """Pretty print the solution."""
        path = ' → '.join(f'City {i}' for i in route)
        print(f"\nBest route found: {path}")
        print(f"Total distance: {distance}")

# Example usage
def main():
    # Example distance matrix - replace with your own distances
    # distances[i][j] represents distance from city i to city j
    distances = [
        [0, 10, 15, 20],
        [10, 0, 35, 25],
        [15, 35, 0, 30],
        [20, 25, 30, 0]
    ]
    
    # Create solver instance
    solver = TSPSolver(distances)
    
    # Find best route
    route, distance = solver.solve_brute_force()
    
    # Print solution
    solver.print_solution(route, distance)
    route, distance = solver.solve_nearest_neighbor()
    solver.print_solution(route, distance)

if __name__ == "__main__":
    main()
