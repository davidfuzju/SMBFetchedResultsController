//
//  SMBFetchedResults.m
//
//  Created by David Fu on 3/16/15.
//  Copyright (c) 2015 David Fu. All rights reserved.
//

#import "SMBFetchedResults.h"

@interface SMBFetchedResults() {
    dispatch_queue_t _queue;
}

@property (readwrite, nonatomic, strong) NSMutableOrderedSet *data;

@property (readwrite, nonatomic, copy) NSString *sortKeyPaths;

@property (readwrite, nonatomic, assign) NSStringCompareOptions options;

@property (readwrite, nonatomic, assign) BOOL moving;

/** KVC one-to-many compliance interface */
- (void)insertObject:(id <SMBFetchedResultsProtocol>)object inDataAtIndex:(NSUInteger)index;
- (void)insertData:(NSArray *)data atIndexes:(NSIndexSet *)indexes;

- (void)removeObjectFromDataAtIndex:(NSUInteger)index;
- (void)removeDataAtIndexes:(NSIndexSet *)indexes;

- (void)replaceObjectInDataAtIndex:(NSUInteger)index withObject:(id <SMBFetchedResultsProtocol>)object;
- (void)replaceDataAtIndexes:(NSIndexSet *)indexes withData:(NSArray *)data;

/** custom KVC one-to-many compliance interface for move */
- (void)moveObjectInDataAtIndex:(NSUInteger)index toIndex:(NSUInteger)toIndex;

- (id <SMBFetchedResultsProtocol>)objectInDataAtIndex:(NSUInteger)index;
- (NSArray *)dataAtIndexes:(NSIndexSet *)indexes;
- (NSUInteger)countOfData;

@end

@implementation SMBFetchedResults

#pragma mark - life cycle

- (instancetype)init {
    return [self initWithMutableData:[NSMutableOrderedSet orderedSet] sortKeyPaths:nil sortOptions:0];
}

- (instancetype)initWithMutableData:(NSMutableOrderedSet *)mutableData {
    return [self initWithMutableData:mutableData sortKeyPaths:nil sortOptions:0];
}

- (instancetype)initWithMutableData:(NSMutableOrderedSet *)mutableData sortKeyPaths:(NSString *)sortKeyPaths sortOptions:(NSStringCompareOptions)options {
    self = [super init];
    if (self) {
        _data = mutableData;
        _sortKeyPaths = sortKeyPaths;
        _options = options;
        _moving = NO;
        _queue = dispatch_queue_create("CTFetchecResults queue", NULL);
        [self sortedResultWithOrderedSet:_data];
    }
    return self;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([key isEqualToString:@"data"]) {
        return YES;
    }
    return [super automaticallyNotifiesObserversForKey:key];
}

#pragma mark Proxying

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    [anInvocation setTarget:self.data];
    [anInvocation invoke];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.data methodSignatureForSelector:sel];
}

- (NSString *)description {
    return [self.data description];
}

#pragma mark - delegate methods

#pragma mark - event response

#pragma mark - private methods

- (NSUInteger)adjustIndexWithObject:(id<SMBFetchedResultsProtocol>)object index:(NSUInteger)index {
    if (self.sorted) {
        NSMutableOrderedSet *destinationOrderedSet = [self.data mutableCopy];
        [destinationOrderedSet addObject:object];
        [self sortedResultWithOrderedSet:destinationOrderedSet];
        NSUInteger finalIndex = [destinationOrderedSet indexOfObject:object];
        return finalIndex;
    }
    else {
        return index;
    }
}

- (void)sortedResultWithOrderedSet:(NSMutableOrderedSet *)orderedSet {
    __block NSArray *keyPaths = [self.sortKeyPaths componentsSeparatedByString:@","];

    [orderedSet sortWithOptions:NSSortConcurrent|NSSortStable
                usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                               for (NSString *path in keyPaths) {
                                                   id value1 = [obj1 valueForKeyPath:path];
                                                   id value2 = [obj2 valueForKeyPath:path];
                                                   
                                                   NSComparisonResult result;
                                                   if ([value1 isKindOfClass:[NSNumber class]]) {
                                                       result = [value1 compare:value2];
                                                   }
                                                   else if ([value1 isKindOfClass:[NSString class]]) {
                                                       result = [value1 compare:value2 options:self.options];
                                                   }
                                                   else {
                                                       result = NSOrderedSame;
                                                   }
                                                   
                                                   if (result != NSOrderedSame)
                                                       return result;
                                               }
                                               return NSOrderedSame;
                                           }];
}

- (id)objectInDataAtIndex:(NSUInteger)index {
    if (self.countOfData == 0) return nil;
    __block id ret;
    dispatch_sync(_queue, ^{
        ret = [_data objectAtIndex:index];;
    });
    return ret;
}

- (NSArray *)dataAtIndexes:(NSIndexSet *)indexes {
    if (self.countOfData == 0) return nil;
    __block id ret;
    dispatch_sync(_queue, ^{
        ret = [_data objectsAtIndexes:indexes];
    });
    return ret;
}

- (NSUInteger)countOfData {
    __block NSUInteger ret;
    dispatch_sync(_queue, ^{
        ret = [_data count];;
    });
    return ret;
}

- (void)insertObject:(id)object inDataAtIndex:(NSUInteger)index {
    [(id <SMBFetchedResultsProtocol>)object setFetchedResults:self];
    dispatch_barrier_sync(_queue, ^{
        [_data insertObject:object atIndex:index];
    });
}

- (void)insertData:(NSArray *)data atIndexes:(NSIndexSet *)indexes {
    for (id <SMBFetchedResultsProtocol>oneOfData in data) {
        [oneOfData setFetchedResults:self];
    }
    dispatch_barrier_sync(_queue, ^{
        [_data insertObjects:data atIndexes:indexes];
    });
}

- (void)removeObjectFromDataAtIndex:(NSUInteger)index {
    dispatch_barrier_sync(_queue, ^{
        [_data removeObjectAtIndex:index];
    });
}

- (void)removeDataAtIndexes:(NSIndexSet *)indexes {
    dispatch_barrier_sync(_queue, ^{
        [_data removeObjectsAtIndexes:indexes];
    });
}

- (void)moveObjectInDataAtIndex:(NSUInteger)index toIndex:(NSUInteger)toIndex {
    id <SMBFetchedResultsProtocol> object = [self objectInDataAtIndex:index];
    self.moving = YES;
    [self removeObjectFromDataAtIndex:index];
    [self insertObject:object inDataAtIndex:toIndex];
    self.moving = NO;
}

- (void)replaceObjectInDataAtIndex:(NSUInteger)index withObject:(id)object {
    dispatch_barrier_sync(_queue, ^{
        [_data replaceObjectAtIndex:index withObject:object];
    });
}

- (void)replaceDataAtIndexes:(NSIndexSet *)indexes withData:(NSArray *)data {
    dispatch_barrier_sync(_queue, ^{
        [_data replaceObjectsAtIndexes:indexes withObjects:data];
    });
}

#pragma mark - accessor methods

- (BOOL)sorted {
    return self.sortKeyPaths != nil;
}

#pragma mark - api methods


- (void)appendObject:(id)object {
    NSUInteger index = [self adjustIndexWithObject:object index:self.countOfData];
    [self insertObject:object inDataAtIndex:index];
}

- (void)appendObjectsFromArray:(NSArray *)otherArray {
    if (self.sorted) {
        for (id<SMBFetchedResultsProtocol> object in otherArray) {
            NSUInteger index = [self adjustIndexWithObject:object index:-1];
            [self insertObject:object inDataAtIndex:index];
        }
    }
    else {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.countOfData, otherArray.count)];
        [self insertData:otherArray atIndexes:indexSet];
    }
}

- (void)insertObject:(id)object {
    NSUInteger index = [self adjustIndexWithObject:object index:0];
    [self insertObject:object inDataAtIndex:index];
}

- (void)insertObjectsFromArray:(NSArray *)otherArray {
    if (otherArray.count) {
        if (self.sorted) {
            for (id<SMBFetchedResultsProtocol> object in otherArray) {
                NSUInteger index = [self adjustIndexWithObject:object index:-1];
                [self insertObject:object inDataAtIndex:index];
            }
        }
        else {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, otherArray.count)];
            [self insertData:otherArray atIndexes:indexSet];
        }
    }
}

- (void)removeObject:(id<SMBFetchedResultsProtocol>)object {
    NSUInteger index = [_data indexOfObject:object];
    if (index == NSNotFound) {
        return;
    }

    [self removeObjectFromDataAtIndex:index];
}

- (void)removeObjectsFromArray:(NSArray *)otherArray {
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (id <SMBFetchedResultsProtocol> object in otherArray) {
        NSUInteger index = [_data indexOfObject:object];
        if (index != NSNotFound) {
            [indexSet addIndex:index];
        }
    }
    [self removeDataAtIndexes:indexSet];
}

- (void)updateObject:(id)object {
    NSUInteger index = [_data indexOfObject:object];
    if (index == NSNotFound) {
        return;
    }
    [self replaceObjectInDataAtIndex:index withObject:object];
}

- (void)updateObjectsFromArray:(NSArray *)otherArray {
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (id <SMBFetchedResultsProtocol> object in otherArray) {
        NSUInteger index = [_data indexOfObject:object];
        if (index != NSNotFound) {
            [indexSet addIndex:index];
        }
    }
    [self replaceDataAtIndexes:indexSet withData:otherArray];
}

- (void)bubbleObject:(id)object {
    NSUInteger index = [_data indexOfObject:object];
    if (index == NSNotFound) {
        return;
    }
    [self moveObjectInDataAtIndex:index toIndex:0];
}

- (void)moveObjectFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    [self moveObjectInDataAtIndex:fromIndex toIndex:toIndex];
}

@end
