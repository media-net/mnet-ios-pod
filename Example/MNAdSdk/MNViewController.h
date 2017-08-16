//
//  MNViewController.h
//  MNAdSdk
//
//  Created by Nithin on 02/15/2017.
//  Copyright (c) 2017 Nithin. All rights reserved.
//


@import UIKit;
#import <CoreLocation/CoreLocation.h>

@interface MNViewController : UIViewController <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *adsTableView;
@property (weak, nonatomic) IBOutlet UIView *topBar;

@end

@interface MNAdViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIView *separator;

- (void)hideSeparator;
- (void)showSeparator;
@end
