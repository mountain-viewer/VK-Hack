//
//  SuggestionsViewController.h
//  VKHack
//
//  Created by Vladislav Shakhray on 28.09.2019.
//  Copyright © 2019 Vladislav Shakhray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iCarousel/iCarousel.h>
#import <AFNetworking/AFNetworking.h>

#import <FLAnimatedImage/FLAnimatedImage.h>
#import <Animated_Gif_iOS/UIImageView+AnimatedGif.h>
#import <Animated_Gif_iOS/AnimatedGif.h>
#import <Photos/Photos.h>
#import <SVProgressHUD/SVProgressHUD.h>
NS_ASSUME_NONNULL_BEGIN

@interface SuggestionsViewController : UIViewController <UIScrollViewDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) NSArray<NSString *> *imageViews;
@property (nonatomic, strong) NSMutableArray< UIImage *> *posterImages;
@property int selected;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *background;
@property (weak, nonatomic) IBOutlet UIImageView *ig;
@property (weak, nonatomic) IBOutlet UIImageView *vk;
@property (weak, nonatomic) IBOutlet UIImageView *fb;

@end

NS_ASSUME_NONNULL_END
