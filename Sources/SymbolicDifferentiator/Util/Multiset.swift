//
//  Multiset.swift
//  
//
//  Created by Liam Rosenfeld on 12/12/21.
//

import Foundation

public struct Multiset<T: Hashable> {
    // MARK: - Storage
    private var storage: [T: UInt] = [:]
    private(set) var count: UInt = 0
    
    // MARK: - Init
    public init<C: Collection>(_ collection: C) where C.Element == T {
        for element in collection {
            self.add(element)
        }
    }
    
    // MARK: - Modification
    mutating func add(_ elem: T, amount: UInt = 1) {
        storage[elem, default: 0] += amount
        count += amount
    }
    
    mutating func addAll(_ set: Multiset<T>, amount: UInt = 1) {
        for (elem, innerAmount) in set {
            storage[elem, default: 0] += innerAmount * amount
            count += innerAmount * amount
        }
    }
    
    mutating func remove(_ elem: T) {
        if let currentCount = storage[elem] {
            if currentCount > 1 {
                storage[elem] = currentCount - 1
            } else {
                storage.removeValue(forKey: elem)
            }
            count -= 1
        }
    }
    
    mutating func removeAll(_ elem: T) {
        if let currentCount = storage[elem] {
            storage.removeValue(forKey: elem)
            count -= currentCount
        }
    }
    
    // MARK: - Access
    func count(for elem: T) -> UInt {
        storage[elem] ?? 0
    }
    
    var asArray: [T] {
        return storage.flatMap { (elem, count) in
            repeatElement(elem, count: Int(count))
        }
    }
}

extension Multiset: Equatable { }
extension Multiset: Hashable { }

extension Multiset: Sequence {
    __consuming public func makeIterator() -> Iterator {
        Iterator(base: self)
    }
    
    public struct Iterator: IteratorProtocol {
        private var internalIter: Dictionary<T, UInt>.Iterator
        
        init(base: Multiset) {
            internalIter = base.storage.makeIterator()
        }
        
        mutating public func next() -> (elem: T, count: UInt)? {
            if let next = internalIter.next() {
                return (elem: next.key, count: next.value)
            } else {
                return nil
            }
        }
    }
}

extension Multiset: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: T...) {
        self.init(elements)
    }
}
