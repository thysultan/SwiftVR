/**
 * Swift implementation
 */

struct Node {
	let nodeType: Int // immutable
	let type: Any     // immutable, String or Function
	var props: ()
	var children: [Any]
}

// an EmptyNode
var EmptyNode = Node(0, "", (), [])

func reconciler (newNode: Node, oldNode: Node) -> Int {
	// remove
	if newNode.nodeType == 0 {
		return 1
	}
	// add
	if oldNode.nodeType == 0 {
		return 2
	}
	// text
	if newNode.nodeType == 3 && oldNode.nodeType == 3 {
		// text update
		if newNode.children[0] !== oldNode.children[0] {
			return 3
		}
	}
	// keys
	else if newNode.props.key != oldNode.props.key {
		return 5
	}
	// replace
	else if newNode.type != oldNode.type {
		return 4
	}
	// recursive
	else {
		// extractNode will handle when newNode.type is a component constructor instead of a string
		var currentNode: Node = extractNode(newNode)

		// identical
		if currentNode == oldNode {
			return 0
		}

		// if not TextNode patch props
		if oldNode.nodeType == 1 { 
			patchProps(currentNode, oldNode)
		}

		var newLength: Int = currentNode.children.count
		var oldLength: Int = oldNode.children.count

		// remove all children
		if newLength == 0 {
			// but only if old children is not already cleared
			if oldLength != 0 {
				clearChildren(oldNode)
				oldNode.children = currentNode.children
			}
		} else {
			var deleteCount:Int = 0

			for var i:Int = 0; i < newLength || i < oldLength; i = i + 1 {
			    var newChild: Node = currentNode.children[i] || EmptyNode
			    var oldChild: Node = oldNode.children[i] || EmptyNode
			    var action: Int    = reconciler(newChild, oldChild)

			    if action != 0 {
			    	var index:Int = i - deleteCount;

			    	switch action {
			    		// remove operation
			    		case 1: {
			    			removeChild(oldNode, index);
			    			oldNode.children.removeAtIndex(index)
			    			deleteCount = deleteCount + 1
			    		}
			    		// add operation
			    		case 2: {
			    			addNode(oldNode, newChild, index)
			    			oldNode.children.insert(newChild, atIndex: index)
			    			deleteCount = deleteCount - 1
			    		}
			    		// text operation
			    		case 3: {
			    			updateText(newChild, oldChild)
			    			oldChild.children[0] = newChild.children[0]
			    		}
			    		// replace operation
			    		case 4: {
			    			// replace dom node
			    			replaceChild(newChild, oldChild)
			    			oldNode.children[index] = newChild
			    		}
			    		// key operation
			    		case 5: {

			    		}
			    	}
			    }
			}
		}
	}

	return 0
}

// a TextNode
var TextNode = Node(3, "Text", (), ["Hello World"])
// an ElementNode NavBar with one TextNode child
var ElementNode = Node(1, "NavBar", (state: "active"), [TextNode])

reconciler(ElementNode, ElementNode)