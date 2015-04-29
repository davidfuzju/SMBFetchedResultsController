//
//  SMBFetchedResultsController.m
//
//  Created by David Fu on 3/13/15.
//  Copyright (c) 2015 ctrip. All rights reserved.
//

#import "SMBFetchedResultsController.h"
#import <UIKit/UIKit.h>

@interface SMBFetchedResultsController () {
    NSArray *_oldObjects;
    NSArray *_oldIndexPaths;
}

@property (readwrite, nonatomic, strong) SMBFetchedResults *fetchedResults;

@end

static char MyObservationContext;

@implementation SMBFetchedResultsController

- (instancetype)initWithFetchedResults:(SMBFetchedResults *)results title:(NSString *)title{
    return [self initWithFetchedResults:results title:title delegate:nil];
}

- (instancetype)initWithFetchedResults:(SMBFetchedResults *)fetchedResults title:(NSString *)title delegate:(id <SMBFetchedResultsControllerDelegate>)delegate {
    self = [super init];
    if (self) {
        _fetchedResults = fetchedResults;
        _title = title;
        _delegate = delegate;
        [fetchedResults addObserver:self
                         forKeyPath:@"data"
                            options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                            context:&MyObservationContext];
    }
    return self;
}

- (void)dealloc{
    [self.fetchedResults removeObserver:self forKeyPath:@"data"];
}

- (NSIndexPath *)indexPathForLastObject {
    if (!self.fetchedResults.countOfData) {
        return nil;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.fetchedResults.countOfData - 1 inSection:0];
    return indexPath;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    return [self.fetchedResults objectInDataAtIndex:indexPath.row];
}

- (NSIndexPath *)indexPathForObject:(id)object {
    NSUInteger row = [self.fetchedResults indexOfObject:object];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    return indexPath;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &MyObservationContext) {
        if ([keyPath isEqualToString:@"data"]) {
            if (object == self.fetchedResults) {
                    NSKeyValueChange kind = [change[NSKeyValueChangeKindKey] unsignedIntegerValue];
                    NSArray *newObject = change[NSKeyValueChangeNewKey];
                    NSArray *oldObject = change[NSKeyValueChangeOldKey];
                    NSIndexSet *indexes = (NSIndexSet *)change[NSKeyValueChangeIndexesKey];
                    NSMutableArray *indexPathsArray = [NSMutableArray array];
                    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                        [indexPathsArray addObject:indexPath];
                    }];
                
                /** NSKeyValueChangeMovement
                 move in this lab is combine with delete and insert, so the first
                 delete at object's old indexpath should be reserved
                 */
                if (self.fetchedResults.moving
                    && kind == NSKeyValueChangeRemoval) {
                    _oldObjects = oldObject;
                    _oldIndexPaths = indexPathsArray;
                    return;
                }
                
                /** NSKeyValueChangeMovement
                 move in this lab is combine with delete and insert, so the second
                 insert means my custom NSKeyValueChangeMovement should fire
                 */
                if (self.fetchedResults.moving
                    && kind == NSKeyValueChangeInsertion
                    && [_oldObjects isEqualToArray:newObject]) {

                    /** becouse KVO change enum does not contain NSKeyValueChangeMovement, so I use 5 instead; */
                    kind = 5;
                }
                
                [self notifyBeginChanges];
                switch (kind) {
                    /** NSKeyValueChangeSetting is not support in this lib */
                    case NSKeyValueChangeSetting: {
                    }
                        break;
                    case NSKeyValueChangeInsertion: {
                        [self notifyChangedObjects:newObject atIndexPaths:nil forChangeType:SMBFetchedResultsChangeInsert newIndexPaths:indexPathsArray];
                    }
                        break;
                    case NSKeyValueChangeRemoval: {

                        [self notifyChangedObjects:oldObject atIndexPaths:indexPathsArray forChangeType:SMBFetchedResultsChangeDelete newIndexPaths:nil];
                    }
                        break;
                    /** KVO's NSkeyValueChangeReplacement in one to many Compliance for NSMutableOrderedSet
                     did not offer the updated objects' indexpaths*/
                    case NSKeyValueChangeReplacement: {
                        NSMutableArray *indexPaths2 = [NSMutableArray array];
                        for (id <SMBFetchedResultsProtocol> result in oldObject) {
                            [indexPaths2 addObject:[self indexPathForObject:result]];
                        }
                        [self notifyChangedObjects:oldObject atIndexPaths:indexPaths2 forChangeType:SMBFetchedResultsChangeUpdate newIndexPaths:nil];
                    }
                        break;
                    /** 5 sandfor my custom NSKeyValueChangeMovement */
                    case 5: {
                        [self notifyChangedObjects:newObject atIndexPaths:_oldIndexPaths forChangeType:SMBFetchedResultsChangeMove newIndexPaths:indexPathsArray];
                        _oldObjects = nil;
                        _oldIndexPaths = nil;
                    }
                        break;
                    default:
                        break;
                }
                [self notifyEndChanges];
            }
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)notifyBeginChanges {
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(controllerWillChangeContent:)]) {
        [self.delegate controllerWillChangeContent:self];
    }
    else {
    }
}

- (void)notifyChangedObjects:(NSArray *)objects atIndexPaths:(NSArray *)indexPaths
                                               forChangeType:(SMBFetchedResultsChangeType)type
                                               newIndexPaths:(NSArray *)newIndexPaths {
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(controller:didChangeObjects:atIndexPaths:forChangeType:newIndexPaths:)]) {
        [self.delegate controller:self
                 didChangeObjects:objects
                     atIndexPaths:indexPaths
                    forChangeType:type
                    newIndexPaths:newIndexPaths];
    }
    else {
    }
}

- (void)notifyEndChanges {
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(controllerDidChangeContent:)]) {
        [self.delegate controllerDidChangeContent:self];
    }
    else {
    }
}

@end
