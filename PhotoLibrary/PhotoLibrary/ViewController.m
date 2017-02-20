//
//  ViewController.m
//  PhotoLibrary
//
//  Created by 王战胜 on 2017/2/20.
//  Copyright © 2017年 gocomtech. All rights reserved.
//

#import "ViewController.h"
#import <CTAssetsPickerController/CTAssetsPickerController.h>
//#import "PHImageManager+CTAssetsPickerController.h"
#define tableViewRowHeight 80.0f

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,CTAssetsPickerControllerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *assets;
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
    
    //图片时间
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    self.dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    
    self.requestOptions = [[PHImageRequestOptions alloc] init];
    self.requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    self.requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
}

- (void)clearAssets{
    self.assets = [[NSMutableArray alloc] init];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];    PHAsset *asset = [self.assets objectAtIndex:indexPath.row];
    cell.textLabel.text         = [self.dateFormatter stringFromDate:asset.creationDate];
    cell.detailTextLabel.text   = [NSString stringWithFormat:@"%ld X %ld", (long)asset.pixelWidth, (long)asset.pixelHeight];
    cell.accessoryType          = UITableViewCellAccessoryDisclosureIndicator;
    cell.clipsToBounds          = YES;
    
    PHImageManager *manager = [PHImageManager defaultManager];
    CGFloat scale = UIScreen.mainScreen.scale;
    CGSize targetSize = CGSizeMake(tableViewRowHeight * scale, tableViewRowHeight * scale);
    
//    [manager ctassetsPickerRequestImageForAsset:asset
//                                     targetSize:targetSize
//                                    contentMode:PHImageContentModeAspectFill
//                                        options:self.requestOptions
//                                  resultHandler:^(UIImage *image, NSDictionary *info){
//                                      cell.imageView.image = image;
//                                      [cell setNeedsLayout];
//                                      [cell layoutIfNeeded];
//                                  }];
    //3.3.0版本方法
    [manager requestImageForAsset:asset
                       targetSize:targetSize
                      contentMode:PHImageContentModeAspectFill
                          options:self.requestOptions
                    resultHandler:^(UIImage *image, NSDictionary *info){
                        cell.imageView.image = image;
                        [cell setNeedsLayout];
                        [cell layoutIfNeeded];
                    }];
    
    return cell;
    
}

#pragma mark - Assets Picker Delegate相册选择完毕回调
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    self.assets = [NSMutableArray arrayWithArray:assets];
    [self.tableView reloadData];
}

#pragma mark - implement should select asset delegate限制最大选择数量
- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(PHAsset *)asset
{
    NSInteger max = 3;
    
    // show alert gracefully
    if (picker.selectedAssets.count >= max)
    {
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Attention"
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


@end
