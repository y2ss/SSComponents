//
//  Tree.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/15.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import Foundation

class Node<Value: Comparable>: Equatable {
    var key: Value
    var left: Node?
    var right: Node?
    var parent: Node?
    var height: Int
    init(key: Value, left: Node? = nil, right: Node? = nil, parent: Node? = nil, height: Int = 0) {
        self.key = key
        self.left = left
        self.right = right
        self.parent = parent
        self.height = height
    }
    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.key == rhs.key
    }
}

protocol Tree {
    associatedtype ValueType: Comparable
    var root: Node<ValueType>? { set get }
    @discardableResult mutating func insert(_ node: Node<ValueType>) -> Node<ValueType>?
    @discardableResult mutating func insert(_ key: ValueType) -> Node<ValueType>?
    func preOrder(_ node: Node<ValueType>?)//先序遍历
    func inOrder(_ node: Node<ValueType>?)//中序遍历
    func postOrder(_ node: Node<ValueType>?)//后序遍历
    @discardableResult func search(_ node: Node<ValueType>?, key: ValueType) -> Node<ValueType>?
    @discardableResult func minimun(_ node: Node<ValueType>?) -> Node<ValueType>?
    @discardableResult func maximun(_ node: Node<ValueType>?) -> Node<ValueType>?
    @discardableResult mutating func remove(_ key: ValueType) -> Node<ValueType>?
    mutating func destory()
}

extension Tree {
    @discardableResult mutating func insert(_ key: ValueType) -> Node<ValueType>? {
        return insert(Node<ValueType>(key: key))
    }
    
    func preOrder(_ node: Node<ValueType>?) {
        guard let node = node else { return }
        print(node.key)
        preOrder(node.left)
        preOrder(node.right)
    }
    
    func inOrder(_ node: Node<ValueType>? = nil) {
        guard let node = node else { return }
        inOrder(node.left)
        print(node.key)
        inOrder(node.right)
    }
    
    func postOrder(_ node: Node<ValueType>?) {
        guard let node = node else { return }
        postOrder(node.left)
        postOrder(node.right)
        print(node.key)
    }
    
    @discardableResult func search(_ node: Node<ValueType>?, key: ValueType) -> Node<ValueType>? {
        if node == nil || (node?.key)! == key {
            return node
        }
        if (node?.key)! < key {
            return search(node?.right, key: key)
        } else {
            return search(node?.left, key: key)
        }
    }
    
    @discardableResult func minimun(_ node: Node<ValueType>?) -> Node<ValueType>? {
        if node == nil || node?.left == nil {
            return node
        }
        return minimun(node?.left)
    }
    
    @discardableResult func maximun(_ node: Node<ValueType>?) -> Node<ValueType>? {
        if node == nil || node?.right == nil {
            return node
        }
        return maximun(node?.right)
    }
}

struct BSTree<Value: Comparable>: Tree { //二叉排序树
    typealias ValueType = Value
    var root: Node<Value>?
    
    @discardableResult mutating func insert(_ node: Node<Value>) -> Node<ValueType>? {
        var y: Node<Value>? = nil
        var x = root
        while x != nil {//找到node的parent
            guard let _x = x else { break }
            y = _x
            if node.key > _x.key {
                x = _x.right
            } else {
                x = _x.left
            }
        }
        node.parent = y
        if y == nil {
            root = node
        } else if (y?.key)! > node.key {
            y?.left = node
        } else {
            y?.right = node
        }
        return nil
    }
    
    @discardableResult mutating func remove(_ key: Value) -> Node<Value>? {
        if let node = search(root, key: key) {
            if node.left == nil && node.right == nil {//node为叶子结点
                if node.parent == nil {//要删除结点为根节点
                    root = nil
                    return node
                } else if node.parent?.left != nil && (node.parent?.left)! == node {//判断要删除点在双亲结点的左边还是右边
                    node.parent?.left = nil
                } else if node.parent?.right != nil && (node.parent?.right)! == node {
                    node.parent?.right = nil
                } else {
                    print("something error1")
                }
            } else if node.left == nil {//node左子树为空
                if node.parent == nil {
                    root = node.right
                    node.right?.parent = nil
                } else if node.parent?.left != nil && (node.parent?.left)! == node {
                    node.parent?.left = node.right
                    node.left?.parent = node.parent
                } else if node.parent?.right != nil && (node.parent?.right)! == node {
                    node.parent?.right = node.right
                    node.right?.parent = node.parent
                } else {
                    print("something error2")
                }
            } else if node.right == nil {//node右子树为空
                if node.parent == nil {
                    root = node.left
                    node.left?.parent = nil
                } else if node.parent?.left != nil && (node.parent?.left)! == node {
                    node.parent?.left = node.left
                    node.left?.parent = node.parent
                } else if node.parent?.right != nil && (node.parent?.right)! == node {
                    node.parent?.right = node.left
                    node.right?.parent = node.parent
                } else {
                    print("something error3")
                }
            } else {//node左右子树均不为空
                if node.parent == nil {//node 为根节点
                    root = node.right
                    root?.parent = nil
                    if node.right?.left != nil {
                        let leftdownnode = minimun(node.right)
                        leftdownnode?.left = node.left//node 右子树的最左节点做node左子树的父节点
                        node.left?.parent = leftdownnode
                    } else {
                        node.right?.left = node.left
                        node.left?.parent = node.right
                    }
                } else if node.parent?.left != nil && (node.parent?.left)! == node  {//将node的左子树替换node的位置
                    node.parent?.left = node.left
                    node.left?.parent = node.parent
                    node.left?.right = node.right
                    node.right?.parent = node.left
                } else if node.parent?.right != nil && (node.parent?.right)! == node {
                    node.parent?.right = node.left
                    node.left?.parent = node.parent
                    node.left?.right = node.right
                    node.right?.parent = node.left
                } else {
                    print("something error4")
                }
            }
            return node
        }
        return nil
    }
    
    mutating func destory() {
        root = nil
    }
}


struct AVLTree<Value: Comparable>: Tree {//平衡二叉树
    typealias ValueType = Value
    var root: Node<Value>?
    
    @discardableResult mutating func insert(_ node: Node<Value>) -> Node<Value>? {
        root = _insert(root, key: node.key)
        return root
    }
    
    @discardableResult private func _insert(_ node: Node<Value>?, key: Value) -> Node<Value>? {
        var _node = node
        if _node == nil {
            _node = Node<Value>(key: key)
        } else if key < (node?.key)! {
            _node?.left = _insert(_node?.left, key: key)
            let h1 = _node?.left?.height ?? 0
            let h2 = _node?.right?.height ?? 0
            if h1 - h2 == 2 {//插入导致二叉树失衡
                if _node?.left != nil && key < (_node?.left?.key)! {
                    _node = leftleftRotate(_node)
                } else {
                    _node = leftrightRotate(_node)
                }
            }
        } else if key > (_node?.key)! {
            _node?.right = _insert(_node?.right, key: key)
            let h1 = _node?.right?.height ?? 0
            let h2 = _node?.left?.height ?? 0
            if h1 - h2 == 2 {
                if _node?.right != nil && key > (_node?.right?.key)! {
                    _node = rightrightRotate(_node)
                } else {
                    _node = rightleftRotate(_node)
                }
            }
        }
        _node?.height = max(_node?.left?.height ?? 0, _node?.right?.height ?? 0) + 1
        return _node
    }
    
    @discardableResult mutating func remove(_ key: Value) -> Node<Value>? {
        root = _remove(root, key: key)
        return root
    }
    
    mutating private func _remove(_ node: Node<Value>?, key: Value) -> Node<Value>? {
        guard var root = node, let dnode = search(self.root, key: key) else { return nil }
        if dnode.key < root.key {//要删除的结点在左子树
            root.left = _remove(root.left, key: key)
            root.height = max(root.left?.height ?? 0, root.right?.height ?? 0) + 1
            if (root.right?.height ?? 0) - (root.left?.height ?? 0) == 2 {//删除导致二叉树失衡
                let rightNode = root.right
                if (rightNode?.left?.height ?? 0) > (rightNode?.right?.height ?? 0) {
                    root = rightleftRotate(root)!
                    if let value = rightleftRotate(root) {
                        root = value
                    } else {
                        return nil
                    }
                } else {
                    if let value = rightrightRotate(root) {
                        root = value
                    } else {
                        return nil
                    }
                }
            } else {
                root.height = max(root.left?.height ?? 0, root.right?.height ?? 0) + 1
            }
        } else if dnode.key > root.key {//要删除的结点在右子树
            root.right = _remove(root.right, key: key)
            if (root.left?.height ?? 0) - (root.right?.height ?? 0) == 2 {
                let leftNode = root.left
                if (leftNode?.left?.height ?? 0) > (leftNode?.right?.height ?? 0) {
                    if let value = leftleftRotate(root) {
                        root = value
                    } else {
                        return nil
                    }
                } else {
                    if let value = leftrightRotate(root) {
                        root = value
                    } else {
                        return nil
                    }
                }
            } else {
                root.height = max(root.left?.height ?? 0, root.right?.height ?? 0) + 1
            }
        } else {//删除
            if root.left != nil && root.right != nil {//结点的左右子树均不为空
                if (root.left?.height ?? 0) > (root.right?.height ?? 0) {
                    /*
                     * 如果tree的左子树比右子树高；
                     * 则(01)找出tree的左子树中的最大节点
                     *  (02)将该最大节点的值赋值给tree。
                     *  (03)删除该最大节点。
                     * 这类似于用"tree的左子树中最大节点"做"tree"的替身；
                     */
                    let maxNode = maximun(root.left)
                    root.key = maxNode!.key
                    root.left = _remove(root.left, key: maxNode!.key)
                    root.height = max(root.left?.height ?? 0, root.right?.height ?? 0) + 1
                } else {
                    /*
                     * 如果tree的左子树不比右子树高(即它们相等，或右子树比左子树高1)
                     * 则(01)找出tree的右子树中的最小节点
                     *  (02)将该最小节点的值赋值给tree。
                     *  (03)删除该最小节点。
                     * 这类似于用"tree的右子树中最小节点"做"tree"的替身；
                     */
                    let minNode = minimun(root.right)
                    root.key = minNode!.key
                    root.right = _remove(root.right, key: minNode!.key)
                    root.height = max(root.left?.height ?? 0, root.right?.height ?? 0) + 1
                }
            } else {
                if root.left != nil {
                    root = root.left!
                } else if root.right != nil {
                    root = root.right!
                } else {
                    return nil
                }
            }
        }
        return root
    }
    
    mutating func destory() {
        root = nil
    }
    
    private func leftleftRotate(_ node: Node<Value>?) -> Node<Value>? {
        let lchild = node?.left
        node?.left = lchild?.right
        lchild?.right = node
        lchild?.height = max(lchild?.left?.height ?? 0, node?.height ?? 0) + 1
        node?.height = max(node?.left?.height ?? 0, node?.right?.height ?? 0) + 1
        return lchild
    }
    
    private func rightrightRotate(_ node: Node<Value>?) -> Node<Value>? {
        let rchild = node?.right
        node?.right = rchild?.left
        rchild?.left = node
        rchild?.height = max(node?.height ?? 0, rchild?.right?.height ?? 0) + 1
        node?.height = max(node?.left?.height ?? 0, node?.right?.height ?? 0) + 1
        return rchild
    }
    
    private func leftrightRotate(_ node: Node<Value>?) -> Node<Value>? {
        node?.left = rightrightRotate(node?.left)//先对左子树右右旋转
        return leftleftRotate(node)//再对结点左左旋转
    }
    
    private func rightleftRotate(_ node: Node<Value>?) -> Node<Value>? {
        node?.right = leftleftRotate(node?.right)
        return rightrightRotate(node)
    }
}


struct RBTree<Value: Comparable> {//红黑树
    
}
