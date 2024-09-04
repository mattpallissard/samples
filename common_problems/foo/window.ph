def max_sum_subarray(arr, k):
    """
    Find the maximum sum of any contiguous subarray of size k.
    
    Args:
        arr (List[int]): Input array of integers
        k (int): Size of the sliding window
        
    Returns:
        tuple: (max_sum, start_index) where max_sum is the maximum sum found
               and start_index is the starting index of that subarray
    """
    if len(arr) < k:
        return None, None
        
    # Calculate sum of first window
    window_sum = sum(arr[:k])
    max_sum = window_sum
    max_start_index = 0
    
    # Slide the window forward
    for i in range(len(arr) - k):
        # Subtract element going out of window
        window_sum = window_sum - arr[i]
        # Add element coming into window
        window_sum = window_sum + arr[i + k]
        
        # Update maximum sum if current window sum is greater
        if window_sum > max_sum:
            max_sum = window_sum
            max_start_index = i + 1
            
    return max_sum, max_start_index

# Example usage
arr = [1, 4, 2, 10, 2, 3, 1, 0, 20]
k = 4
max_sum, start_idx = max_sum_subarray(arr, k)
subarray = arr[start_idx:start_idx + k] if start_idx is not None else None
