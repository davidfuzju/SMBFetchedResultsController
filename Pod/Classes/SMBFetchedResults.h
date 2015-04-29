//
//  SMBFetchedResults.h
//
//  Created by David Fu on 3/16/15.
//  Copyright (c) 2015 David Fu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SMBFetchedResults;

@protocol SMBFetchedResultsProtocol <NSObject>

@property (readwrite, nonatomic, weak) SMBFetchedResults *fetchedResults;

@end

/**
 NSMutableOrderedSet KVO container
 */

@interface SMBFetchedResults : NSObject

@property (readonly, nonatomic, strong) NSMutableOrderedSet *data;

@property (readonly, nonatomic, assign) BOOL moving;

- (instancetype)initWithMutableData:(NSMutableOrderedSet *)mutableData;

- (void)appendObject:(id <SMBFetchedResultsProtocol>)object;
- (void)appendObjectsFromArray:(NSArray *)otherArray;

- (void)insertObject:(id <SMBFetchedResultsProtocol>)object;
- (void)insertObjectsFromArray:(NSArray *)otherArray;

- (void)bubbleObject:(id <SMBFetchedResultsProtocol>)object;
- (void)updateObject:(id <SMBFetchedResultsProtocol>)object;

- (void)removeObject:(id <SMBFetchedResultsProtocol>)object;

- (NSUInteger)indexOfObject:(id <SMBFetchedResultsProtocol>)anObject;

- (id <SMBFetchedResultsProtocol>)objectInDataAtIndex:(NSUInteger)index;
- (NSArray *)dataAtIndexes:(NSIndexSet *)indexes;
- (NSUInteger)countOfData;

/** KVC one-to-many compliance interface */
- (void)insertObject:(id <SMBFetchedResultsProtocol>)object inDataAtIndex:(NSUInteger)index;
- (void)insertData:(NSArray *)data atIndexes:(NSIndexSet *)indexes;

- (void)removeObjectFromDataAtIndex:(NSUInteger)index;
- (void)removeDataAtIndexes:(NSIndexSet *)indexes;

- (void)replaceObjectInDataAtIndex:(NSUInteger)index withObject:(id <SMBFetchedResultsProtocol>)object;
- (void)replaceDataAtIndexes:(NSIndexSet *)indexes withData:(NSArray *)data;

/** custom KVC one-to-many compliance interface for move */
- (void)moveObjectInDataAtIndex:(NSUInteger)index toIndex:(NSUInteger)toIndex;

/** forbid */
- (instancetype)init __attribute__((unavailable("Invoke the designated initializer `initWithMutableData` instead.")));
- (instancetype)new __attribute__((unavailable("Invoke the designated initializer `initWithMutableData` instead.")));
@end
