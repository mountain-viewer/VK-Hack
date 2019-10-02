//
//  VKViewController.h
//  VKHack
//
//  Created by Vladislav Shakhray on 29.09.2019.
//  Copyright © 2019 Vladislav Shakhray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VKSdk.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <AFNetworking/AFNetworking.h>
#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN

@interface VKViewController : UIViewController <VKSdkDelegate>
@property (weak, nonatomic) IBOutlet UIButton *authButton;
@property (weak, nonatomic) IBOutlet UILabel *text;
@property (weak, nonatomic) IBOutlet UIImageView *logo;

@end

NS_ASSUME_NONNULL_END
