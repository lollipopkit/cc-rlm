# RLM Example Workflows

This document provides concrete examples of Recursive Language Model reasoning in action.

## Example 1: Algorithm Design

**User Request**: "Use RLM to design a function that finds the k-th largest element in an unsorted array"

### 🔄 Iteration 1

**Current Solution**:
```python
def find_kth_largest(nums, k):
    nums.sort(reverse=True)
    return nums[k-1]
```

**Self-Critique**:
- Strengths: Simple, correct, readable
- Weaknesses: O(n log n) time complexity; modifies input array
- Missing: Edge case handling; could be O(n) average
- Confidence: 4/10

**Refinement Plan**:
1. Add input validation
2. Consider QuickSelect for O(n) average case
3. Avoid modifying input

---

### 🔄 Iteration 2

**Current Solution**:
```python
def find_kth_largest(nums, k):
    if not nums or k < 1 or k > len(nums):
        raise ValueError("Invalid input")

    import heapq
    return heapq.nlargest(k, nums)[-1]
```

**Self-Critique**:
- Strengths: Handles edge cases; doesn't modify input
- Weaknesses: Still O(n log k); heap overhead
- Missing: Could implement QuickSelect for better average case
- Confidence: 6/10

**Refinement Plan**:
1. Implement QuickSelect algorithm
2. Add randomization to avoid worst case

---

### 🔄 Iteration 3

**Current Solution**:
```python
import random

def find_kth_largest(nums, k):
    if not nums or k < 1 or k > len(nums):
        raise ValueError("Invalid input")

    def partition(left, right, pivot_idx):
        pivot = arr[pivot_idx]
        arr[pivot_idx], arr[right] = arr[right], arr[pivot_idx]
        store_idx = left
        for i in range(left, right):
            if arr[i] > pivot:
                arr[store_idx], arr[i] = arr[i], arr[store_idx]
                store_idx += 1
        arr[right], arr[store_idx] = arr[store_idx], arr[right]
        return store_idx

    def quickselect(left, right, k_smallest):
        if left == right:
            return arr[left]
        pivot_idx = random.randint(left, right)
        pivot_idx = partition(left, right, pivot_idx)
        if k_smallest == pivot_idx:
            return arr[k_smallest]
        elif k_smallest < pivot_idx:
            return quickselect(left, pivot_idx - 1, k_smallest)
        else:
            return quickselect(pivot_idx + 1, right, k_smallest)

    arr = nums.copy()
    return quickselect(0, len(arr) - 1, k - 1)
```

**Self-Critique**:
- Strengths: O(n) average; randomized; doesn't modify input
- Weaknesses: O(n²) worst case (rare with randomization)
- Missing: Could add median-of-medians for guaranteed O(n)
- Confidence: 8/10

---

### ✅ Final Answer

The QuickSelect implementation above provides O(n) average time complexity with proper edge case handling.

| Iteration | Key Changes | Confidence |
|-----------|-------------|------------|
| 1 | Basic sort approach | 4/10 |
| 2 | Added validation, used heap | 6/10 |
| 3 | Implemented randomized QuickSelect | 8/10 |

---

## Example 2: Code Review Refinement

**User Request**: "Use RLM to review and improve this error handling code"

```python
def process_file(path):
    try:
        f = open(path)
        data = f.read()
        return parse(data)
    except:
        return None
```

### 🔄 Iteration 1

**Current Solution**:
```python
def process_file(path):
    try:
        with open(path) as f:
            data = f.read()
            return parse(data)
    except Exception as e:
        logging.error(f"Failed to process {path}: {e}")
        return None
```

**Self-Critique**:
- Strengths: Uses context manager; logs errors
- Weaknesses: Catches too broad; still returns None
- Confidence: 5/10

---

### 🔄 Iteration 2

**Current Solution**:
```python
from pathlib import Path

def process_file(path: str | Path) -> ParseResult:
    path = Path(path)

    if not path.exists():
        raise FileNotFoundError(f"File not found: {path}")

    try:
        content = path.read_text(encoding='utf-8')
    except PermissionError:
        raise PermissionError(f"Cannot read file: {path}")
    except UnicodeDecodeError as e:
        raise ValueError(f"Invalid encoding in {path}: {e}")

    try:
        return parse(content)
    except ParseError as e:
        raise ValueError(f"Failed to parse {path}: {e}")
```

**Self-Critique**:
- Strengths: Specific exceptions; type hints; proper propagation
- Weaknesses: Could use custom exception hierarchy
- Confidence: 8/10

---

### ✅ Final Answer

The refined version properly separates file I/O errors from parsing errors, uses specific exception types, and provides clear error messages with context.

| Iteration | Key Changes | Confidence |
|-----------|-------------|------------|
| 1 | Added context manager and logging | 5/10 |
| 2 | Specific exceptions, type hints, proper error propagation | 8/10 |
