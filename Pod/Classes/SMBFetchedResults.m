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

@property (readwrite, nonatomic, assign) BOOL moving;

@end

@implementation SMBFetchedResults

#pragma mark - life cycle

- (instancetype)init {
    return [self initWithMutableData:[NSMutableOrderedSet orderedSet]];
}

- (instancetype)initWithMutableData:(NSMutableOrderedSet *)mutableData {
    self = [super init];
    if (self) {
        _data = mutableData;
        _moving = NO;
        _queue = dispatch_queue_create("CTFetchecResults queue", NULL);
    }
    return self;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([key isEqualToString:@"data"]) {
        return YES;
    }
    return [super automaticallyNotifiesObserversForKey:key];
}

#pragma mark - delegate methods

#pragma mark - event response

#pragma mark - private methods

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

#pragma mark - api methods


- (void)appendObject:(id)object {
    [self insertObject:object inDataAtIndex:self.countOfData];
}

- (void)appendObjectsFromArray:(NSArray *)otherArray {
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.countOfData, otherArray.count)];
    [self insertData:otherArray atIndexes:indexSet];
}

- (void)insertObject:(id)object {
    [self insertObject:object inDataAtIndex:0];
}

- (void)insertObjectsFromArray:(NSArray *)otherArray {
    if (otherArray.count) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, otherArray.count)];
        [self insertData:otherArray atIndexes:indexSet];
    }
}

- (void)bubbleObject:(id)object {
    NSUInteger index = [_data indexOfObject:object];
    [self moveObjectInDataAtIndex:index toIndex:0];
}

- (void)removeObject:(id<SMBFetchedResultsProtocol>)object {
    NSUInteger index = [_data indexOfObject:object];
    [self removeObjectFromDataAtIndex:index];
}

- (void)updateObject:(id)object {
    NSUInteger index = [_data indexOfObject:object];
    [self replaceObjectInDataAtIndex:index withObject:object];
}

- (NSUInteger)indexOfObject:(id)anObject {
    return [_data indexOfObject:anObject];
}

- (NSString *)description {
    return [_data description];
}

@end
