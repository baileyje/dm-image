#import "DMImage.h"
#import "DMRequest.h"
#import "DMBufferingResponseCallback.h"
#import "DMResponse.h"
#import "DMBlocks.h"
#import "DMImageCache.h"

@implementation UIImage (AsyncLoading)

+ (void)imageWithUrl:(NSURL*)url callback:(DMImageCallback)callback {
    NSString* key = url.absoluteString;
    [DMImageCache.shared imageForKey:key callback:^(UIImage* image) {
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
    [DMImageCache.shared imageForKey:path callback:^(UIImage* image) {
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

- (UIImage*)decoded {
    return [self.class decodedImageFor:self];
}

@end



@implementation UIImage (Scaling)

+ (UIImage*)image:(UIImage*)image withSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextConcatCTM(context, CGAffineTransformMake(1, 0, 0, -1, 0, size.height));
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), image.CGImage);
    UIImage *resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resized;
}

+ (UIImage*)image:(UIImage*)image scaledToFit:(CGSize)size {
    CGFloat widthFactor = size.width / image.size.width;
    CGFloat heightFactor = size.height / image.size.height;
    CGFloat scaleFactor = widthFactor < heightFactor ? widthFactor : heightFactor;
    return [self image:image withSize:CGSizeMake(image.size.width * scaleFactor, image.size.height * scaleFactor)];
}

- (UIImage*)imageScaledToFit:(CGSize)size {
    return [self.class image:self scaledToFit:size];
}

- (UIImage*)imageWithSize:(CGSize)size {
    return [self.class image:self withSize:size];
}

@end

@implementation UIImage (ColorMasking)

+ (UIImage *)image:(UIImage *)image maskedWithColor:(UIColor *)color {
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextClipToMask(context, rect, [image CGImage]);
    CGContextFillRect(context, rect);
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return coloredImage;
}

- (UIImage*)imageMaskedWithColor:(UIColor*)color {
    return [self.class image:self maskedWithColor:color];
}

@end