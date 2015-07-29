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

@property (readonly, nonatomic, copy) NSString *sortKeyPaths;

@property (readonly, nonatomic, assign) NSStringCompareOptions options;

@property (readonly, nonatomic, assign) BOOL moving;

@property (readonly, nonatomic, assign) BOOL sorted;

- (void)sortedResultWithOrderedSet:(NSMutableOrderedSet *)orderedSet;

- (instancetype)initWithMutableData:(NSMutableOrderedSet *)mutableData;
- (instancetype)initWithMutableData:(NSMutableOrderedSet *)mutableData sortKeyPaths:(NSString *)sortKeyPaths sortOptions:(NSStringCompareOptions)options;

- (void)appendObject:(id <SMBFetchedResultsProtocol>)object;
- (void)appendObjectsFromArray:(NSArray *)otherArray;

- (void)insertObject:(id <SMBFetchedResultsProtocol>)object;
- (void)insertObjectsFromArray:(NSArray *)otherArray;

- (void)removeObject:(id <SMBFetchedResultsProtocol>)object;
- (void)removeObjectsFromArray:(NSArray *)otherArray;

- (void)updateObject:(id <SMBFetchedResultsProtocol>)object;
- (void)updateObjectsFromArray:(NSArray *)otherArray;

- (void)bubbleObject:(id <SMBFetchedResultsProtocol>)object;

- (void)moveObjectFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

@end
