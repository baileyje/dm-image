#import "ViewController.h"
#import "DmImageCache.h"
#import <DMImage/DMImage.h>

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSArray* images;
@end

@implementation ViewController

- (void)awakeFromNib {
    [super awakeFromNib];

    self.images = @[
        @"http://ia.media-imdb.com/images/M/MV5BMjEyMTEyOTQ0MV5BMl5BanBnXkFtZTcwNzU3NTMzNw@@._V1_SY317_CR9,0,214,317_.jpg",
        @"http://ia.media-imdb.com/images/M/MV5BMTQzMTg5NzYxMV5BMl5BanBnXkFtZTcwMDE0MjU1Mg@@._V1_SY317_CR10,0,214,317_.jpg",
        @"http://ia.media-imdb.com/images/M/MV5BMTI1NTk5ODY3Nl5BMl5BanBnXkFtZTcwNTE5MjcyMg@@._V1_SY317_CR7,0,214,317_.jpg",
        @"http://ia.media-imdb.com/images/M/MV5BMTM4MTE3NDY0NF5BMl5BanBnXkFtZTcwMjk3Mjg4Mw@@._V1_SX214_CR0,0,214,317_.jpg",
        @"http://ia.media-imdb.com/images/M/MV5BMTQzOTUwNzM0NV5BMl5BanBnXkFtZTgwMDg3MDQwMDE@._V1_SY317_CR74,0,214,317_.jpg",
        @"http://ia.media-imdb.com/images/M/MV5BMTg2NTg0NTI0Ml5BMl5BanBnXkFtZTYwNzM4Njc4._V1_SY317_CR22,0,214,317_.jpg",
        @"http://ia.media-imdb.com/images/M/MV5BMTAxMzQ5Mzk2MDheQTJeQWpwZ15BbWU3MDk5MzY1MDY@._V1_SX214_CR0,0,214,317_.jpg",
        @"http://ia.media-imdb.com/images/M/MV5BMTM5NjkwOTMxNV5BMl5BanBnXkFtZTcwNTY3NDM3OA@@._V1_SX214_CR0,0,214,317_.jpg",
        @"http://ia.media-imdb.com/images/M/MV5BNjcxMTg5NjY1OF5BMl5BanBnXkFtZTcwMzYzNDk0Mg@@._V1_SX214_CR0,0,214,317_.jpg",
        @"http://ia.media-imdb.com/images/M/MV5BMjE4OTIyNDQ0MF5BMl5BanBnXkFtZTcwNTAwODE1OQ@@._V1._SX200_SY225_.jpg",
        @"http://ia.media-imdb.com/images/M/MV5BMTcwNTY1NzYwMl5BMl5BanBnXkFtZTYwNTk1MzU1._V1_SX214_CR0,0,214,317_.jpg",
        @"http://ia.media-imdb.com/images/M/MV5BMTMxMjUzOTEzOF5BMl5BanBnXkFtZTcwMjAwOTA4Mg@@._V1_SY317_CR12,0,214,317_.jpg",
        @"http://ia.media-imdb.com/images/M/MV5BMjE0MjkwNDM2OF5BMl5BanBnXkFtZTYwMjI0MjA1._V1_SX100_CR0,0,100,100_.jpg",
        @"http://ia.media-imdb.com/images/M/MV5BNTU1NzQ5NTM3NF5BMl5BanBnXkFtZTcwNDkzMDkwOA@@._V1_SY317_CR6,0,214,317_.jpg",
        @"http://ia.media-imdb.com/images/M/MV5BOTk1MTIwMTMyNl5BMl5BanBnXkFtZTcwNDA2NjgyOQ@@._V1_SX213_CR0,0,213,317_.jpg"
    ];

    self.collectionView.dataSource = self;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reload" style:UIBarButtonItemStylePlain target:self.collectionView action:@selector(reloadData)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:DMImageCache.shared action:@selector(clear)];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"IMAGE_CELL" forIndexPath:indexPath];
    UIImageView* imageView = (UIImageView*) [cell viewWithTag:1];
    [UIImage imageWithUrl:[NSURL URLWithString:self.images[indexPath.row]] callback:^(UIImage*image) {
        imageView.image = image;
    }];
    return cell;
}

@end