//
//  TurbineAddEditViewController.m
//  SyncKit
//
//  Created by Kavitha on 06/08/14.
//  Copyright (c) 2014 Cognizant. All rights reserved.
//

#import "TurbineAddEditViewController.h"
#import "kCoreDataController.h"

@interface TurbineAddEditViewController ()<UITextFieldDelegate,UIActionSheetDelegate>
{
    
    UITextField * trbLocationField;
    UITextField * trbNameField;
    UITextField * trbCapacityField;
    UITextField * trbTempField;
    UITextField * trbPressureField;
    UITextField * trbCurrentRPMField;
    UITextField * trbOilLevelField;
    UITextField * trbCompressorHealthField;
    UITextField * trbRotationSpeedField;
    UITextField * trbRotorCountField;

}
@end

@implementation TurbineAddEditViewController

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
    
    self.title = @"Turbine Details";
    
    UIBarButtonItem *saveButton  = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed:)];
    
    UIBarButtonItem *shareButton  = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButtonPressed:)];
    
    [self.navigationItem setRightBarButtonItems:[[NSArray alloc]initWithObjects:saveButton,shareButton,nil]];

}

-(void)animateTextField:(UITextField*)textField up:(BOOL)up
{
    const int movementDistance = -250; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? movementDistance : -movementDistance);
    
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (IBAction)saveButtonPressed:(id)sender {
    
    if(self.turbineObject)
    {
        self.turbineObject.trbName = trbNameField.text;
        self.turbineObject.trbLocation = trbLocationField.text;
        self.turbineObject.trbCapacity = trbCapacityField.text;
        self.turbineObject.trbTemp = trbTempField.text;
        self.turbineObject.trbPressure = trbPressureField.text;
        self.turbineObject.trbCurrentRPM = trbCurrentRPMField.text;
        self.turbineObject.trbOilLevel = trbOilLevelField.text;
        self.turbineObject.trbRotationSpeed = trbRotationSpeedField.text;
        self.turbineObject.trbRotorCount = trbRotorCountField.text;
        self.turbineObject.trbCompressorHealth= trbCompressorHealthField.text;
        
        //update existing object
    }
    else{
        //create new object
        Turbine *turbineItem =  [NSEntityDescription
                           insertNewObjectForEntityForName:@"Turbine"
                           inManagedObjectContext:[[kCoreDataController sharedController] backgroundManagedObjectContext]];
        turbineItem.trbName = trbNameField.text;
        turbineItem.trbLocation = trbLocationField.text;
        turbineItem.trbCapacity = trbCapacityField.text;
        turbineItem.trbTemp = trbTempField.text;
        turbineItem.trbPressure = trbPressureField.text;
        turbineItem.trbCurrentRPM = trbCurrentRPMField.text;
        turbineItem.trbOilLevel = trbOilLevelField.text;
        turbineItem.trbRotationSpeed = trbRotationSpeedField.text;
        turbineItem.trbRotorCount = trbRotorCountField.text;
        turbineItem.trbCompressorHealth= trbCompressorHealthField.text;
        

        
    }
    
    [[kCoreDataController sharedController] saveContextToPersistentStore];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 10;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    // Make cell unselectable
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
	UITextField* tf = nil ;
	switch ( indexPath.row ) {
		case 0: {
			cell.textLabel.text = @"Name" ;
			tf = trbNameField = [self makeTextField:self.turbineObject.trbName placeholder:@""];
			[cell addSubview:trbNameField];
			break ;
		}
		case 1: {
			cell.textLabel.text = @"Location" ;
			tf = trbLocationField = [self makeTextField:self.turbineObject.trbLocation placeholder:@""];
			[cell addSubview:trbLocationField];
			break ;
		}
		case 2: {
			cell.textLabel.text = @"Capacity" ;
			tf = trbCapacityField = [self makeTextField:self.turbineObject.trbCapacity placeholder:@""];
			[cell addSubview:trbCapacityField];
			break ;
		}
		case 3: {
			cell.textLabel.text = @"Temp" ;
			tf = trbTempField = [self makeTextField:self.turbineObject.trbTemp placeholder:@""];
			[cell addSubview:trbTempField];
			break ;
		}
        case 4: {
			cell.textLabel.text = @"Pressure" ;
			tf = trbPressureField = [self makeTextField:self.turbineObject.trbPressure placeholder:@""];
			[cell addSubview:trbPressureField];
			break ;
		}
		case 5: {
			cell.textLabel.text = @"Current RPM" ;
			tf = trbCurrentRPMField = [self makeTextField:self.turbineObject.trbCurrentRPM placeholder:@""];
			[cell addSubview:trbCurrentRPMField];
			break ;
		}
		case 6: {
			cell.textLabel.text = @"Oil Level" ;
			tf = trbOilLevelField = [self makeTextField:self.turbineObject.trbOilLevel placeholder:@""];
			[cell addSubview:trbOilLevelField];
			break ;
		}
		case 7: {
			cell.textLabel.text = @"Rot Speed" ;
			tf = trbRotationSpeedField = [self makeTextField:self.turbineObject.trbRotationSpeed placeholder:@""];
			[cell addSubview:trbRotationSpeedField];
			break ;
		}
        case 8: {
			cell.textLabel.text = @"Rotor Count" ;
			tf = trbRotorCountField = [self makeTextField:self.turbineObject.trbRotorCount placeholder:@""];
			[cell addSubview:trbRotorCountField];
			break ;
		}
        case 9: {
			cell.textLabel.text = @"Compressor Health" ;
			tf = trbCompressorHealthField = [self makeTextField:self.turbineObject.trbCompressorHealth placeholder:@""];
			[cell addSubview:trbCompressorHealthField];
			break ;
		}
	}
    
	// Textfield dimensions
	tf.frame = CGRectMake(120, 12, 170, 30);
	
	// Workaround to dismiss keyboard when Done/Return is tapped
	[tf addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    cell.accessoryView = tf;
	
	// We want to handle textFieldDidEndEditing
	tf.delegate = self ;
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate


-(UITextField*) makeTextField: (NSString*)text
                  placeholder: (NSString*)placeholder  {
	UITextField *tf = [[UITextField alloc] init];
	tf.placeholder = placeholder ;
	tf.text = text ;
	tf.autocorrectionType = UITextAutocorrectionTypeNo ;
	tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
	tf.adjustsFontSizeToFitWidth = YES;
	tf.textColor = [UIColor colorWithRed:56.0f/255.0f green:84.0f/255.0f blue:135.0f/255.0f alpha:1.0f];
	return tf ;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    /* should move views */
    /* self.view.center = CGPointMake(self.view.center.x, self.view.center.y + 220);*/
    
    // if(textField.)
    
    [self animateTextField:textField up:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    /* should move views */
    [self animateTextField:textField up:NO];
}
// Workaround to hide keyboard when Done is tapped
- (IBAction)textFieldFinished:(id)sender {
    // [sender resignFirstResponder];
}
#pragma mark UIActionSheetController methods for Sharing between apps.

-(void)shareButtonPressed:(id)sender
{
    
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select Sharing option:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"URL Scheme",
                            @"Keychain",
                            @"PasteBoard",
                            @"ActivityViewController",
                            nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
    
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    [self callViaURIScheme];
                    break;
                case 1:
                    break;
                case 2:
                {
                    [self storeintoPasteBoard];
                    
                }
                    break;
                case 3:
                    
                    [self shareViaActivityViewControllerMethod];
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

-(void)callViaURIScheme
{
    NSMutableDictionary *boilerData = [NSMutableDictionary dictionaryWithDictionary:[self.turbineObject committedValuesForKeys:nil]];
    
    [boilerData removeObjectsForKeys:@[@"lastServerSyncDate",@"lastUpdatedDate"]];
    
    NSError *theError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:boilerData options:NSJSONWritingPrettyPrinted error:&theError];
    
    //NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString * text =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *newText = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    newText = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSString *trimmedString = [newText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    //NSString *jsonString = [NSString stringWithFormat:@"%@",jsonData];
    
    //jsonString = [jsonString substringFromIndex:1];
    
    //jsonString = [jsonString substringToIndex:[jsonString length] - 1];
    
    NSString *piggyBackString = [NSString stringWithFormat:@"sharedapp://%@",trimmedString];
    
    piggyBackString = [piggyBackString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:piggyBackString]];
}

#define PASTE_BOARD_NAME @"mypasteboard"
#define PASTE_BOARD_TYPE @"mydata"

#pragma mark UIPasteBoard methods.

-(void)storeintoPasteBoard
{
    
    NSMutableDictionary *boilerData = [NSMutableDictionary dictionaryWithDictionary:[self.turbineObject committedValuesForKeys:nil]];
    
    [boilerData removeObjectsForKeys:@[@"lastServerSyncDate",@"lastUpdatedDate"]];
    
    NSError *theError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:boilerData options:NSJSONWritingPrettyPrinted error:&theError];
    
    UIPasteboard * pasteboard=[UIPasteboard generalPasteboard];
    [pasteboard setData:jsonData forPasteboardType:@"MyPasteBoardSpaces"];
    
}
-(void)shareViaActivityViewControllerMethod
{
    /* NSString *textToShare = @"Look at this awesome website for aspiring iOS Developers!";
     NSURL *myWebsite = [NSURL URLWithString:@"http://www.codingexplorer.com/"];*/
    
    NSMutableDictionary *boilerData = [NSMutableDictionary dictionaryWithDictionary:[self.turbineObject committedValuesForKeys:nil]];
    
    [boilerData removeObjectsForKeys:@[@"lastServerSyncDate",@"lastUpdatedDate"]];
    
    NSArray *objectsToShare = @[boilerData];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[//UIActivityTypeAirDrop,
                                   //UIActivityTypePrint,
                                   //UIActivityTypeAssignToContact,
                                   //UIActivityTypeSaveToCameraRoll,
                                   //UIActivityTypeAddToReadingList,
                                   //UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
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

@end
