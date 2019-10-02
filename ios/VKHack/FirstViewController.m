//
//  FirstViewController.m
//  VKHack
//
//  Created by Vladislav Shakhray on 27.09.2019.
//  Copyright © 2019 Vladislav Shakhray. All rights reserved.
//

#import "FirstViewController.h"

#import <Photos/Photos.h>
#import <FSPagerView/FSPagerViewObjcCompat.h>
#import <Pods_VKHack/Pods-VKHack-umbrella.h>

@interface FirstViewController ()

@end
const CGFloat shadowRadius = 12.0f;

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _loadAssetsInfo.hidden = YES;
    UIImage *img = [UIImage imageNamed:@"sportsru"];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [imgView setImage:img];
    // setContent mode aspect fit
    [imgView setContentMode:UIViewContentModeScaleAspectFit];
    self.navigationItem.titleView = imgView;
    
    self.extra1.alpha = 0.;
    self.extra2.alpha = 0.;
    self.header.alpha = 0.;
    self.score1.alpha = 0.;
    self.score2.alpha = 0.;
    // Do any additional setup after loading the view.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_shown) {
        return;
    }
    _shown = YES;
    [self setupShadowsAndRoundedCorners:self.team1];
    [self setupShadowsAndRoundedCorners:self.team2];
    
    
    UITapGestureRecognizer *singleFingerTap =
      [[UITapGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(select1)];
    [self.team1 addGestureRecognizer:singleFingerTap];
    
    UITapGestureRecognizer *singleFingerTap2 =
      [[UITapGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(select2)];
    [self.team2 addGestureRecognizer:singleFingerTap2];
    
    self.teams.alpha = 0;
    self.team1.alpha = 0.;
    self.team2.alpha = 0.;
    self.extra1.alpha = 0.;
    self.extra2.alpha = 0.;
    self.header.alpha = 0.;
    self.score1.alpha = 0.;
    self.score2.alpha = 0.;
    _continueButton.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1];
    _continueButton.layer.cornerRadius = 8;
    _continueButton.layer.borderWidth = 2;
    _continueButton.layer.borderColor = [UIColor colorWithWhite:0.93 alpha:1].CGColor;
    [_continueButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    _continueButton.enabled = NO;
    
    [self startLoadingAssets:nil];
}

- (void)updateTeam:(UIView *)view selected:(BOOL)selected {
    view.backgroundColor =
    selected ? [UIColor colorWithWhite:1 alpha:1] : [UIColor whiteColor];
    
    if (selected) {
        [view.layer setBorderColor:[UIColor grayColor].CGColor];
        [view.layer setBorderWidth:1.5f];
        [view.layer setShadowOpacity:0.2];
        [view.layer setShadowRadius:1.5 * shadowRadius];
    } else {
        [view.layer setBorderColor:[UIColor clearColor].CGColor];
        [view.layer setBorderWidth:0];
        [view.layer setShadowOpacity:0.07];
        [view.layer setShadowRadius:shadowRadius * 0.8];
    }
}

- (void)select1 {
    [self updateTeam:self.team1 selected:YES];
    [self updateTeam:self.team2 selected:NO];
    _selected = 1;
    [self activateContinueButton];
}

- (void)select2 {
    [self updateTeam:self.team1 selected:NO];
    [self updateTeam:self.team2 selected:YES];
    _selected = 2;
    [self activateContinueButton];
}

- (IBAction)continueButtonPressed:(id)sender {
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD show];
//
    PHFetchOptions *const foptions = nil;
    foptions.sortDescriptors = @[
        [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO],
    ];

    PHFetchResult<PHAsset *> *images = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:foptions];

//    for (PHAsset *ass in images) {
//        NSLog(@"%@", ass.creationDate);
//    }
    PHAsset *asset = images[images.count - 1];
    PHImageManager *manager = [PHImageManager defaultManager];
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    [options setVersion:PHImageRequestOptionsVersionOriginal];
    options.networkAccessAllowed = YES;
    __block UIImage *image = nil;
    [manager requestImageForAsset:asset targetSize:CGSizeMake(300, 600) contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        [self sendImageWithMethod:@"geo/process_photo" image:result parameters:[[NSDictionary alloc] initWithObjects:@[[NSString stringWithFormat:@"%d", self->_selected]] forKeys:@[@"choice"]]];
    }];
}

//
//    for (int i = 0; i < images.count; i++) {
//        PHAsset *const asset = images[i];
//        PHImageManager *manager = [PHImageManager defaultManager];
//        PHImageRequestOptions *options = [PHImageRequestOptions new];
////        [options setSynchronous:YES];
//        [options setVersion:PHImageRequestOptionsVersionOriginal];
//
//        __block UIImage *image = nil;
//        [manager requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//            if (imageData) {
//                image = [UIImage imageWithData:imageData];
//            }
//        }];
//
//        if (image) {
//            return image;
//        }
//    }
//    return nil;

- (void)activateContinueButton {
    _continueButton.backgroundColor = [UIColor colorWithWhite:0. alpha:0.99];
    _continueButton.layer.cornerRadius = 8;
    _continueButton.layer.borderWidth = 2;
//    _continueButton.layer.borderColor = [UIColor colorWithRed:55./255 green:147/255. blue:232/255. alpha:1].CGColor;
    [_continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _continueButton.enabled = YES;
}

- (void)moveCorrectly {
//    CGFloat width = self.view.frame.size.width;
//    CGFloat kOffset = (width - 2 * self.team1.frame.size.width) / 3.;
//
//    CGRect frame = self.team1.frame;
//    frame.origin.x = kOffset;
////    frame.origin.y = 100;
//    self.team1.frame = frame;
//
//    frame = self.team2.frame;
//    frame.origin.x = 2 * kOffset + self.team1.frame.size.width;
////    frame.origin.y = 100;
//    self.team2.frame = frame;
}
- (void)setupShadowsAndRoundedCorners:(UIView *)v {
    CGFloat cornerRadius = 30.0f;
    
    // border radius
    [v.layer setCornerRadius:cornerRadius];

    // border
//    [v.layer setBorderColor:[UIColor lightGrayColor].CGColor];
//    [v.layer setBorderWidth:1.5f];

    // drop shadow
    [v.layer setShadowColor:[UIColor colorWithWhite:0.2 alpha:1].CGColor];
    [v.layer setShadowOpacity:0.1];
    [v.layer setShadowRadius:shadowRadius];
    [v.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
//    v.alpha = 0.;
}

- (void)moveView:(UIView *)view fromOrigin:(CGPoint)origin toPlace:(CGPoint)destination alphaBegin:(CGFloat)alphaBegin alphaEnd:(CGFloat)alphaEnd time:(CGFloat)seconds completion:(void(^)(BOOL finished))completion
{
    view.alpha = alphaBegin;
    CGRect frame = view.frame;
    frame.origin = origin;
    view.frame = frame;
    
    [UIView animateWithDuration:seconds animations:^{
        CGRect frame = view.frame;
        frame.origin = destination;
        view.frame = frame;
        view.alpha = alphaEnd;
    } completion:completion];
}

- (void)animateAlpha:(UIView *)view alphaBegin:(CGFloat)alphaBegin alphaEnd:(CGFloat)alphaEnd time:(CGFloat)seconds completion:(void(^)(BOOL finished))completion {
    [self moveView:view fromOrigin:view.frame.origin toPlace:view.frame.origin alphaBegin:alphaBegin alphaEnd:alphaEnd time:seconds completion:completion];
}

- (IBAction)startLoadingAssets:(id)sender {
//    [self moveCorrectly];
    
//    id res =
//    [self performGETRequestWithMethod:@"quiz/get_stories" parameters:@{@"team_name" : @"arsenal", @"true_answers" : @"2"}];
//    
//    NSLog(@"%@", res);
//
//    return;
    
    PHFetchOptions *const options = nil;
    options.sortDescriptors = @[
        [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO],
    ];

    PHFetchResult<PHAsset *> *images = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];

    CLLocation *finalLoc = nil;
    for (int i = 0; i < images.count; i++) {
        PHAsset *const asset = images[i];
        CLLocation *location = asset.location;
        
        const auto eps = 1e-5;
        if (fabs(location.coordinate.longitude) > eps || fabs(location.coordinate.latitude) > eps) {
            finalLoc = location;
            break;
        }
    }
    
    if (!finalLoc) {
        [self userNotOnMatch];
        return;
    }
    
    id response = [self
      performGETRequestWithMethod:@"geo/initial_fetch"
      parameters:
      [[NSDictionary alloc] initWithObjects:@[@(finalLoc.coordinate.longitude), @(finalLoc.coordinate.latitude)] forKeys:@[@"lon", @"lat"]]];
    
    NSString *const team1 = response[@"home_team_name"];
    NSString *const team2 = response[@"away_team_name"];
    
    NSString *const logo1 = response[@"home_team_logo"];
    NSString *const logo2 = response[@"away_team_logo"];
    self.team1_name.text = team1;
    NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:logo1]];
    self.team1_logo.image = [UIImage imageWithData: imageData];
    
    self.team2_name.text = team2;
    NSData *imageData2 = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:logo2]];
    self.team2_logo.image = [UIImage imageWithData: imageData2];
    
    self.score1.text = [NSString stringWithFormat:@"%d", [response[@"home_score"] intValue]];
    self.score2.text = [NSString stringWithFormat:@"%d", [response[@"away_score"] intValue]];

    self.extra2_label.text = response[@"venue_name"];
    self.extra1_label.text = [NSString stringWithFormat:@"%d минута", [response[@"match_current_time"] intValue]];
    CGFloat width = self.view.frame.size.width;
    CGFloat kOffset = (width - 2 * self.team1.frame.size.width) / 3.;
    
    [self moveView:self.teams fromOrigin:CGPointMake(self.teams.frame.origin.x, 500) toPlace:CGPointMake(self.teams.frame.origin.x, 400) alphaBegin:0. alphaEnd:1. time:1.5 completion:^(BOOL finished) {
        [self animateAlpha:self.header alphaBegin:0. alphaEnd:1. time:0.8 completion:nil];
        [self animateAlpha:self.extra1 alphaBegin:0. alphaEnd:1. time:0.8 completion:nil];
        [self animateAlpha:self.extra2 alphaBegin:0. alphaEnd:1. time:0.8 completion:nil];
        [self animateAlpha:self.score1 alphaBegin:0. alphaEnd:1. time:0.8 completion:nil];
        [self animateAlpha:self.score2 alphaBegin:0. alphaEnd:1. time:0.8 completion:nil];

    }];
    self.team1.alpha = 1.;
    self.team2.alpha = 1.;
    self.team1_name.textColor = [UIColor blackColor];
    self.team2_name.textColor = [UIColor blackColor];
    _continueButton.hidden = NO;
    
}

- (void)userNotOnMatch {
    
}

- (id)performGETRequestWithMethod:(NSString *)method parameters:(NSDictionary<NSString *, NSString *> *)parameters {
    static NSString *const kBaseURL = @"http://95.213.37.132:5000";
    
    NSString *url = [NSString stringWithFormat:@"%@/%@?", kBaseURL, method];
    for (NSString *key in parameters) {
        url = [url stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", key, parameters[key]]];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    
    NSError *error = nil;
    NSHTTPURLResponse *responseCode = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %i", url, [responseCode statusCode]);
        return nil;
    }
    
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];

    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

- (id)sendImageWithMethod:(NSString *)method image:(UIImage *)image parameters:(NSDictionary<NSString *, NSString *> *)parameters {
    static NSString *const kBaseURL = @"http://95.213.37.132:5000";
    
    NSString *url = [NSString stringWithFormat:@"%@/%@?", kBaseURL, method];
    for (NSString *key in parameters) {
        url = [url stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", key, parameters[key]]];
    }
    
    NSData * binaryImageData = UIImagePNGRepresentation(image);
        
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    [binaryImageData writeToFile:[basePath stringByAppendingPathComponent:@"myfile.png"] atomically:YES];
    
    NSString *path = [basePath stringByAppendingPathComponent:@"myfile.png"];
    //    NSString *jsonpath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"json%d_%d", MIN(self.selectedCountry, 4), self.selectedType] ofType:@"json"];
        
//    NSString *jsonpath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"json1_1", MIN(_selectedCountry, 4), _selectedType] ofType:@"json"];
        
        
    __block id response;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        //    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // only needed if the server is not returning JSON; if web service returns JSON, remove this line
    NSURLSessionTask *task = [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            NSError *error;

            if (![formData appendPartWithFileURL:[NSURL fileURLWithPath:path] name:@"image" fileName:@"myfile.png" mimeType:@"image/png" error:&error]) {
                NSLog(@"error appending part: %@", error);
            }
            
//            [formData appendPartWithFormData:[@"101" dataUsingEncoding:NSUTF8StringEncoding] name:@"choice"];
    //        if (![formData appendPartWithFileURL:[NSURL fileURLWithPath:jsonpath] name:@"data" fileName:[NSString stringWithFormat:@"json%d_%d.json", MIN(self.selectedCountry, 4), self.selectedType] mimeType:@"application/json" error:&error]) {
    //            NSLog(@"error appending part: %@", error);
    //        }
        
//                    if (![formData appendPartWithFileURL:[NSURL fileURLWithPath:jsonpath] name:@"data" fileName:[NSString stringWithFormat:@"json1_1.json", MIN(self.selectedCountry, 4), self.selectedType] mimeType:@"application/json" error:&error]) {
//                        NSLog(@"error appending part: %@", error);
//                    }
        }  progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            NSArray* array = (NSArray*) responseObject;
            
            self.imageViews = [array copy];
            
            [SVProgressHUD dismissWithDelay:.0 completion:^{
//                self.imageViews = flImageViews;
                [self performSegueWithIdentifier:@"suggestions" sender:self];
            }];
//            int t = 4;
            
//            self.loadedImages = imgs;
//
//            if (self.selectedType == 1) {
//                [SVProgressHUD dismiss];
//                [self performSegueWithIdentifier:@"GIFs" sender:self];
//            } else {
//                [SVProgressHUD dismiss];
//                [self performSegueWithIdentifier:@"Stickers" sender:self];
//            }
        } failure:^(NSURLSessionTask *task, NSError *error) {
            NSLog(@"error = %@", error);
        }];
    
    return response;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    SuggestionsViewController *dest = segue.destinationViewController;
    dest.imageViews = self.imageViews;
    dest.selected = _selected;
}
@end
