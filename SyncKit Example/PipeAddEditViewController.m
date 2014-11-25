//
//  PipeAddEditViewController.m
//  SyncKit
//
//  Created by Kavitha on 06/08/14.
//  Copyright (c) 2014 Cognizant. All rights reserved.
//

#import "PipeAddEditViewController.h"
#import "kCoreDataController.h"

@interface PipeAddEditViewController ()<UITextFieldDelegate,UIActionSheetDelegate>
{
    
    UITextField * pDiameterField;
    UITextField * pLocationField;
    UITextField * pLengthField;
    UITextField * pMakeField;
    UITextField * pCurrentContainmentField;
    UITextField * pPressureField;
    UITextField * pTemperatureField;
    UITextField * pMaxPressureField;
    UITextField * pMaxTemperatureField;
    UIDatePicker *datePicker;
}
@end

@implementation PipeAddEditViewController

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
       
    self.title = @"Pipe Details";
    
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
    
    if(self.pipeObject)
    {
        
        self.pipeObject.pLocation = pLocationField.text;
        self.pipeObject.pDiameter = pDiameterField.text;
        self.pipeObject.pLength = pLengthField.text;
        self.pipeObject.pMake = pMakeField.text;
        self.pipeObject.pCurrentContainment = pCurrentContainmentField.text;
        self.pipeObject.pPressure = pPressureField.text;
        self.pipeObject.pTemperature = pTemperatureField.text;
        self.pipeObject.pMaxTemperature = pMaxTemperatureField.text;
        self.pipeObject.pMaxPressure = pMaxPressureField.text;

        
        //update existing object
    }
    else{
        //create new object
        Pipe *pipeItem =  [NSEntityDescription
                           insertNewObjectForEntityForName:@"Pipe"
                           inManagedObjectContext:[[kCoreDataController sharedController] backgroundManagedObjectContext]];
        pipeItem.pLocation = pLocationField.text;
        pipeItem.pDiameter = pDiameterField.text;
        pipeItem.pLength = pLengthField.text;
        pipeItem.pMake = pMakeField.text;
        pipeItem.pCurrentContainment = pCurrentContainmentField.text;
        pipeItem.pPressure = pPressureField.text;
        pipeItem.pTemperature = pTemperatureField.text;
        pipeItem.pMaxTemperature = pMaxTemperatureField.text;
        pipeItem.pMaxPressure = pMaxPressureField.text;

        
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
    return 9;
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
			cell.textLabel.text = @"Location" ;
			tf = pLocationField = [self makeTextField:self.pipeObject.pLocation placeholder:@""];
			[cell addSubview:pLocationField];
			break ;
		}
		case 1: {
			cell.textLabel.text = @"Diameter" ;
			tf = pDiameterField = [self makeTextField:self.pipeObject.pDiameter placeholder:@""];
			[cell addSubview:pDiameterField];
			break ;
		}
		case 2: {
			cell.textLabel.text = @"Length" ;
			tf = pLengthField = [self makeTextField:self.pipeObject.pLength placeholder:@""];
			[cell addSubview:pLengthField];
			break ;
		}
		case 3: {
			cell.textLabel.text = @"Make" ;
			tf = pMakeField = [self makeTextField:self.pipeObject.pMake placeholder:@""];
			[cell addSubview:pMakeField];
			break ;
		}
        case 4: {
			cell.textLabel.text = @"Containment" ;
			tf = pCurrentContainmentField = [self makeTextField:self.pipeObject.pCurrentContainment placeholder:@""];
			[cell addSubview:pCurrentContainmentField];
			break ;
		}
		case 5: {
			cell.textLabel.text = @"Pressure" ;
			tf = pPressureField = [self makeTextField:self.pipeObject.pPressure placeholder:@""];
			[cell addSubview:pPressureField];
			break ;
		}
		case 6: {
			cell.textLabel.text = @"Temperature" ;
			tf = pTemperatureField = [self makeTextField:self.pipeObject.pTemperature placeholder:@""];
			[cell addSubview:pTemperatureField];
			break ;
		}
		case 7: {
			cell.textLabel.text = @"Max Temp" ;
			tf = pMaxTemperatureField = [self makeTextField:self.pipeObject.pMaxTemperature placeholder:@""];
			[cell addSubview:pMaxTemperatureField];
			break ;
		}
        case 8: {
			cell.textLabel.text = @"Max Pressure" ;
			tf = pMaxPressureField = [self makeTextField:self.pipeObject.pMaxPressure placeholder:@""];
			[cell addSubview:pMaxPressureField];
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
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone )
    {
    [self animateTextField:textField up:YES];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone )
    {
    /* should move views */
    [self animateTextField:textField up:NO];
    }
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
                {
                    [self storeintoPasteBoard];
                }
                    break;
                case 2:
                    
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
    NSMutableDictionary *boilerData = [NSMutableDictionary dictionaryWithDictionary:[self.pipeObject committedValuesForKeys:nil]];
    
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
    
    NSMutableDictionary *boilerData = [NSMutableDictionary dictionaryWithDictionary:[self.pipeObject committedValuesForKeys:nil]];
    
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
    
    NSMutableDictionary *boilerData = [NSMutableDictionary dictionaryWithDictionary:[self.pipeObject committedValuesForKeys:nil]];
    
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
