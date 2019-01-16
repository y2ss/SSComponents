//
//  Algorithm.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/27.
//  Copyright © 2018年 y2ss. All rights reserved.
//

struct Sort {
    //O(n2) stable
    static func bubbleSort<T>(_ arr: inout [T]) where T: Comparable {
        let len = arr.count
        for i in 0 ..< len - 1 {
            for j in 0 ..< len - i - 1 {
                if arr[j] > arr [j + 1] {
                    let temp = arr[j + 1]
                    arr[j + 1] = arr[j]
                    arr[j] = temp
                }
            }
        }
    }
    
    //O(n2) unstable
    static func selectSort<T>(_ arr: inout [T]) where T: Comparable {
        let len = arr.count
        var minIdx: Int
        var temp: T
        for i in 0 ..< len - 1 {
            minIdx = i
            for j in i + 1 ..< len {
                if arr[j] < arr[minIdx] {
                    minIdx = j
                }
            }
            temp = arr[i]
            arr[i] = arr[minIdx]
            arr[minIdx] = temp
        }
    }
    
    //O(n2) stable
    static func insertSort<T>(_ arr: inout [T]) where T: Comparable {
        let len = arr.count
        var preIdx: Int
        var current: T
        for i in 1 ..< len {
            preIdx = i - 1
            current = arr[i]
            while preIdx >= 0 && arr[preIdx] > current {
                arr[preIdx + 1] = arr[preIdx]
                preIdx -= 1
            }
            arr[preIdx + 1] = current
        }
    }
    
    //O(n1.3-n2) unstable
    static func shellSort<T>(_ arr: inout [T]) where T: Comparable {
        if arr.count == 0 { return }
        var gap = arr.count
        var temp: T
        repeat {
            gap = gap / 3 + 1
            print(gap)
            for i in gap ..< arr.count {
                print(arr)
                if arr[i - gap] > arr[i] {
                    temp = arr[i]
                    var j = i - gap
                    repeat {
                        arr[j + gap] = arr[j]
                        j -= gap
                    } while j >= 0 && arr[j] > temp
                    arr[j + gap] = temp
                }
            }
        } while gap > 1
    }
    
    //O(nlog2n)
    static func mergeSort<T>(_ arr: inout [T]) where T: Comparable {
        var temp: [T] = Array(repeating: 0, count: arr.count) as! [T]
        _mergesort(&arr, temp: &temp, left: 0, right: arr.count - 1)
    }
    
    private static func _mergesort<T>(_ arr: inout [T], temp: inout [T], left: Int, right: Int) where T: Comparable {
        if left < right {
            let mid = (left + right) / 2
            _mergesort(&arr, temp: &temp, left: left, right: mid)
            _mergesort(&arr, temp: &temp, left: mid + 1, right: right)
            merge(&arr, left: left, right: right, mid: mid, temp: &temp)
        }
    }
    
    private static func merge<T>(_ arr: inout [T], left: Int, right: Int, mid: Int, temp: inout [T]) where T: Comparable {
        print("left:\(left) mid:\(mid) right:\(right)")
        var _left = left
        var i = _left
        var j = mid + 1
        var t = 0
        while i <= mid && j <= right {
            if arr[i] <= arr[j] {
                temp[t] = arr[i]
                i += 1
            } else {
                temp[t] = arr[j]
                j += 1
            }
            t += 1
        }
        while i <= mid {
            temp[t] = arr[i]
            t += 1
            i += 1
        }
        while j <= right {
            temp[t] = arr[j]
            t += 1
            j += 1
        }
        t = 0
        while _left <= right {
            arr[_left] = temp[t]
            _left += 1
            t += 1
        }
    }
    
    //O(nlog2n) unstable
    static func quickSort<T>(_ arr: inout [T], left: Int = 0, right: Int) where T: Comparable {
        if left >= right { return }
        var i = left
        var j = right
        let key = arr[i]
        while i < j {
            while i < j && arr[j] >= key {
                j -= 1
            }
            arr[i] = arr[j]
            while i < j && arr[i] <= key {
                i += 1
            }
            arr[j] = arr[i]
        }
        arr[i] = key
        quickSort(&arr, left: left, right: i - 1)
        quickSort(&arr, left: i + 1, right: right)
    }
    
    
    private static func swap<T>(_ arr: inout [T], _ i: Int, _ j: Int) where T: Comparable {
        let temp = arr[i]
        arr[i] = arr[j]
        arr[j] = temp
    }
    
    
    //O(nlog2n) unstable
    static func heapSort<T>(_ arr: inout [T]) where T: Comparable {
        buildMaxHeap(&arr)
        var len = arr.count
        var i = len - 1
        while i > 0 {
            swap(&arr, 0, i)
            len -= 1
            heapify(&arr, i: 0, len: len)
            i -= 1
        }
    }
    
    private static func buildMaxHeap<T>(_ arr: inout [T]) where T: Comparable {
        let len = arr.count
        var i = Int(floor(Double(len / 2)))
        while i >= 0 {
            heapify(&arr, i: i, len: len)
            i -= 1
        }
    }
    
    private static func heapify<T>(_ arr: inout [T], i: Int, len: Int) where T: Comparable {
        let left = 2 * i + 1
        let right = 2 * i + 2
        var largest = i
        if left < len && arr[left] > arr[largest] {
            largest = left
        }
        if right < len && arr[right] > arr[largest] {
            largest = right
        }
        if largest != i {
            swap(&arr, i, largest)
            heapify(&arr, i: largest, len: len)
        }
    }
    
    //O(n+k) stable
    static func countingSort(_ arr: inout [Int]) {
        guard let min = arr.min(), let max = arr.max() else { return }
        let len = arr.count
        let gap = max - min + 1
        var bucket = Array(repeating: 0, count: gap + 1)
        for i in 0 ..< len {
            bucket[arr[i] - min + 1] = bucket[arr[i] - min + 1] + 1
        }
        for i in 0 ..< gap {
            bucket[i + 1] += bucket[i]
        }
        var count = Array(repeating: 0, count: len)
        for i in 0 ..< len {
            count[bucket[arr[i] - min]] = arr[i]
            bucket[arr[i] - min] = bucket[arr[i] - min] + 1
        }
        for i in 0 ..< len {
            arr[i] = count[i]
        }
    }
    
    //O(n+k) stable
    static func bucketSort(_ arr: inout [Int], maxSize: Int = 5) {
        if arr.count == 0 { return }
        var minValue = arr[0]
        var maxValue = arr[0]
        for i in 1 ..< arr.count {
            if arr[i] < minValue {
                minValue = arr[i]
            } else if arr[i] > maxValue {
                maxValue = arr[i]
            }
        }

        let bucketSize = maxSize
        let bucketCount = Int(floor(Double((maxValue - minValue) / bucketSize)) + 1)
        var buckets = Array(repeating: [Int](), count: bucketCount)
        for i in 0 ..< buckets.count {
            buckets[Int(floor(Double((arr[i] - minValue) / bucketSize)))].append(arr[i])
        }
       
        for i in 0 ..< buckets.count {
            insertSort(&buckets[i])
            for j in 0 ..< buckets[i].count {
                arr.append(buckets[i][j])
            }
        }
    }
}
