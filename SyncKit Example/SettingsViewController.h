//
//  SettingsViewController.h
//  SyncKit
//
//  Created by Kavitha on 17/07/14.
//  Copyright (c) 2014 Cognizant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RadioButton.h"

@interface SettingsViewController : UIViewController
@property (nonatomic, weak) IBOutlet RadioButton* clientRadioButton;
@property (nonatomic, weak) IBOutlet RadioButton* serverRadioButton;
@property (weak, nonatomic) IBOutlet RadioButton *customMergeButton;
@property (weak, nonatomic) IBOutlet RadioButton *mostRecentWinsButton;

-(IBAction)onRadioBtn:(id)sender;
@end
