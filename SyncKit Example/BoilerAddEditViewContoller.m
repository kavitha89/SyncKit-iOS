//
//  BoilerAddEditViewContoller.m
//  SyncKit
//
//  Created by Kavitha on 7/1/14.
//  Copyright (c) 2014 Cognizant. All rights reserved.
//

#import "BoilerAddEditViewContoller.h"
#import "kCoreDataController.h"
//#import "KeychainAppManager.h"

@interface BoilerAddEditViewContoller ()<UITextFieldDelegate,UIActionSheetDelegate>
{
    
    UITextField * bNameField;
    UITextField * bCapacityField;
    UITextField * bLocationField;
    UITextField * bMakeField;
    UITextField * bTempField;
    UITextField * bPressureField;
    UITextField * bHealthStatusField;
    UITextField * bCurrentContainmentField;

    
    UIDatePicker *datePicker;
}
@end

@implementation BoilerAddEditViewContoller

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
    
    self.title = @"Boiler Details";
    
    UIBarButtonItem *shareButton  = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButtonPressed:)];
   
    UIBarButtonItem *saveButton  = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed:)];
    
    [self.navigationItem setRightBarButtonItems:[[NSArray alloc]initWithObjects:saveButton,shareButton,nil]];

    // Do any additional setup after loading the view.
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)animateTextField:(UITextField*)textField up:(BOOL)up
{
    const int movementDistance = -175; // tweak as needed
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (IBAction)saveButtonPressed:(id)sender {
    
    if(self.boilerObject)
    {
        self.boilerObject.bName = bNameField.text;
        self.boilerObject.bCapacity = bCapacityField.text;
        self.boilerObject.bHealthStatus = bHealthStatusField.text;
        self.boilerObject.bMake = bMakeField.text;
        self.boilerObject.bTemp = bTempField.text;
        self.boilerObject.bPressure = bPressureField.text;
        self.boilerObject.bCurrentContainment = bCurrentContainmentField.text;
        self.boilerObject.bLocation = bLocationField.text;

        
        //update existing object
    }
    else{
        //create new object
        Boiler *boilerItem =  [NSEntityDescription
                                      insertNewObjectForEntityForName:@"Boiler"
                                      inManagedObjectContext:[[kCoreDataController sharedController] backgroundManagedObjectContext]];
        boilerItem.bName = bNameField.text;
        boilerItem.bCapacity = bCapacityField.text;
        boilerItem.bHealthStatus = bHealthStatusField.text;
        boilerItem.bMake = bMakeField.text;
        boilerItem.bTemp = bTempField.text;
        boilerItem.bPressure = bPressureField.text;
        boilerItem.bCurrentContainment = bCurrentContainmentField.text;
        boilerItem.bLocation = bLocationField.text;
        
    }
    
    [[kCoreDataController sharedController] saveContextToPersistentStore];

    [self.navigationController popViewControllerAnimated:YES];

}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 8;
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
			tf = bNameField = [self makeTextField:self.boilerObject.bName placeholder:@""];
			[cell addSubview:bNameField];
			break ;
		}
		case 1: {
			cell.textLabel.text = @"Capacity" ;
			tf = bCapacityField = [self makeTextField:self.boilerObject.bCapacity placeholder:@""];
			[cell addSubview:bCapacityField];
			break ;
		}
		case 2: {
			cell.textLabel.text = @"Location" ;
			tf = bLocationField = [self makeTextField:self.boilerObject.bLocation placeholder:@""];
			[cell addSubview:bLocationField];
			break ;
		}
		case 3: {
			cell.textLabel.text = @"Make" ;
			tf = bMakeField = [self makeTextField:self.boilerObject.bMake placeholder:@""];
			[cell addSubview:bMakeField];
			break ;
		}
        case 4: {
			cell.textLabel.text = @"Temperature" ;
			tf = bTempField = [self makeTextField:self.boilerObject.bTemp placeholder:@""];
			[cell addSubview:bTempField];
			break ;
		}
		case 5: {
			cell.textLabel.text = @"Pressure" ;
			tf = bPressureField = [self makeTextField:self.boilerObject.bPressure placeholder:@""];
			[cell addSubview:bPressureField];
			break ;
		}
		case 6: {
			cell.textLabel.text = @"Health" ;
			tf = bHealthStatusField = [self makeTextField:self.boilerObject.bHealthStatus placeholder:@""];
			[cell addSubview:bHealthStatusField];
			break ;
		}
		case 7: {
			cell.textLabel.text = @"Containment" ;
			tf = bCurrentContainmentField = [self makeTextField:self.boilerObject.bCurrentContainment placeholder:@""];
			[cell addSubview:bCurrentContainmentField];
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
                    [self storeIntoKeychain];
                    break;
                case 2:
                {
                    NSDictionary *dict = @{@"1":@"one",@"2":@"two"};
                    [self storeDataToPasteBoardFromSyncKitAppl:dict];
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
    NSMutableDictionary *boilerData = [NSMutableDictionary dictionaryWithDictionary:[self.boilerObject committedValuesForKeys:nil]];
    
    [boilerData removeObjectsForKeys:@[@"lastServerSyncDate",@"lastUpdatedDate"]];
    
    NSError *theError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:boilerData options:NSJSONWritingPrettyPrinted error:&theError];
    
    //NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *jsonString = [NSString stringWithFormat:@"%@",jsonData];
    
    jsonString = [jsonString substringFromIndex:1];
    
    jsonString = [jsonString substringToIndex:[jsonString length] - 1];
    
    NSString *piggyBackString = [NSString stringWithFormat:@"sharedapp://%@",jsonData];
    
    piggyBackString = [piggyBackString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:piggyBackString]];
}

#define PASTE_BOARD_NAME @"mypasteboard"
#define PASTE_BOARD_TYPE @"mydata"

#pragma mark UIPasteBoard methods.

-(void)storeintoPasteBoard
{
    //Method 1
    NSString * text=@"Kavi";
    UIPasteboard * pasteboard=[UIPasteboard generalPasteboard];
    [pasteboard setString:text];
    
    //Method 2
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    [pasteboard setData:data forPasteboardType:(NSString *)kUTTypeText];
}
-(void)readDataFromPasteBoard
{
    UIPasteboard * pasteboard=[UIPasteboard generalPasteboard];
    //Method 1
    NSLog(@"Text =%@",[pasteboard string]);
    
    //Method 2
    NSData * data = [pasteboard dataForPasteboardType:(NSString*)kUTTypeText];
    NSString * text =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Text =%@",text);
}

-(void)storeDataToPasteBoardFromSyncKitAppl:(NSDictionary*)dictionary
{
    
    UIPasteboard * pb = [UIPasteboard pasteboardWithName:PASTE_BOARD_NAME create:YES];
    [pb setPersistent:TRUE];
    
    [pb setData:[NSKeyedArchiver archivedDataWithRootObject:dictionary] forPasteboardType:PASTE_BOARD_TYPE];
}

-(NSDictionary*) readFromPasteboard
{
    
    UIPasteboard * pb=[UIPasteboard pasteboardWithName:PASTE_BOARD_NAME create:NO];
    NSData * data=[pb valueForPasteboardType:PASTE_BOARD_TYPE];
    NSDictionary * dict;
    
    if (!data) {
        return nil;
    }
    @try {
        dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    @catch (NSException* exception)
    {
        NSLog(@"Exception: %@",exception);
        return nil;
    }
    return dict;
}

-(void)removepasteBoardContent
{
    
    [UIPasteboard removePasteboardWithName:PASTE_BOARD_NAME];
}

-(void)shareViaActivityViewControllerMethod
{
    NSString *textToShare = @"Look at this awesome website for aspiring iOS Developers!";
    NSURL *myWebsite = [NSURL URLWithString:@"http://www.codingexplorer.com/"];
    
    NSArray *objectsToShare = @[textToShare, myWebsite];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
}
-(void)storeIntoKeychain
{
    NSDictionary *dict = @{@"1":@"one",@"2":@"two"};
    //KeychainAppManager *sso = [[KeychainAppManager alloc]init];
    //[sso setInstallionQueuedFlag:dict];
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
