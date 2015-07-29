//
//  SMBFetchedResultsController.h
//
//  Created by David Fu on 3/13/15.
//  Copyright (c) 2015 ctrip. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SMBFetchedResults.h"

typedef NS_ENUM(NSUInteger, SMBFetchedResultsChangeType) {
    SMBFetchedResultsChangeInsert = NSKeyValueChangeInsertion,
    SMBFetchedResultsChangeDelete = NSKeyValueChangeRemoval,
    SMBFetchedResultsChangeMove = 5,
    SMBFetchedResultsChangeUpdate = NSKeyValueChangeReplacement
};

@class SMBFetchedResultsController;

@protocol SMBFetchedResultsControllerDelegate <NSObject>

@optional

/**
 
 `objects` will always return the array of changed objects, `type` will always return the type of change.
 
 when insert, indexPaths will return nil, newIdnexPaths will return the array of indexPaths for inserted objects
 when delete, newIndexPaths will return nil, indexPaths will return the array of indexPaths for deleted objects
 when move, indexPaths will return the array of a single indexPath for the obejct before it moved,
    newIndexpaths will return the array of a single indexPath for the object after it moved
 when update, newIndexPaths will return nil, indexPaths will returen the array of indexPaths for updated objects

 */

- (void)controller:(SMBFetchedResultsController *)controller
   didChangeObjects:(NSArray *)objects
       atIndexPaths:(NSArray *)indexPaths
     forChangeType:(SMBFetchedResultsChangeType)type
      newIndexPaths:(NSArray *)newIndexPaths;

@optional
- (void)controllerWillChangeContent:(SMBFetchedResultsController *)controller;

@optional
- (void)controllerDidChangeContent:(SMBFetchedResultsController *)controller;

@end

/**
 
 SMBFetchedResultsController provide a NSFetchedResultController's style interface to monitor datasource like NSMutableOrderedSet, every
 operation to datasource will notify the delegate with appropriate parameters

 SMBFetchedResultsController builds on KVO by SMBFetchedResults implementing KVC's one-to-manay relationship, 
 and SMBFetchedResultsController implements its own `move` change type;
 */

@interface SMBFetchedResultsController : NSObject

@property (readwrite, nonatomic, weak) id <SMBFetchedResultsControllerDelegate> delegate;

@property (readonly, nonatomic, strong) SMBFetchedResults *fetchedResults;

@property (readonly, nonatomic, copy) NSString *title;

- (instancetype)initWithFetchedResults:(SMBFetchedResults *)results title:(NSString *)title;

- (instancetype)initWithFetchedResults:(SMBFetchedResults *)results title:(NSString *)title delegate:(id <SMBFetchedResultsControllerDelegate>)delegate;

- (void)setSortKeyPath:(NSString *)sortKeyPath sortOptions:(NSStringCompareOptions)options;

- (NSIndexPath *)indexPathForLastObject;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

- (NSIndexPath *)indexPathForObject:(id)object;

@end
