//
//  PipesListViewController.m
//  SyncKit
//
//  Created by Kavitha on 8/5/14.
//  Copyright (c) 2014 Cognizant. All rights reserved.
//

#import "PipesListViewController.h"
#import "kSyncKit.h"
#import "kCoreDataController.h"
#import "PipeAddEditViewController.h"
#import "NSManagedObject+kSyncKit.h"
#import "Pipe.h"

@interface PipesListViewController ()<kSyncConflictManagerDelegate>
{
    kSyncKit *syncKit;
    NSMutableArray *pipeItems;
}
@end

@implementation PipesListViewController

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
    
    self.title = @"Pipes";
    
    [syncKit.syncEngine.conflictManager setConflictResolutionDelegate:self];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(itemsSynced) name:ckSyncEngineSyncCompletedNotificationName object:nil];
    

    
    UIBarButtonItem *addNewsButton  = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPipePressed)];
    
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
    pipeItems = [NSMutableArray arrayWithArray:[[kSyncEngine sharedEngine] fetchAllRecordsForManagedObjectClass:@"Pipe"]];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addPipePressed {
    [self performSegueWithIdentifier:@"pipeDetails" sender:nil];
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
    return [pipeItems count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"pipeCell";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
    }
    
	// Configure the cell to show the data.
	Pipe *pipeItem = [pipeItems objectAtIndex:indexPath.row];
	cell.textLabel.text =  pipeItem.pLocation;
    cell.detailTextLabel.text = pipeItem.pCurrentContainment;
    
	//this adds the arrow to the right hand side.
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
	return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PipeAddEditViewController *addEditVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PipeAddEditViewController"];
     addEditVC.pipeObject = [pipeItems objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    [self.navigationController pushViewController:addEditVC animated:YES];
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Remove the row from data model
    if (editingStyle==UITableViewCellEditingStyleDelete)
    {
        Pipe *pipeItem = [pipeItems objectAtIndex:indexPath.row];
        [pipeItem markAsDeleted];
        [[kCoreDataController sharedController] saveContextToPersistentStore];
        [pipeItems removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    }
    
}
@end
