//
//  ModelSelectionTableViewController.m
//  SyncKit
//
//  Created by Kavitha on 8/5/14.
//  Copyright (c) 2014 Cognizant. All rights reserved.
//

#import "ModelSelectionTableViewController.h"
#import "kSyncKit.h"
#import "SettingsViewController.h"
#import "PipesListViewController.h"
#import "BoilerListViewController.h"
#import "TurbineListViewController.h"
#import "TransfomerListViewController.h"


@interface ModelSelectionTableViewController ()

{
    kSyncKit *syncKit;
}

@property (strong, nonatomic) UIActivityIndicatorView *syncInProgressIndicator;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ModelSelectionTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Registered Models";
    
    self.screenName = @"Sync Process";
    
    [self initializeSyncKit];
    
    self.syncInProgressIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(self.view.center.x, self.view.center.y, 50,50 )];
    self.syncInProgressIndicator.center = CGPointMake(self.tableView.center.x, self.tableView.center.y-64);
    self.syncInProgressIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.syncInProgressIndicator.color =[UIColor blueColor];
    [self.view addSubview:self.syncInProgressIndicator];
    [self.view bringSubviewToFront:self.syncInProgressIndicator];
    
    //[self.tableView reloadData];
    
    UIBarButtonItem *syncButton  = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(syncButtonPressed)];
    [self.navigationItem setLeftBarButtonItem:syncButton];
    
    UIBarButtonItem *settingButton  = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(settingButtonPressed)];
    
    [self.navigationItem setRightBarButtonItems:[[NSArray alloc]initWithObjects:settingButton,nil]];

    [self syncButtonPressed];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeSyncKit
{
    
#ifdef PARE_DOT_COM_TARGET
    syncKit = [kSyncKit sharedKitWithConfigurationFile:@"SyncKitParameters-BoilerPlant.plist"];
    [syncKit setupSyncComponentWithLocalDBModelName:@"SyncDemoModel"];
    [syncKit.syncEngine registerNSManagedObjectClassToSync:NSClassFromString(@"Boiler")];
    [syncKit.syncEngine registerNSManagedObjectClassToSync:NSClassFromString(@"Turbine")];
    [syncKit.syncEngine registerNSManagedObjectClassToSync:NSClassFromString(@"Pipe")];
    [syncKit.syncEngine registerNSManagedObjectClassToSync:NSClassFromString(@"Transformer")];

    [syncKit.syncEngine.conflictManager setConflictResolutionType:kConflictResolutionClientWins];
#endif
    
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(conflictedObjects:) name:ckSyncEngineConflictedObjectsNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(itemsSynced) name:ckSyncEngineSyncCompletedNotificationName object:nil];

}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
- (void)syncButtonPressed {
    [self.syncInProgressIndicator setHidden:NO];
    [self.syncInProgressIndicator startAnimating];
    [[kSyncKit sharedKit] startSync];
}

- (void)itemsSynced
{
    [self.syncInProgressIndicator stopAnimating];
    [self.syncInProgressIndicator setHidden:YES];
    [self.tableView reloadData];
}


-(void)settingButtonPressed{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
    SettingsViewController *settingVC = [storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    [self.navigationController pushViewController:settingVC animated:YES];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return syncKit.syncEngine.registeredClassesToSync.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"modelCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [syncKit.syncEngine.registeredClassesToSync objectAtIndex:indexPath.row];
    // Configure the cell...
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[syncKit.syncEngine.registeredClassesToSync objectAtIndex:indexPath.row] isEqualToString:@"Boiler"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
        BoilerListViewController *settingVC = [storyboard instantiateViewControllerWithIdentifier:@"BoilerListViewController"];
        [self.navigationController pushViewController:settingVC animated:YES];
        
    }
    
    else if ([[syncKit.syncEngine.registeredClassesToSync objectAtIndex:indexPath.row] isEqualToString:@"Pipe"])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
        PipesListViewController *settingVC = [storyboard instantiateViewControllerWithIdentifier:@"PipesListViewController"];
        [self.navigationController pushViewController:settingVC animated:YES];
    }
    
    else if ([[syncKit.syncEngine.registeredClassesToSync objectAtIndex:indexPath.row] isEqualToString:@"Transformer"])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
        TransfomerListViewController *settingVC = [storyboard instantiateViewControllerWithIdentifier:@"TransfomerListViewController"];
        [self.navigationController pushViewController:settingVC animated:YES];
    }
    
    else if ([[syncKit.syncEngine.registeredClassesToSync objectAtIndex:indexPath.row] isEqualToString:@"Turbine"])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
        TurbineListViewController *settingVC = [storyboard instantiateViewControllerWithIdentifier:@"TurbineListViewController"];
        [self.navigationController pushViewController:settingVC animated:YES];
    }
    
}


@end
