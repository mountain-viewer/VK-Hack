#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <dispatch/dispatch.h>
#import <UIKit/UIKit.h>
dispatch_queue_t backgroundQueue;

@interface GIFConverter: NSObject

@property (strong, nonatomic) AVAssetWriter *videoWriter;

/**
 Convert a .GIF to .MP4 video file
 
 @param gif GIF image loaded into an NSData structure, eg.
            [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://i.imgur.com/xqG0QP3.gif"]];
 @param speed Speed of output video, where 1.0 is actual speed, 2.0 is double speed
 @param size The wanted size of the output file, will keep aspect and fill rest with black. Use CGSizeMake(0, 0) if you want to keep original size
 @param repeat Number of times to repeat GIF, 0 = play once, do not repeat
 @param output Path to output file, must not exist
 @param completion Block to call on completion, contains error if any
 */
- (void)convertGIFToMP4:(NSData *)gif speed:(float)speed size:(CGSize)size repeat:(int)repeat output:(NSString *)path completion:(void (^)(NSError *))completion;

@end
