
#[

<!-- ✅ Step 1: Tree traversal helper

Purpose: walk the tree and run a lambda on every node.

Use a recursive function.

For variant objects, traverse each field that contains child nodes, not just a generic children seq.

Example lambdas:

printNode(node)

collectNodeKinds(node, hashset)

This is your debugging and utility foundation.

✅ Step 2: General transform runner

Purpose: apply a lambda/transform to every node in the tree and produce a modified tree.

Can be mutable (in-place) or immutable (return new node).

For each node, the lambda can:

modify fields

leave children intact

replace children (if needed)

The traversal for this is structurally identical to the traversal helper, except it rebuilds nodes or mutates them.

✅ Step 3: Individual transforms

Each transform is small, specific, and typed to a node kind.

They are passed into the general transform runner.

Each transform:

modifies only the intended fields

leaves the rest of the node/subtree untouched

may produce new node kinds

After one transform run, the tree is replaced by the transformed tree (or updated in-place).

✅ Step 4: Iterate transforms until convergence

Collect the set of node kinds present in the tree (collectKinds).

Run all relevant transforms in sequence, one pass per transform.

Recompute collectKinds after the pass to know which transforms are still relevant.

Repeat passes until:

no transform changed the tree

or a cycle is detected

✅ Step 5: Tree hashing for convergence and cycle detection

Purpose: know if a tree changed without comparing every field manually.

Recursive hashing:

For a node, hash its kind.

Hash all primitive fields.

Hash children recursively.

Combine into a single hash for the node.

After each transform pass, compare the new root hash to the previous root hash.

If the same → stable → stop

If repeated hashes appear in a sequence → cycle detected → error

Optional: keep a small history buffer to catch oscillations between 2–3 tree states.

✅ How it all fits together

Traverse → run utility lambdas (debug/collect info).

Run general transform → each node receives a lambda that knows how to modify it.

Apply individual transforms → use the general transform runner.

Iterate until convergence → track tree hash and collected node kinds.

Detect cycles → stop with a clear diagnostic if repeated hashes appear. 

]#