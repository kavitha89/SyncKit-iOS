//
//  TransfomerListViewController.m
//  SyncKit
//
//  Created by Kavitha on 8/5/14.
//  Copyright (c) 2014 Cognizant. All rights reserved.
//

#import "TransfomerListViewController.h"
#import "kSyncKit.h"
#import "kCoreDataController.h"
#import "TransfomerAddEditViewController.h"
#import "NSManagedObject+kSyncKit.h"
#import "Pipe.h"

@interface TransfomerListViewController ()<kSyncConflictManagerDelegate>
{
    kSyncKit *syncKit;
    NSMutableArray *trItems;
}
@end

@implementation TransfomerListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Transformers";
    
    [syncKit.syncEngine.conflictManager setConflictResolutionDelegate:self];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(itemsSynced) name:ckSyncEngineSyncCompletedNotificationName object:nil];
    

    
    UIBarButtonItem *addNewsButton  = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAuthorPressed)];
    
    [self.navigationItem setRightBarButtonItems:[[NSArray alloc]initWithObjects:addNewsButton,nil]];
    
    
    [self itemsSynced];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(conflictedObjects:) name:ckSyncEngineConflictedObjectsNotification object:nil];

}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)itemsSynced
{
    trItems = [NSMutableArray arrayWithArray:[[kSyncEngine sharedEngine] fetchAllRecordsForManagedObjectClass:@"Transformer"]];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addAuthorPressed {
    [self performSegueWithIdentifier:@"transformerDetails" sender:nil];
}

- (void)conflictedObjects:(NSNotification *)notification {
    
    NSMutableDictionary *conflcitData = notification.object;
    
    //accepting client data
    if(conflcitData.count>0)
    {
        
        NSMutableDictionary *resolvedData = [NSMutableDictionary dictionary];
        
        
        for(id key in conflcitData.allKeys)
        {
            id obj = [conflcitData objectForKey:key];
            
            if ([obj isKindOfClass:[NSArray class]]) {
                
                for(id obj1 in obj)
                {
                    NSLog(@"objects client data: %@",[obj1 objectForKey:@"clientData"]);
                    NSLog(@"objects server data: %@",[obj1 objectForKey:@"serverData"]);
                    
                    NSMutableDictionary *resolvedObject = [NSMutableDictionary dictionaryWithDictionary:[obj1 objectForKey:@"clientData"]];
                    
                    for (id key in [obj1 objectForKey:@"clientData"]) {
                        
                        [resolvedObject setObject:[[obj1 objectForKey:@"clientData"] objectForKey:key] forKey:key];
                    }
                    
                    if([resolvedData objectForKey:key])
                    {
                        NSMutableArray *preExisitngConflictObjects = [resolvedData objectForKey:key];
                        [preExisitngConflictObjects addObject:resolvedObject];
                        
                        [resolvedData setObject:preExisitngConflictObjects forKey:key];
                    }
                    
                    else
                    {
                        NSMutableArray *preExisitngConflictObjects = [resolvedData objectForKey:key];
                        if(preExisitngConflictObjects== nil)
                            preExisitngConflictObjects = [NSMutableArray array];
                        
                        if(![preExisitngConflictObjects containsObject:resolvedObject])
                            [preExisitngConflictObjects addObject:resolvedObject];
                        
                        [resolvedData setObject:preExisitngConflictObjects forKey:key];
                        
                    }
                    
                }
                
            }
        }
        
        
        [syncKit.syncEngine.conflictManager resolveConflictsInDictionary:resolvedData];
        
        
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [trItems count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
    }
	//if you want to add an image to your cell, here's how
	UIImage *image = [UIImage imageNamed:@"icon.png"];
	cell.imageView.image = image;
    
	// Configure the cell to show the data.
	Transformer *trItem = [trItems objectAtIndex:indexPath.row];
	cell.textLabel.text =  trItem.trsName;
    cell.detailTextLabel.text = trItem.trsLocation;
    
	//this adds the arrow to the right hand side.
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
	return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
    TransfomerAddEditViewController *addEditVC = [storyboard instantiateViewControllerWithIdentifier:@"TransfomerAddEditViewController"];
     addEditVC.trObject = [trItems objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    [self.navigationController pushViewController:addEditVC animated:YES];
    
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Remove the row from data model
    if (editingStyle==UITableViewCellEditingStyleDelete)
    {
        Transformer *trItem = [trItems objectAtIndex:indexPath.row];
        [trItem markAsDeleted];
        [[kCoreDataController sharedController] saveContextToPersistentStore];
        [trItems removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    }
    
}
@end
