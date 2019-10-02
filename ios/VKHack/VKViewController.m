//
//  VKViewController.m
//  VKHack
//
//  Created by Vladislav Shakhray on 29.09.2019.
//  Copyright © 2019 Vladislav Shakhray. All rights reserved.
//

#import "VKViewController.h"

@interface VKViewController ()

@end

@implementation VKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(skip)];
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    // Do any additional setup after loading the view.
    UIImage *img = [UIImage imageNamed:@"sportsru"];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [imgView setImage:img];
    // setContent mode aspect fit
    [imgView setContentMode:UIViewContentModeScaleAspectFit];
    self.navigationItem.titleView = imgView;

    
    _authButton.backgroundColor = [UIColor colorWithRed:70./255 green:128./255 blue:194./255 alpha:1];
        _authButton.layer.cornerRadius = 8;
//        _authButton.layer.borderWidth = 1.5;
//        _authButton.layer.borderColor =  _authButton.tintColor.CGColor;
//    _conti
        [_authButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _authButton.enabled = YES;
}
- (IBAction)auth:(id)sender {
    [[VKSdk initializeWithAppId:@"7152061"] registerDelegate:self];
    NSArray *SCOPE = @[@"groups", @"stories", @"photos"];

    [VKSdk wakeUpSession:SCOPE completeBlock:^(VKAuthorizationState state, NSError *error) {
        if (state == VKAuthorizationAuthorized) {
            // Authorized and ready to go
            int i = 0;
        } else if (error) {
            int i = 0;
            // Some error happend, but you may try later
        } else {
            [VKSdk authorize:SCOPE];
        }
    }];
}

- (void)vkSdkAccessAuthorizationFinishedWithResult:(VKAuthorizationResult *)result
{
    if (result.token) {
        int i = 0;
//        [SVProgressHUD show];
//        [[NSUserDefaults standardUserDefaults] setObject:result.token forKey:@"token"];
        VKRequest *req = [VKRequest requestWithMethod:@"groups.get" andParameters:@{@"fields" : @"name", @"extended" : @"1"}];
        [req executeWithResultBlock:^(VKResponse *response) {
                NSLog(@"Json result: %@", response.json);
            NSString *items = @"";
            for (id item in response.json[@"items"]) {
                NSArray* words = [(NSString *)item[@"name"] componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString* res = [words componentsJoinedByString:@""];
                words = [res componentsSeparatedByCharactersInSet :[NSCharacterSet punctuationCharacterSet]];
                res = [words componentsJoinedByString:@""];
                items = [items stringByAppendingString:[NSString stringWithFormat:@"%@,", res]];
            }
            id resp =
            [self performGETRequestWithMethod:@"auth/get_teams" formData:items];
            int i = 0;
            } errorBlock:^(NSError * error) {
            if (error.code != VK_API_ERROR) {
                [error.vkError.request repeat];
            } else {
                NSLog(@"VK error: %@", error);
            }
        }];
    } else {
        int i = 0;
    }
}

- (id)performGETRequestWithMethod:(NSString *)method formData:(NSString *)form {
    static NSString *const kBaseURL = @"http://95.213.37.132:5000";
    
    NSString *url = [NSString stringWithFormat:@"%@/%@?", kBaseURL, method];

        
    __block id response;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        //    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // only needed if the server is not returning JSON; if web service returns JSON, remove this line
    NSURLSessionTask *task = [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            NSError *error;

//            if (![formData appendPartWithFileURL:[NSURL fileURLWithPath:path] name:@"image" fileName:@"myfile.png" mimeType:@"image/png" error:&error]) {
//                NSLog(@"error appending part: %@", error);
//            }
            
            [formData appendPartWithFormData:[form dataUsingEncoding:NSUTF8StringEncoding] name:@"groups"];
    //        if (![formData appendPartWithFileURL:[NSURL fileURLWithPath:jsonpath] name:@"data" fileName:[NSString stringWithFormat:@"json%d_%d.json", MIN(self.selectedCountry, 4), self.selectedType] mimeType:@"application/json" error:&error]) {
    //            NSLog(@"error appending part: %@", error);
    //        }
        
//                    if (![formData appendPartWithFileURL:[NSURL fileURLWithPath:jsonpath] name:@"data" fileName:[NSString stringWithFormat:@"json1_1.json", MIN(self.selectedCountry, 4), self.selectedType] mimeType:@"application/json" error:&error]) {
//                        NSLog(@"error appending part: %@", error);
//                    }
        }  progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            
//            [SVProgressHUD dismiss];
            
//            [self animateAlpha:self.logo alphaBegin:1 alphaEnd:0 time:1. completion:nil];
//            [self animateAlpha:self.text alphaBegin:1 alphaEnd:0 time:1. completion:nil];
//            [self animateAlpha:self.authButton alphaBegin:1 alphaEnd:0 time:1. completion:nil];
//            int t = 4;
            if (!responseObject) {
                [self skip];
                return;
            }
            [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"screen_3_logo"] forKey:@"link"];
            [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"screen_3_text"][0][0] forKey:@"string1"];
            [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"screen_3_text"][0][1] forKey:@"string2"];
            [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"screen_3_text"][1][0] forKey:@"string3"];
            [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"screen_3_text"][1][1] forKey:@"string4"];
            [self skip];
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    PHFetchOptions *const options = nil;
    options.sortDescriptors = @[
        [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO],
    ];

    PHFetchResult<PHAsset *> *images = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
[segue.destinationViewController setModalInPresentation:YES];
}

- (void)skip {
    [self performSegueWithIdentifier:@"skip_auth" sender:self];
}
//
//- (id)performGETRequestWithMethod:(NSString *)method parameters:(NSDictionary<NSString *, NSString *> *)parameters {
//    static NSString *const kBaseURL = @"http://95.213.37.132:5000";
//
//    NSString *url = [NSString stringWithFormat:@"%@/%@?", kBaseURL, method];
//    for (NSString *key in parameters) {
//        url = [url stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", key, parameters[key]]];
//    }
//
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//    [request setHTTPMethod:@"GET"];
//    [request setURL:[NSURL URLWithString:url]];
//
//    NSError *error = nil;
//    NSHTTPURLResponse *responseCode = nil;
//    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
//
//    if([responseCode statusCode] != 200){
//        NSLog(@"Error getting %@, HTTP status code %i", url, [responseCode statusCode]);
//        return nil;
//    }
//
//    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//    NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
//    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
