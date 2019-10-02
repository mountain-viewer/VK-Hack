//
//  SuggestionsViewController.m
//  VKHack
//
//  Created by Vladislav Shakhray on 28.09.2019.
//  Copyright © 2019 Vladislav Shakhray. All rights reserved.
//

#import "SuggestionsViewController.h"

@interface SuggestionsViewController ()

@end

@implementation SuggestionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *img = [UIImage imageNamed:@"sportsru"];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(-30, 0, 30, 30)];
    [imgView setImage:img];
    // setContent mode aspect fit
    [imgView setContentMode:UIViewContentModeScaleAspectFit];
    self.navigationItem.titleView = imgView;
    self.background.layer.cornerRadius = 10;
    _scrollView.delegate = self;
    _posterImages = [NSMutableArray new];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(pick)];
//    _scrollView
    // Do any additional setup after loading the view.
}

- (void)pick {
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc]init];
    // Check if image access is authorized
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        // Use delegate methods to get result of photo library -- Look up UIImagePicker delegate methods
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:true completion:nil];
    }
}
- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    [SVProgressHUD show];
    
    for (UIView *v in _scrollView.subviews) {
        [v removeFromSuperview];
    }
    
    if (originalImage.imageOrientation != UIImageOrientationUp) {
      UIGraphicsBeginImageContextWithOptions(originalImage.size, NO, originalImage.scale);
      [originalImage drawInRect:(CGRect){{0, 0}, originalImage.size}];
      originalImage = UIGraphicsGetImageFromCurrentImageContext();
      UIGraphicsEndImageContext();
    }
    
    [self sendImageWithMethod:@"geo/process_photo" image:originalImage parameters:[[NSDictionary alloc] initWithObjects:@[[NSString stringWithFormat:@"%d", _selected]] forKeys:@[@"choice"]]];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)sendImageWithMethod:(NSString *)method image:(UIImage *)image parameters:(NSDictionary<NSString *, NSString *> *)parameters {
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
        
        }  progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            NSArray* array = (NSArray*) responseObject;
            
            self.imageViews = [array copy];
            
            [SVProgressHUD dismiss];
            [self updateScrollView];
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
    
//    return response;
}

- (void) ig_ {
    NSURL *urlScheme = [NSURL URLWithString:@"instagram-stories://share"];
    if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {
    
          // Assign background image asset and attribution link URL to pasteboard
        NSArray *pasteboardItems = @[@
        {@"com.instagram.sharedSticker.backgroundImage" : self.posterImages[(int)(((_scrollView.contentOffset.x) + 100) / self.view.frame.size.width)],
                                         @"com.instagram.sharedSticker.contentURL" : self.imageViews[0]}];
          NSDictionary *pasteboardOptions = @{UIPasteboardOptionExpirationDate : [[NSDate date] dateByAddingTimeInterval:60 * 5]};
          // This call is iOS 10+, can use 'setItems' depending on what versions you support
          [[UIPasteboard generalPasteboard] setItems:pasteboardItems options:pasteboardOptions];
      
          [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
    } else {
        // Handle older app versions or app not installed case
    }
}

- (void)vk_ {
    NSURL *urlScheme = [NSURL URLWithString:@"vk:"];
    if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {
          [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
    } else {
        // Handle older app versions or app not installed case
    }
}

- (void)im_ {
    NSURL *urlScheme = [NSURL URLWithString:@"sms:"];
    if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {
          [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
    } else {
        // Handle older app versions or app not installed case
    }
}

- (NSString *)prettify:(NSString *)string {
    if (![string containsString:@"http"]) {
        return [NSString stringWithFormat:@"http://%@", string];
    }
    return string;
}

- (void)viewDidAppear:(BOOL)animated {
//    CGRect frame = CGRectMake(0, 0, 50, 200);
//    FLAnimatedImageView *img = self.imageViews[0];
//    img.frame = frame;
//
//    [self.view addSubview:img]
    [super viewDidAppear:animated];

    UIButton *b1 = [[UIButton alloc] initWithFrame:_ig.frame];
    [b1 addTarget:self action:@selector(ig_) forControlEvents:UIControlEventTouchUpInside];
    [_background addSubview:b1];
    
    UIButton *b2 = [[UIButton alloc] initWithFrame:_vk.frame];
    [b2 addTarget:self action:@selector(vk_) forControlEvents:UIControlEventTouchUpInside];
    [_background addSubview:b2];
    
    UIButton *b3 = [[UIButton alloc] initWithFrame:_fb.frame];
    [b3 addTarget:self action:@selector(im_) forControlEvents:UIControlEventTouchUpInside];
    [_background addSubview:b3];
    
    [self updateScrollView];
}

- (void)updateScrollView {
    CGFloat offset = 0.;
    CGFloat width = self.view.frame.size.width / 1.3;
    CGFloat border = (self.view.frame.size.width - width) / 2.;
    
    _scrollView.contentSize = CGSizeMake(width * self.imageViews.count + border * 2 * (self.imageViews.count - 1) + border * 2, _scrollView.frame.size.height);
    _scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    for (int i = 0; i < self.imageViews.count; i++) {
        FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self prettify:self.imageViews[i]]]]];
        [_posterImages addObject:image.posterImage];
        FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
        imageView.animatedImage = image;
        CGRect fr = CGRectMake(border, 0.0, width, _scrollView.frame.size.height);
        imageView.frame = CGRectMake(0, 0, width, _scrollView.frame.size.height);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        UIView *v = [[UIView alloc]initWithFrame:fr];
        [v addSubview:imageView];
        v.layer.cornerRadius = 12;
        v.clipsToBounds = YES;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(offset, 0., width + 2 * border, v.frame.size.height)];
        [view addSubview:v];
        offset += width;
        offset += border * 2.;
        [_scrollView addSubview:view];
    }

    _scrollView.pagingEnabled = YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
