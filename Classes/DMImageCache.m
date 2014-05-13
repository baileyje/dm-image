#import "DMImageCache.h"
#import "NSString+Digest.h"

#define DMImageCacheFileMaxAge 86400

@interface DMImageCache ()
@property (nonatomic, strong) NSString* namespace;
@property (nonatomic, strong) NSCache* cache;
@property (nonatomic) dispatch_queue_t dispatchQueue;
@property (nonatomic) NSFileManager* fileManager;
@property (nonatomic, strong) NSString* cachePath;
@end

@implementation DMImageCache

+ (instancetype)shared {
    static DMImageCache* shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[DMImageCache alloc] initWithNamespace:@"com.devemode.image.cache"];
    });
    return shared;
}

+ (NSString*)cachePathForNamespace:(NSString*)namespace {
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [cachePaths[0] stringByAppendingPathComponent:namespace];
}

- (instancetype)initWithNamespace:(NSString*)namespace {
    if(self = [super init]) {
        self.namespace = namespace;
        self.cache = [NSCache new];
        self.cache.name = namespace;
        self.fileManager = [NSFileManager defaultManager];
        self.dispatchQueue = dispatch_queue_create([[@"dm-image-cache:" stringByAppendingString:namespace] cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
        self.cachePath = [DMImageCache cachePathForNamespace:namespace];
        if(![self.fileManager fileExistsAtPath:self.cachePath]) {
            [self.fileManager createDirectoryAtPath:self.cachePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        self.maxFileAge = DMImageCacheFileMaxAge;
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(clearMemory) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(prune) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

- (NSString*)cachePathForKey:(NSString*)key {
    return [self.cachePath stringByAppendingPathComponent:[key md5]];
}

- (void)addImage:(UIImage*)image withKey:(NSString*)key {
    [self addImage:image withKey:key store:YES];
}

- (void)addImage:(UIImage*)image withKey:(NSString*)key store:(BOOL)store {
    [self.cache setObject:image forKey:key cost:(NSUInteger) (image.size.width * image.size.height * image.scale)];
    if(store) dispatch_async(self.dispatchQueue, ^{
        [self.fileManager createFileAtPath:[self cachePathForKey:key] contents:UIImagePNGRepresentation(image) attributes:nil];
    });
}

- (UIImage*)imageForKey:(NSString*)key {
    return [self.cache objectForKey:key];
}

- (void)imageForKey:(NSString*)key callback:(DMImageCallback)callback {
    [self imageForKey:key callback:callback loader:nil];
}

- (void)decodeAndCallback:(UIImage*)image callback:(DMImageCallback)callback {
    UIImage* decoded = [image decoded];
    dispatch_async(dispatch_get_main_queue(), ^{
        callback(decoded);
    });
}

- (void)imageForKey:(NSString*)key callback:(DMImageCallback)callback loader:(DMImageLoader)loader {
    UIImage* cached = [self imageForKey:key];
    if(cached) {
        return callback(cached);
    }
    NSString* cachePath = [self cachePathForKey:key];
    dispatch_async(self.dispatchQueue, ^{
        if([self.fileManager fileExistsAtPath:cachePath]) {
            NSData *data = [NSData dataWithContentsOfFile:cachePath];
            UIImage *image = [UIImage imageWithData:data];
            [self addImage:image withKey:key store:NO];
            [self decodeAndCallback:image callback:callback];
        } else if(loader) {
            loader(^ (UIImage* image) {
                [self addImage:image withKey:key store:YES];
                [self decodeAndCallback:image callback:callback];
            });
        } else {
            callback(nil);
        }
    });
}

- (UIImage*)removeImageWithKey:(NSString*)key {
    UIImage* existing = [self imageForKey:key];
    [self.cache removeObjectForKey:key];
    dispatch_async(self.dispatchQueue, ^{
        [self.fileManager removeItemAtPath:[self cachePathForKey:key] error:nil];
    });
    return existing;
}

- (void)clearMemory {
    [self.cache removeAllObjects];
}

- (void)clear {
    [self clearMemory];
    dispatch_async(self.dispatchQueue, ^{
        [self.fileManager removeItemAtPath:self.cachePath error:nil];
        [self.fileManager createDirectoryAtPath:self.cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    });
}

- (void)prune {
    dispatch_async(self.dispatchQueue, ^{
        NSDirectoryEnumerator* enumerator = [self.fileManager enumeratorAtURL:[NSURL fileURLWithPath:self.cachePath] includingPropertiesForKeys:@[NSURLContentModificationDateKey] options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];
        for(NSURL* fileUrl in enumerator) {
            NSDate* modified = [fileUrl resourceValuesForKeys:@[NSURLContentModificationDateKey] error:nil][NSURLContentModificationDateKey];
            if (-[modified timeIntervalSinceNow] > DMImageCacheFileMaxAge) {
                [self.fileManager removeItemAtURL:fileUrl error:nil];
                continue;
            }
        }
    });
}

- (NSUInteger)cacheLimit {
    return self.cache.totalCostLimit;
}

- (void)setCacheLimit:(NSUInteger)cacheLimit {
    self.cache.totalCostLimit = cacheLimit;
}

@end