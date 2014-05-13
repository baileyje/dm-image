#import "DMImage.h"
#import "DMRequest.h"
#import "DMBufferingResponseCallback.h"
#import "DMResponse.h"
#import "DMBlocks.h"
#import "DmImageCache.h"

@implementation UIImage (AsyncLoading)

+ (void)imageWithUrl:(NSURL*)url callback:(DMImageCallback)callback {
    NSString* key = url.absoluteString;
    [DmImageCache.shared imageForKey:key callback:^(UIImage* image) {
        callback(image);
    } loader:^(DMImageCallback callback) {
        [[[[DMRequest get:url.absoluteString]
            success:[DMBufferingResponseCallback with:^ (DMResponse* response, NSData* data){
                callback([UIImage imageWithData:data]);
            }]]
            error:^(DMResponse* response, DMCallback next) {
                callback(nil);
                next();
            }]
            fetch];
    }];
}

+ (void)imageWithPath:(NSString*)path callback:(DMImageCallback)callback {
    [DmImageCache.shared imageForKey:path callback:^(UIImage* image) {
        callback(image);
    } loader:^(DMImageCallback callback) {
        NSData* data = [NSData dataWithContentsOfFile:path];
        if(data) {
            callback([UIImage imageWithData:data]);
        } else {
            callback(nil);
        }
    }];
}

@end

@implementation UIImage (Decoding)

+ (UIImage*)decodedImageFor:(UIImage*)image {
    CGImageRef reference = image.CGImage;
    CGSize size = CGSizeMake(CGImageGetWidth(reference), CGImageGetHeight(reference));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, (size_t) size.width, (size_t) size.height, CGImageGetBitsPerComponent(reference), 0, colorSpace, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
    CGColorSpaceRelease(colorSpace);
    if (!context) return image;
    CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), reference);
    CGImageRef decodedReference = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    UIImage *decoded = [UIImage imageWithCGImage:decodedReference scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(decodedReference);
    return decoded;
}

- (UIImage*)decode {
    return [self.class decodedImageFor:self];
}

@end