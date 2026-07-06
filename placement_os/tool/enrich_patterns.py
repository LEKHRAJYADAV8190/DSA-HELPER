#!/usr/bin/env python3
"""Add predefined patterns to each problem in striver_a2z.json without changing order."""
import json
import re
from pathlib import Path

JSON_PATH = Path(__file__).resolve().parent.parent / "assets" / "data" / "striver_a2z.json"

TOPIC_DEFAULTS = {
    "learn-the-basics": ["Fundamentals"],
    "learn-important-sorting-techniques": ["Sorting"],
    "solve-problems-on-arrays-easy-medium-hard": ["Arrays"],
    "binary-search-1d-2d-arrays-search-space": ["Binary Search"],
    "strings-basic-and-medium": ["Hashing"],
    "learn-linkedlist-single-ll-double-ll-medium-hard-problems": ["Linked List"],
    "recursion-patternwise": ["Recursion"],
    "bit-manipulation-concepts-problems": ["Bit Manipulation"],
    "stack-and-queues-learning-pre-in-post-fix-monotonic-stack-implementation": ["Stack & Queue"],
    "sliding-window-two-pointer-combined-problems": ["Sliding Window", "Two Pointer"],
    "heaps-learning-medium-hard-problems": ["Heap"],
    "greedy-algorithms-easy-medium-hard": ["Greedy"],
    "binary-trees-traversals-medium-and-hard-problems": ["Tree"],
    "binary-search-trees-concept-and-problems": ["Tree", "Binary Search"],
    "graphs-concepts-problems": ["Graph"],
    "dynamic-programming-patterns-and-problems": ["DP"],
    "tries": ["Trie"],
    "strings": ["Hashing"],
}

NAME_RULES = [
    (r"interval|meeting room|merge interval|non-overlapping|insert interval", ["Intervals"]),
    (r"kadane|max subarray|subarray sum|prefix sum|equilibrium|product array", ["Prefix Sum"]),
    (r"two pointer|two sum|3 sum|three sum|4 sum|four sum|container with most|trapping rain|sort color|remove duplicate|move zero|palindrome", ["Two Pointer"]),
    (r"sliding window|longest substring|minimum window|subarray.*k|fruit into basket|pick fruits", ["Sliding Window"]),
    (r"binary search|lower bound|upper bound|search insert|rotated sorted|peak element|single element", ["Binary Search"]),
    (r"sort|quick|merge sort|bubble|selection|count sort|kth largest", ["Sorting"]),
    (r"hash|anagram|frequency|subsequence.*string|group anagram", ["Hashing"]),
    (r"greedy|jump game|assign cookie|partition|stock.*profit|activity", ["Greedy"]),
    (r"dp|dynamic|knapsack|coin change|lis|longest increasing|edit distance|matrix chain|partition equal", ["DP"]),
    (r"graph|bfs|dfs|dijkstra|topo|union find|disjoint|cycle|island|word ladder|bellman", ["Graph"]),
    (r"trie|prefix tree|word search ii", ["Trie"]),
    (r"heap|priority queue|kth.*stream|median", ["Heap"]),
    (r"bit|xor|single number|power of two|count bit", ["Bit Manipulation"]),
    (r"linked list|reverse.*list|cycle.*list|merge.*list|intersection.*list", ["Linked List"]),
    (r"tree|bst|binary tree|inorder|preorder|postorder|lca|diameter", ["Tree"]),
    (r"stack|queue|monotonic|next greater|next smaller|histogram|rotting orange", ["Stack & Queue"]),
    (r"recursion|subset|combination|permutation|n-queen|sudoku|rat in maze", ["Recursion"]),
]


def infer_patterns(name: str, topic_id: str) -> list[str]:
    patterns = set(TOPIC_DEFAULTS.get(topic_id, ["General"]))
    lower = name.lower()
    for regex, tags in NAME_RULES:
        if re.search(regex, lower):
            patterns.update(tags)
    # Arrays topic refinement
    if topic_id == "solve-problems-on-arrays-easy-medium-hard" and patterns == {"Arrays"}:
        if re.search(r"sum|subarray|array", lower):
            patterns.add("Prefix Sum")
    return sorted(patterns)


def main():
    data = json.loads(JSON_PATH.read_text(encoding="utf-8"))
    all_patterns = set()
    for p in data["problems"]:
        tags = infer_patterns(p["name"], p["topicId"])
        p["patterns"] = tags
        p["title"] = p["name"]
        p["topic"] = p.get("topic") or p["topicId"]
        all_patterns.update(tags)
    data["predefinedPatterns"] = sorted(all_patterns)
    JSON_PATH.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"Updated {len(data['problems'])} problems with {len(all_patterns)} patterns")


if __name__ == "__main__":
    main()
