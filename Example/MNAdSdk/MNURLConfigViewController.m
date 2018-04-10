//
//  MNURLConfigViewController.m
//  MNAdSdk_Example
//
//  Created by kunal.ch on 06/02/18.
//  Copyright © 2018 Nithin. All rights reserved.
//

#import "MNURLConfigViewController.h"
#import "MNAdSdkURLManager.h"
#import "UIView+Toast.h"

static NSString *kStaging = @"STAGING";
static NSString *kProd    = @"PRODUCTION";

@interface MNURLConfigViewController ()
@property (weak, nonatomic) IBOutlet UILabel *baseURLLabel;
@property (weak, nonatomic) IBOutlet UILabel *configURLLabel;
@property (weak, nonatomic) IBOutlet UILabel *pulseURLLabel;
@property (weak, nonatomic) IBOutlet UILabel *resoourceURLLabel;
@property (weak, nonatomic) IBOutlet UISwitch *prodStageSwitch;
@property (nonatomic) BOOL isDebug;
@property (weak, nonatomic) IBOutlet UILabel *envLabel;
- (IBAction)backAction:(id)sender;

@end

@implementation MNURLConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpVC];
    [self setLabelTexts];
}

- (void)setUpVC {
    self.isDebug = [[MNAdSdkURLManager getSharedInstance] isDebug];
    [self.envLabel setText:self.isDebug ? kStaging : kProd];
    [self.prodStageSwitch addTarget:self
                             action:@selector(switchStateChanged:)
                   forControlEvents:UIControlEventValueChanged];
    [self.prodStageSwitch setOn:self.isDebug];
}

- (void)setLabelTexts {
    self.baseURLLabel.text      = [[MNAdSdkURLManager getSharedInstance] getSdkBaseURL];
    self.configURLLabel.text    = [[MNAdSdkURLManager getSharedInstance] getSdkConfigBaseURL];
    self.pulseURLLabel.text     = [[MNAdSdkURLManager getSharedInstance] getSdkPulseBaseURL];
    self.resoourceURLLabel.text = [[MNAdSdkURLManager getSharedInstance] getSdkResourceBaseURL];
}

// Default value is STAGING
- (void)switchStateChanged:(UISwitch *)switchState {
    if ([switchState isOn]) {
        [self.envLabel setText:kStaging];
        self.isDebug = YES;
    } else {
        [self.envLabel setText:kProd];
        self.isDebug = NO;
    }

    [[MNAdSdkURLManager getSharedInstance] setIsProdUserDefaults:!self.isDebug];
    [self setLabelTexts];
    [self.view makeToast:@"Please kill and restart app for the changes to take effect"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
