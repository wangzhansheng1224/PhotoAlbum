//
//  ViewController.m
//  PhotoLibrary
//
//  Created by 王战胜 on 2017/2/20.
//  Copyright © 2017年 gocomtech. All rights reserved.
//

#import "ViewController.h"
#import <CTAssetsPickerController/CTAssetsPickerController.h>
#import "FileHash.h"
#import "UIImage+PPCategory.h"
#import "WZSTableViewCell.h"
#import "ImageModel.h"
#define tableViewRowHeight 80.0f
#define MAX_PHOTOS_NUM 5

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,CTAssetsPickerControllerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) PHImageRequestOptions *requestOptions;
@property (nonatomic, strong) UIColor *color1;
@property (nonatomic, strong) UIColor *color2;
@property (nonatomic, strong) UIFont *font;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"相册";
    
    self.color1 = [UIColor colorWithWhite:0.1 alpha:1];
    self.color2 = [UIColor whiteColor];
    self.font   = [UIFont fontWithName:@"Futura-Medium" size:18.0];
    
    // Navigation Bar apperance//定制导航栏
    UINavigationBar *navBar = [UINavigationBar appearanceWhenContainedIn:[CTAssetsPickerController class], nil];
    
    // set nav bar style to black to force light content status bar style将底端状态栏变为白色
    navBar.barStyle = UIBarStyleBlack;
    
    // bar tint color背景
    navBar.barTintColor = self.color1;
    
    // tint color左右item的颜色
    navBar.tintColor = self.color2;
    
    // title标题
    navBar.titleTextAttributes =
    @{NSForegroundColorAttributeName: self.color2,
      NSFontAttributeName : self.font};
    
    // bar button item appearance
    UIBarButtonItem *barButtonItem = [UIBarButtonItem appearanceWhenContainedIn:[CTAssetsPickerController class], nil];
    [barButtonItem setTitleTextAttributes:@{NSFontAttributeName : [self.font fontWithSize:18.0]} forState:UIControlStateNormal];
    
    UIBarButtonItem *clearButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Clear"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(clearAssets)];
    
    
    UIBarButtonItem *addButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Pick"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(pickAssets)];
    
    UIBarButtonItem *space =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    //将上面的item添加到 工具条上
    self.toolbarItems = @[clearButton, space, addButton];
    
    //设置工具条 是否隐藏 默认是YES 隐藏
    self.navigationController.toolbarHidden = NO;
    
    
    self.tableView = [[UITableView alloc]initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.tableFooterView=[[UIView alloc]init];
    [self.view addSubview:self.tableView];
    self.tableView.rowHeight = tableViewRowHeight;
    [self.tableView registerNib:[UINib nibWithNibName:@"WZSTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    
    //图片时间
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    self.dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    
    self.requestOptions = [[PHImageRequestOptions alloc] init];
    self.requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    self.requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
}

- (void)clearAssets{
    [self.assets removeAllObjects];
    [self.tableView reloadData];
}

- (void)pickAssets{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // init picker初始化相册
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            
            // set delegate添加代理
            picker.delegate = self;
            
            
            
            // set default album (Camera Roll)默认点开第一个相册
            picker.defaultAssetCollection = PHAssetCollectionSubtypeSmartAlbumUserLibrary;
            
            
            
            // create options for fetching photo only只显示图片
            PHFetchOptions *fetchOptions = [PHFetchOptions new];
            fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
            
            // assign options
            picker.assetsFetchOptions = fetchOptions;
            
            
            
            //不显示空相册
            picker.showsEmptyAlbums = NO;
            picker.showsNumberOfAssets=YES;
            
            
            // to present picker as a form sheet in iPad
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                picker.modalPresentationStyle = UIModalPresentationFormSheet;
            
            // present picker
            [self presentViewController:picker animated:YES completion:nil];
            
        });
    }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.assets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WZSTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    ImageModel *model=self.assets[indexPath.row];
    cell.LeftImage.image=[UIImage imageWithContentsOfFile:model.imagePath];
    cell.RightLabel.text=model.md5Str;
    
//    cell.textLabel.text         = [self.dateFormatter stringFromDate:asset.creationDate];
//    cell.detailTextLabel.text   = [NSString stringWithFormat:@"%ld X %ld", (long)asset.pixelWidth, (long)asset.pixelHeight];
//    cell.accessoryType          = UITableViewCellAccessoryDisclosureIndicator;
//    cell.clipsToBounds          = YES;
    return cell;
    
}

#pragma mark - Assets Picker Delegate相册选择完毕回调
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    __block NSInteger Num = 0;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    for (NSInteger i=0; i<assets.count; i++) {
        PHAsset *assetImage = assets[i];
        
        PHImageManager *manager = [PHImageManager defaultManager];
        CGSize targetSize = CGSizeMake(assetImage.pixelWidth, assetImage.pixelHeight);
        
        
        [manager requestImageForAsset:assetImage
                                targetSize:targetSize
                               contentMode:PHImageContentModeAspectFill
                                   options:self.requestOptions
                             resultHandler:^(UIImage *image, NSDictionary *info){
                                 
                                 NSData *data;
                                 if (image.size.width > 4000 || image.size.height > 4000) {
                                     CGSize size = CGSizeMake(image.size.width *0.6, image.size.height *0.6);
                                     image = [image scaleToSize:size];
                                     //image = [self rotateImage:image];
                                     data = UIImageJPEGRepresentation(image, 0.000001f);
                                 }else{
                                     image = [self rotateImage:image];
                                     data = UIImageJPEGRepresentation(image, 0.8f);
                                 }
                                 NSString *path_document = NSHomeDirectory();
                                 //设置一个图片的存储路径
                                 NSRange rang=[assetImage.localIdentifier rangeOfString:@"/"];
                                 NSString *pathStr=[assetImage.localIdentifier substringToIndex:rang.location];
                                 
                                 NSString *imagePath = [path_document stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@.jpg",pathStr]];
                                 [data writeToFile:imagePath atomically:YES];
                                 NSLog(@"%@",imagePath);
                                 //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
                                 
                                 NSString *executableFileMD5Hash = [FileHash md5HashOfFileAtPath:imagePath];
                                 
                                 ImageModel *model=[[ImageModel alloc]init];
                                 model.imagePath=imagePath;
                                 model.md5Str=executableFileMD5Hash;
                                 [self.assets addObject:model];
                                 
                                 Num++;
                                 if (Num==assets.count) {
                                     [self.tableView reloadData];
                                 }
                             }];

    }
    
    
}

#pragma mark - implement should select asset delegate限制最大选择数量
- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(PHAsset *)asset
{
    NSInteger max = MAX_PHOTOS_NUM;
    
    // show alert gracefully
    if (picker.selectedAssets.count >= max)
    {
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"提示"
                                            message:[NSString stringWithFormat:@"请不要添加超过%ld张图片", (long)max]
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action =
        [UIAlertAction actionWithTitle:@"确定"
                                 style:UIAlertActionStyleDefault
                               handler:nil];
        
        [alert addAction:action];
        
        [picker presentViewController:alert animated:YES completion:nil];
    }
    
    // limit selection to max
    return (picker.selectedAssets.count < max);
}

#pragma mark - 修改CollectionCell的layout
- (UICollectionViewLayout *)assetsPickerController:(CTAssetsPickerController *)picker collectionViewLayoutForContentSize:(CGSize)contentSize traitCollection:(UITraitCollection *)trait
{
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake((contentSize.width-20)/4, (contentSize.width-20)/4);
    layout.minimumInteritemSpacing = 4;
    layout.minimumLineSpacing = 4;
    layout.sectionInset = UIEdgeInsetsMake(4, 4, 4, 4);
    layout.footerReferenceSize = CGSizeMake(contentSize.width, 10);
    
    return (UICollectionViewLayout *)layout;
}




//处理图片
- (UIImage* )rotateImage:(UIImage *)image {
    //    int kMaxResolution = 320;
    // Or whatever
    CGImageRef imgRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    
    
    //    if (width > kMaxResolution || height > kMaxResolution) {
    //        CGFloat ratio = width  /  height;
    //        if (ratio > 1 ) {
    //            bounds.size.width = kMaxResolution;
    //            bounds.size.height = bounds.size.width / ratio;
    //        }
    //        else {
    //            bounds.size.height = kMaxResolution;
    //            bounds.size.width = bounds.size.height * ratio;
    //        }
    //    }
    CGFloat scaleRatio = 1;//bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch (orient) {
        case UIImageOrientationUp:
            //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
        case UIImageOrientationUpMirrored:
            //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0 );
            break;
        case UIImageOrientationDown:
            //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored:
            //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
        case UIImageOrientationLeftMirrored:
            //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width );
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0 );
            break;
        case UIImageOrientationLeft:
            //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate( transform, 3.0 * M_PI / 2.0  );
            break;
        case UIImageOrientationRightMirrored:
            //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate( transform, M_PI / 2.0);
            break;
        case UIImageOrientationRight:
            //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0 );
            break;
        default:
            return image;
            ;
            //            [NSExceptionraise:NSInternalInconsistencyExceptionformat:@"Invalid image orientation"];
    }
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    CGContextConcatCTM(context, transform );
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageCopy;
}




- (NSMutableArray *)assets{
    if (!_assets) {
        _assets=[[NSMutableArray alloc]init];
    }
    return _assets;
}


@end
