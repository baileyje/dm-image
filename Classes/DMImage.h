#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^DMImageCallback)(UIImage*);

@interface UIImage (AsyncLoading)

+ (void)imageWithUrl:(NSURL*)url callback:(DMImageCallback)callback;

+ (void)imageWithPath:(NSString*)path callback:(DMImageCallback)callback;

@end

@interface UIImage (Decoding)

+ (UIImage*)decodedImageFor:(UIImage*)image;

- (UIImage*)decoded;

@end

@interface UIImage (ColorMasking)

+ (UIImage *)image:(UIImage *)image maskedWithColor:(UIColor *)color;

- (UIImage*)imageMaskedWithColor:(UIColor *)color;

@end

@interface UIImage (Scaling)

+ (UIImage*)image:(UIImage*)image withSize:(CGSize)size;

+ (UIImage*)image:(UIImage*)image scaledToFit:(CGSize)size;

- (UIImage*)imageWithSize:(CGSize)size;

- (UIImage *)imageScaledToFit:(CGSize)size;

@end