//
//  WeakPointerArray.swift
//  MyMobileED
//
//  Created by Created by Admin on 02.05.18.
//  Copyright © 2018 Company. All rights reserved.
//

import Foundation

class WeakPointerArray<ObjectType> {
    
    var count: Int {
        return weakStorage.count
    }
    
    fileprivate let weakStorage = NSHashTable<AnyObject>.weakObjects()
    
    func add(_ object: ObjectType) {
        weakStorage.add(object as AnyObject)
    }
    
    func remove(_ object: ObjectType) {
        weakStorage.remove(object as AnyObject)
    }
    
    func removeAllObjects() {
        weakStorage.removeAllObjects()
    }
    
    func contains(_ object: ObjectType) -> Bool {
        return weakStorage.contains(object as AnyObject)
    }
}

extension WeakPointerArray: Sequence {
    
    func makeIterator() -> AnyIterator<ObjectType> {
        
        let enumerator = weakStorage.objectEnumerator()
        
        return AnyIterator {
            return enumerator.nextObject() as! ObjectType?
        }
    }
}
