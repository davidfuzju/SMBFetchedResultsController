# SMBFetchedResultsController

[![CI Status](http://img.shields.io/travis/David Fu/SMBFetchedResultsController.svg?style=flat)](https://travis-ci.org/David Fu/SMBFetchedResultsController)
[![Version](https://img.shields.io/cocoapods/v/SMBFetchedResultsController.svg?style=flat)](http://cocoapods.org/pods/SMBFetchedResultsController)
[![License](https://img.shields.io/cocoapods/l/SMBFetchedResultsController.svg?style=flat)](http://cocoapods.org/pods/SMBFetchedResultsController)
[![Platform](https://img.shields.io/cocoapods/p/SMBFetchedResultsController.svg?style=flat)](http://cocoapods.org/pods/SMBFetchedResultsController)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

Use it just like NSFetchedResultsController, set it up:

    - (void)viewDidLoad {
        [super viewDidLoad];
        
        self.dataSource = [NSMutableOrderedSet orderedSetWithObject:[[Person alloc] initWithName:@"sherry"]];
        SMBFetchedResults *fetchedResults = [[SMBFetchedResults alloc] initWithMutableData:self.dataSource];
        self.fetchedResultsController = [[SMBFetchedResultsController alloc] initWithFetchedResults:fetchedResults title:@"SMB" delegate:self];
    }

insert operation to SMBFetchedResults data struct:

    - (IBAction)insertButtonClick:(id)sender {
        Person *person = [[Person alloc] initWithName:@"david"];
        [self.fetchedResultsController.fetchedResults insertObject:person inDataAtIndex:0];
    }

that's it!

## Requirements

## Installation

SMBFetchedResultsController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SMBFetchedResultsController"
```

## Author

David Fu, david.fu.zju.dev@gmail.com

## License

SMBFetchedResultsController is available under the MIT license. See the LICENSE file for more info.
