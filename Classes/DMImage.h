#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^DMImageCallback)(UIImage*);

@interface UIImage (AsyncLoading)

+ (void)imageWithUrl:(NSURL*)url callback:(DMImageCallback)callback;

+ (void)imageWithPath:(NSString*)path callback:(DMImageCallback)callback;

@end

@interface UIImage (Decoding)

+ (UIImage*)decodedImageFor:(UIImage*)image;

- (UIImage*)decode;

@end