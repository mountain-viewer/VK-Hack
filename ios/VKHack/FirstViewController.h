//
//  FirstViewController.h
//  VKHack
//
//  Created by Vladislav Shakhray on 27.09.2019.
//  Copyright © 2019 Vladislav Shakhray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>
#import <FLAnimatedImage/FLAnimatedImage.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "SuggestionsViewController.h"

@interface FirstViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *loadAssetsInfo;
@property (nonatomic, strong) NSArray<NSString *> *imageViews;
@property BOOL shown;
@property (weak, nonatomic) IBOutlet UIView *team1;
@property (weak, nonatomic) IBOutlet UILabel *team1_name;
@property (weak, nonatomic) IBOutlet UIImageView *team1_logo;
@property (weak, nonatomic) IBOutlet UIView *team2;
@property (weak, nonatomic) IBOutlet UILabel *team2_name;
@property (weak, nonatomic) IBOutlet UIImageView *team2_logo;
@property (weak, nonatomic) IBOutlet UIView *teams;

@property int selected;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UIView *extra1;
@property (weak, nonatomic) IBOutlet UIView *extra2;
@property (weak, nonatomic) IBOutlet UILabel *extra1_label;
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UILabel *extra2_label;
@property (weak, nonatomic) IBOutlet UILabel *score1;
@property (weak, nonatomic) IBOutlet UILabel *score2;

@end

