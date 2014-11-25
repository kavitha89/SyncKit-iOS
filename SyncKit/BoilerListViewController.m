//
//  BoilerListViewController.m
//  SyncKit
//
//  Created by Kavitha on 6/6/14.
//  Copyright (c) 2014 Cognizant. All rights reserved.
//

#import "BoilerListViewController.h"
#import "kSyncKit.h"
#import "kSyncEngine.h"
#import "kCoreDataController.h"
#import "BoilerAddEditViewContoller.h"
#import "SettingsViewController.h"
#import "NSManagedObject+kSyncKit.h"
#import "Boiler.h"


@interface BoilerListViewController ()<kSyncConflictManagerDelegate>
{
    NSMutableArray *newsItems;
    kSyncKit *syncKit;
}
@property (strong, nonatomic) UIActivityIndicatorView *syncInProgressIndicator;
@end

@implementation BoilerListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Boiler Items";
    
    self.syncInProgressIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(self.view.center.x, self.view.center.y, 50,50 )];
    self.syncInProgressIndicator.center = CGPointMake(self.tableView.center.x, self.tableView.center.y-64);
    self.syncInProgressIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.syncInProgressIndicator.color =[UIColor blueColor];
    [self.view addSubview:self.syncInProgressIndicator];
    [self.view bringSubviewToFront:self.syncInProgressIndicator];
    
    [syncKit.syncEngine.conflictManager setConflictResolutionDelegate:self];

    UIBarButtonItem *addNewsButton  = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewsPressed)];
    
    [self.navigationItem setRightBarButtonItems:[[NSArray alloc]initWithObjects:addNewsButton,nil]];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self itemsSynced];

    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(itemsSynced) name:ckSyncEngineSyncCompletedNotificationName object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(conflictedObjects:) name:ckSyncEngineConflictedObjectsNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

- (void)itemsSynced
{
    [self.syncInProgressIndicator stopAnimating];
    [self.syncInProgressIndicator setHidden:YES];
    newsItems = [NSMutableArray arrayWithArray:[[kSyncEngine sharedEngine] fetchAllRecordsForManagedObjectClass:@"Boiler"]];
    [self.tableView reloadData];
}

- (void)conflictedObjects:(NSNotification *)notification {
    
    NSMutableDictionary *conflcitData = notification.object;

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

/*- (void)conflictedObjects:(NSNotification *)notification
 {
 
 
 }*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addNewsItem"] && sender == self) {
        BoilerAddEditViewContoller *addEditVC = [segue destinationViewController];
        addEditVC.boilerObject = [newsItems objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [newsItems count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
    }

    
	// Configure the cell to show the data.
	Boiler *newsItem = [newsItems objectAtIndex:indexPath.row];
	cell.textLabel.text =  newsItem.bName;
    cell.detailTextLabel.text = newsItem.bLocation;
    
	//this adds the arrow to the right hand side.
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
	return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"addNewsItem" sender:self];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Remove the row from data model
    if (editingStyle==UITableViewCellEditingStyleDelete)
    {
        Boiler* news = [newsItems objectAtIndex:indexPath.row];
        [news markAsDeleted];
        [[kCoreDataController sharedController] saveContextToPersistentStore];
        [newsItems removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    }
    
}

- (void)addNewsPressed {
    [self performSegueWithIdentifier:@"addNewsItem" sender:nil];
}

- (void)syncButtonPressed {
    [self.syncInProgressIndicator setHidden:NO];
    [self.syncInProgressIndicator startAnimating];
    [[kSyncKit sharedKit] startSync];
}
-(void)settingButtonPressed{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
    SettingsViewController *settingVC = [storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    [self.navigationController pushViewController:settingVC animated:YES];
}
@end
