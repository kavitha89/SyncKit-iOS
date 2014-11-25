//
//  SettingsViewController.m
//  SyncKit
//
//  Created by Kavitha on 17/07/14.
//  Copyright (c) 2014 Cognizant. All rights reserved.
//

#import "SettingsViewController.h"
#import "kSyncKit.h"

@interface SettingsViewController ()
{
    NSMutableArray *newsItems;
    kSyncKit *syncKit;
}
@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Settings";
    
}
- (void)viewWillAppear:(BOOL)animated
{
    
    switch ([kSyncKit sharedKit].syncEngine.conflictManager.conflictResolutionType) {
            
        case kConflictResolutionServerWins:
        {
            self.serverRadioButton.selected = YES;
            break;
        }
            
        case kConflictResolutionClientWins:
        {
            self.clientRadioButton.selected = YES;
            break;
        }
            
        case kConflictResolutionCustomMerge:
        {
            self.customMergeButton.selected = YES;
            break;
        }
            case kConflictResolutionMostRecentWins:
        {
            self.mostRecentWinsButton.selected = YES;
            break;
        }
            
            
        default:
            break;
    }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)onRadioBtn:(UIButton*)sender
{
    if(sender.selected) {
		NSLog(@"Selected type: %@", sender.titleLabel.text);
        if([sender.titleLabel.text isEqualToString:@"Client Wins"])
        {
            [[kSyncKit sharedKit].syncEngine.conflictManager setConflictResolutionType:kConflictResolutionClientWins];
         }
        else if([sender.titleLabel.text isEqualToString:@"Server Wins"])
        {
           [[kSyncKit sharedKit].syncEngine.conflictManager setConflictResolutionType:kConflictResolutionServerWins];
        }
       
        else if([sender.titleLabel.text isEqualToString:@"Custom Merge Wins"])
        {
            [[kSyncKit sharedKit].syncEngine.conflictManager setConflictResolutionType:kConflictResolutionCustomMerge];
        }
	}
}


@end
