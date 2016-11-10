//
//  SparkSetupSuccessFailureViewController.m
//  teacup-ios-app
//
//  Created by Ido on 2/3/15.
//  Copyright (c) 2015 spark. All rights reserved.
//

#import "SparkSetupResultViewController.h"
#import "SparkSetupUIElements.h"
#import "SparkSetupMainController.h"
#import "SparkSetupWebViewController.h"
#import "SparkSetupCustomization.h"
#ifdef FRAMEWORK
#import <ParticleSDK/ParticleSDK.h>
#else
#import "Spark-SDK.h"
#endif
#ifdef ANALYTICS
#import <Mixpanel.h>
#endif

@interface SparkSetupResultViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet SparkSetupUILabel *shortMessageLabel;
@property (weak, nonatomic) IBOutlet SparkSetupUILabel *longMessageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *setupResultImageView;
@property (weak, nonatomic) IBOutlet UIImageView *brandImageView;

@property (weak, nonatomic) IBOutlet SparkSetupUILabel *nameDeviceLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameDeviceTextField;
@property (strong, nonatomic) NSArray *randomDeviceNamesArray;

@property (weak, nonatomic) IBOutlet SparkSetupUIButton *doneButton;

@end

@implementation SparkSetupResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // set logo
    self.brandImageView.image = [SparkSetupCustomization sharedInstance].brandImage;
    self.brandImageView.backgroundColor = [SparkSetupCustomization sharedInstance].brandImageBackgroundColor;
    
    self.nameDeviceLabel.hidden = YES;
    self.nameDeviceTextField.hidden = YES;

    // Trick to add an inset from the left of the text fields
    CGRect  viewRect = CGRectMake(0, 0, 10, 32);
    UIView* emptyView = [[UIView alloc] initWithFrame:viewRect];
    
    self.nameDeviceTextField.leftView = emptyView;
    self.nameDeviceTextField.leftViewMode = UITextFieldViewModeAlways;
    self.nameDeviceTextField.delegate = self;
    self.nameDeviceTextField.returnKeyType = UIReturnKeyDone;
    self.nameDeviceTextField.font = [UIFont fontWithName:[SparkSetupCustomization sharedInstance].normalTextFontName size:16.0];

    // init funny random device names
    self.randomDeviceNamesArray = [NSArray arrayWithObjects:@"aardvark", @"bacon", @"badger", @"banjo", @"bobcat", @"boomer", @"captain", @"chicken", @"cowboy", @"maker", @"splendid", @"sparkling", @"dentist", @"doctor", @"green", @"easter", @"ferret", @"gerbil", @"hacker", @"hamster", @"wizard", @"hobbit", @"hoosier", @"hunter", @"jester", @"jetpack", @"kitty", @"laser", @"lawyer", @"mighty", @"monkey", @"morphing", @"mutant", @"narwhal", @"ninja", @"normal", @"penguin", @"pirate", @"pizza", @"plumber", @"power", @"puppy", @"ranger", @"raptor", @"robot", @"scraper", @"burrito", @"station", @"tasty", @"trochee", @"turkey", @"turtle", @"vampire", @"wombat", @"zombie", nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidAppear:(BOOL)animated
{
    if ((!isiPhone4) && (!isiPhone5))
        [self disableKeyboardMovesViewUp];
    
    if (self.setupResult == SparkSetupResultSuccess)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.nameDeviceTextField becomeFirstResponder];
        });
    }
}

-(void)viewWillAppear:(BOOL)animated
{
#ifdef ANALYTICS
    [[Mixpanel sharedInstance] track:@"Device Setup: Setup Result Screen"];
#endif

    
    [super viewWillAppear:animated];
    
    switch (self.setupResult) {
        case SparkSetupResultSuccess:
        {
            self.setupResultImageView.image = [SparkSetupMainController loadImageFromResourceBundle:@"success"];
            self.shortMessageLabel.text = @"Setup completed successfully";
            self.longMessageLabel.text = @"Congrats! You've successfully set up your {device}.";
            
            self.nameDeviceLabel.hidden = NO;
            self.nameDeviceTextField.hidden = NO;
            NSString *randomDeviceName1 = self.randomDeviceNamesArray[arc4random_uniform((UInt32)self.randomDeviceNamesArray.count)];
            NSString *randomDeviceName2 = self.randomDeviceNamesArray[arc4random_uniform((UInt32)self.randomDeviceNamesArray.count)];
            self.nameDeviceTextField.text = [NSString stringWithFormat:@"%@_%@",randomDeviceName1,randomDeviceName2];
#ifdef ANALYTICS
            [[Mixpanel sharedInstance] track:@"Device Setup: Success"];
#endif

            break;
        }
            
        case SparkSetupResultSuccessDeviceOffline:
        {
            self.setupResultImageView.image = [SparkSetupMainController loadImageFromResourceBundle:@"warning"];
            self.shortMessageLabel.text = @"Grove didn't connect.";
            self.shortMessageLabel.textColor = [SparkSetupCustomization sharedInstance].brandImageBackgroundColor;
            self.longMessageLabel.text = @"Make sure your wifi password is accurate and try again. \n\nIf this happens again, hold the control knob down for 7 seconds. You'll see a blinking orange light. When you do, retry wifi setup.";
            [self.doneButton setTitle:@"Retry Setup" forState:UIControlStateNormal];
            
#ifdef ANALYTICS
            [[Mixpanel sharedInstance] track:@"Device Setup: Success" properties:@{@"reason":@"device offline"}];
#endif
            break;
        }

        case SparkSetupResultSuccessUnknown:
        {
            self.setupResultImageView.image = [SparkSetupMainController loadImageFromResourceBundle:@"success"];
            self.shortMessageLabel.text = @"Setup completed";
            self.longMessageLabel.text = @"Setup was successful, but since you do not own this device we cannot know if the {device} has connected to the Internet. If you see the LED breathing cyan this means it worked! If not, please restart the setup process.";
            
#ifdef ANALYTICS
            [[Mixpanel sharedInstance] track:@"Device Setup: Success" properties:@{@"reason":@"not claimed"}];
#endif
            break;
            
        }
            
        case SparkSetupResultFailureClaiming:
        {
            self.setupResultImageView.image = [SparkSetupMainController loadImageFromResourceBundle:@"failure"];
            self.shortMessageLabel.text = @"Setup failed";
            // TODO: add customization point for custom troubleshoot texts
//            self.longMessageLabel.text = @"Setup process failed at claiming your {device}, if your {device} LED is blinking in blue or green this means that you provided wrong Wi-Fi credentials. If {device} LED is breathing cyan an internal cloud issue occured - please contact product support.";
            self.longMessageLabel.text = @"Setup process failed at claiming your {device}, if your {device} LED is blinking in blue or green this means that you provided wrong Wi-Fi credentials, please try setup process again.";
#ifdef ANALYTICS
            [[Mixpanel sharedInstance] track:@"Device Setup: Failure" properties:@{@"reason":@"claiming failed"}];
#endif

            break;
        }
            
        case SparkSetupResultFailureCannotDisconnectFromDevice:
        {
            self.setupResultImageView.image = [SparkSetupMainController loadImageFromResourceBundle:@"warning"];
            self.shortMessageLabel.text = @"Grove didn't connect.";
            self.longMessageLabel.text = @"Looks like there was a problem setting your grove up to wifi. \n\nPlease make sure your phone is connected to the internet and hold the control knob down for 7 seconds and release when your grove is blinking orange. (Error code: Jalapeño)";
            [self.doneButton setTitle:@"Retry Setup" forState:UIControlStateNormal];

#ifdef ANALYTICS
            [[Mixpanel sharedInstance] track:@"Device Setup: Failure" properties:@{@"reason":@"cannot disconnect"}];
#endif

            break;
        }
            
        case SparkSetupResultFailureConfigure:
        {
            self.setupResultImageView.image = [SparkSetupMainController loadImageFromResourceBundle:@"warning"];
            self.shortMessageLabel.text = @"Grove could not connect.";
            self.longMessageLabel.text = @"This can be caused by a few things. \n\n1. Incorrect password. Confirm you have the correct wifi info. \n\n2. Poor network signal. Stand closer to your router. \n\n3. Signal dropped at the wrong moment. Try again. \n\nIf this issue persists, go to bit.ly/grovewifi for a full troubleshooting guide. (Error code: Serrano Pepper)";
            [self.doneButton setTitle:@"Retry Setup" forState:UIControlStateNormal];
#ifdef ANALYTICS
            [[Mixpanel sharedInstance] track:@"Device Setup: Failure" properties:@{@"reason":@"cannot configure"}];
#endif

            break;
        }
            
        case SparkSetupResultFailureLostConnectionToDevice:
        {
            self.setupResultImageView.image = [SparkSetupMainController loadImageFromResourceBundle:@"failure"];
            self.shortMessageLabel.text = @"Error!";
            self.longMessageLabel.text = @"Setup process couldn't configure the Wi-Fi credentials for your {device}, please try running setup again after resetting your {device} and putting it back in blinking blue listen mode if needed.";
#ifdef ANALYTICS
            [[Mixpanel sharedInstance] track:@"Device Setup: Failure" properties:@{@"reason":@"lost connection"}];
#endif
            break;
        }
            
    }
    
    [self.longMessageLabel setType:@"normal"];

    /*
    if ([SparkSetupCustomization sharedInstance].tintSetupImages)
    {
        self.setupResultImageView.image = [self.setupResultImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.setupResultImageView.tintColor = [SparkSetupCustomization sharedInstance].normalTextColor;// elementBackgroundColor;;
    }
     */

}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.nameDeviceTextField)
    {
        [textField resignFirstResponder];
        [self.device rename:textField.text completion:^(NSError *error) {
            [self doneButtonTapped:self];
        }];
    }
    
    return YES;
}




- (IBAction)doneButtonTapped:(id)sender
{
  [SparkSetupResultViewController exitSetup:self.setupResult :self.device];
}

+ (void)exitSetup:(SparkSetupResult)setupResult :(SparkDevice *)device
{
  NSMutableDictionary *userInfo = [NSMutableDictionary new];
  if (setupResult == SparkSetupResultSuccess)
  {
    // Update zero notice to user
    // TODO: condition message only if its really getting update zero
    // UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Firmware update" message:@"If this is the first time you are setting up this device it might blink its LED in magenta color for a while, this means the device is currently updating its firmware from the cloud to the latest version. Please be patient and do not press the reset button. Device LED will breathe cyan once update has completed and it has come online." delegate:nil cancelButtonTitle:@"Understood" otherButtonTitles:nil];
    // [alert show];
    
    userInfo[kSparkSetupDidFinishStateKey] = @(SparkSetupMainControllerResultSuccess);
    
    if (device)
      userInfo[kSparkSetupDidFinishDeviceKey] = device;
  }
  else if (setupResult == SparkSetupResultSuccessUnknown)
  {
    userInfo[kSparkSetupDidFinishStateKey] = @(SparkSetupMainControllerResultSuccessNotClaimed);
  }
  else
  {
    userInfo[kSparkSetupDidFinishStateKey] = @(SparkSetupMainControllerResultFailure);
  }
  
  // finish with success and provide device
  [[NSNotificationCenter defaultCenter] postNotificationName:kSparkSetupDidFinishNotification
                                                      object:nil
                                                    userInfo:userInfo];
}


- (IBAction)troubleshootingButtonTouched:(id)sender
{
  
    SparkSetupWebViewController* webVC = [[UIStoryboard storyboardWithName:@"setup" bundle:[NSBundle bundleWithIdentifier:SPARK_SETUP_RESOURCE_BUNDLE_IDENTIFIER]] instantiateViewControllerWithIdentifier:@"webview"];
    webVC.link = [SparkSetupCustomization sharedInstance].troubleshootingLinkURL;
    [self presentViewController:webVC animated:YES completion:nil];
    
}



@end
