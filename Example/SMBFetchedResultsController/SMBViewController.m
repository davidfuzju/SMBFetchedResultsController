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

@property (readwrite, nonatomic, assign) NSInteger age;

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
        _age = rand()%20;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %d", self.name, self.age];
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
    
    Person *person1 = [[Person alloc] initWithName:@"sherry"];
    Person *person2 = [[Person alloc] initWithName:@"kate"];
    Person *person3 = [[Person alloc] initWithName:@"allen"];
    self.dataSource = [NSMutableOrderedSet orderedSetWithArray:@[person1, person2, person3]];
    SMBFetchedResults *fetchedResults = [[SMBFetchedResults alloc] initWithMutableData:self.dataSource
                                                                          sortKeyPaths:@"age"
                                                                           sortOptions:NSCaseInsensitiveSearch];
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
    Person *person = [[Person alloc] initWithName:@"zoe"];
    [self.fetchedResultsController.fetchedResults insertObject:person];
}

- (IBAction)removeButtonClick:(id)sender {
    if (self.fetchedResultsController.fetchedResults.countOfData > 0) {
        [self.fetchedResultsController.fetchedResults removeObject:[self.fetchedResultsController.fetchedResultsOrderedSet lastObject]];
    }
    else {
        NSLog(@"Error!, remove operation should work under the condition count > 0");
    }
}

- (IBAction)replaceButtonClick:(id)sender {
    if (self.fetchedResultsController.fetchedResults.countOfData > 0) {
        Person *person = [self.fetchedResultsController.fetchedResultsOrderedSet firstObject];
        person.name = @"mary";
        person.age = rand()%20;
        [self.fetchedResultsController.fetchedResults updateObject:person];
    }
    else {
        NSLog(@"Error!, replace operation should work under the condition count > 0");
    }
    
}

- (IBAction)moveButtonClick:(id)sender {
    if (self.fetchedResultsController.fetchedResults.countOfData > 1) {
        NSUInteger lastIndex = self.fetchedResultsController.fetchedResults.countOfData - 1;
        [self.fetchedResultsController.fetchedResults moveObjectFromIndex:lastIndex toIndex:0];
    }
    else {
        NSLog(@"Error!, replace operation should work under the condition count > 0");
    }
}

- (IBAction)insertsButtonClick:(id)sender {
    if (self.fetchedResultsController.fetchedResults.countOfData > 0) {
        Person *person = [[Person alloc] initWithName:@"zoe"];
        Person *person1 = [[Person alloc] initWithName:@"petter"];
        [self.fetchedResultsController.fetchedResults insertObjectsFromArray:@[person, person1]];
    }
}

- (IBAction)removesButtonClick:(id)sender {
    if (self.fetchedResultsController.fetchedResults.countOfData > 3) {
        Person *person = [self.fetchedResultsController.fetchedResults objectInDataAtIndex:1];
        Person *person1 = [self.fetchedResultsController.fetchedResults objectInDataAtIndex:2];
        [self.fetchedResultsController.fetchedResults removeObjectsFromArray:@[person, person1]];
    }
    else {
        NSLog(@"Error!, remove operation should work under the condition count > 0");
    }
}

- (IBAction)replacesButtonClick:(id)sender {
    if (self.fetchedResultsController.fetchedResults.countOfData > 1) {
        Person *person = [self.fetchedResultsController.fetchedResults objectInDataAtIndex:0];
        person.name = @"mary";
        person.age = rand()%20;
        Person *person1 = [self.fetchedResultsController.fetchedResults objectInDataAtIndex:1];
        person1.name = @"tom";
        person1.age = rand()%20;
        NSMutableIndexSet *indexset = [NSMutableIndexSet indexSet];
        [indexset addIndex:0];
        [indexset addIndex:1];
        [self.fetchedResultsController.fetchedResults updateObjectsFromArray:@[person, person1]];
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
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %d", person.name, person.age];
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
