#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DMImage.h"

typedef void(^DMImageLoader)(DMImageCallback);

@interface DmImageCache : NSObject

@property (nonatomic) NSUInteger cacheLimit;

+ (instancetype)shared;

- (instancetype)initWithNamespace:(NSString*)namespace;

- (void)addImage:(UIImage*)image withKey:(NSString*)key;

- (UIImage*)imageForKey:(NSString*)key;

- (void)imageForKey:(NSString*)key callback:(DMImageCallback)callback;

- (void)imageForKey:(NSString*)key callback:(DMImageCallback)callback loader:(DMImageLoader)loader;

- (UIImage*)removeImageWithKey:(NSString*)key;

- (void)clear;

- (void)clearMemory;

@end