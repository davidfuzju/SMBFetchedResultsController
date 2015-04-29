//
//  SMBViewController.m
//  SMBFetchedResultsController
//
//  Created by David Fu on 04/29/2015.
//  Copyright (c) 2014 David Fu. All rights reserved.
//

#import "SMBViewController.h"
#import "SMBFetchedResultsController.h"

static NSString *generateUUID() {
    NSString *result = nil;
    
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    if (uuid)
    {
        result = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
    }
    
    return result;
}

@interface Person : NSObject <SMBFetchedResultsProtocol>

@property (readwrite, nonatomic, copy) NSString *name;

@property (readonly, nonatomic, copy) NSString *identity;

@property (readwrite, nonatomic, weak) SMBFetchedResults *fetchedResults;

- (instancetype)initWithName:(NSString *)name;

@end

@implementation Person

- (instancetype)init {
    return [self initWithName:nil];
}

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = name;
        _identity = generateUUID();
    }
    return self;
}

@end

@interface SMBViewController () <SMBFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (readwrite, nonatomic, strong) NSMutableOrderedSet *dataSource;
@property (readwrite, nonatomic, strong) SMBFetchedResultsController *fetchedResultsController;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SMBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.dataSource = [NSMutableOrderedSet orderedSetWithObject:[[Person alloc] initWithName:@"sherry"]];
    SMBFetchedResults *fetchedResults = [[SMBFetchedResults alloc] initWithMutableData:self.dataSource];
    self.fetchedResultsController = [[SMBFetchedResultsController alloc] initWithFetchedResults:fetchedResults
                                                                                          title:@"SMB"
                                                                                       delegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)insertButtonClick:(id)sender {
    Person *person = [[Person alloc] initWithName:@"david"];
    [self.fetchedResultsController.fetchedResults insertObject:person inDataAtIndex:0];
}

- (IBAction)removeButtonClick:(id)sender {
    if (self.fetchedResultsController.fetchedResults.countOfData > 0) {
        [self.fetchedResultsController.fetchedResults removeObjectFromDataAtIndex:0];
    }
    else {
        NSLog(@"Error!, remove operation should work under the condition count > 0");
    }
}

- (IBAction)replaceButtonClick:(id)sender {
    if (self.fetchedResultsController.fetchedResults.countOfData > 0) {
        Person *person = [self.fetchedResultsController.fetchedResults objectInDataAtIndex:0];
        person.name = @"mary";
        [self.fetchedResultsController.fetchedResults replaceObjectInDataAtIndex:0 withObject:person];
    }
    else {
        NSLog(@"Error!, replace operation should work under the condition count > 0");
    }
    
}

- (IBAction)moveButtonClick:(id)sender {
    if (self.fetchedResultsController.fetchedResults.countOfData > 1) {
        NSUInteger lastIndex = self.fetchedResultsController.fetchedResults.countOfData - 1;
        [self.fetchedResultsController.fetchedResults moveObjectInDataAtIndex:lastIndex toIndex:0];
    }
    else {
        NSLog(@"Error!, replace operation should work under the condition count > 0");
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fetchedResultsController.fetchedResults.countOfData;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    Person *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = person.name;
    cell.detailTextLabel.text = person.identity;
    return cell;
}

#pragma mark SMBFetchedResultsControllerDelegate

- (void)controller:(SMBFetchedResultsController *)controller
  didChangeObjects:(NSArray *)objects
      atIndexPaths:(NSArray *)indexPaths
     forChangeType:(SMBFetchedResultsChangeType)type
     newIndexPaths:(NSArray *)newIndexPaths {
    switch (type) {
        case SMBFetchedResultsChangeDelete: {
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case SMBFetchedResultsChangeInsert: {
            [self.tableView insertRowsAtIndexPaths:newIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case SMBFetchedResultsChangeUpdate: {
            [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case SMBFetchedResultsChangeMove: {
            [self.tableView moveRowAtIndexPath:[indexPaths firstObject] toIndexPath:[newIndexPaths firstObject]];
        }
            break;
        default:
            break;
    }
}

- (void)controllerWillChangeContent:(SMBFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(SMBFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
