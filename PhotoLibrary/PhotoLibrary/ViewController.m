//
//  ViewController.m
//  PhotoLibrary
//
//  Created by 王战胜 on 2017/2/20.
//  Copyright © 2017年 gocomtech. All rights reserved.
//

#import "ViewController.h"
#import <CTAssetsPickerController/CTAssetsPickerController.h>
#import "PHImageManager+CTAssetsPickerController.h"
#define tableViewRowHeight 80.0f

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,CTAssetsPickerControllerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *assets;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) PHImageRequestOptions *requestOptions;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //相册
    self.view.backgroundColor=[UIColor whiteColor];
    
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
            
            // init picker
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            
            // set delegate
            picker.delegate = self;
            
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
    
    [manager ctassetsPickerRequestImageForAsset:asset
                                     targetSize:targetSize
                                    contentMode:PHImageContentModeAspectFill
                                        options:self.requestOptions
                                  resultHandler:^(UIImage *image, NSDictionary *info){
                                      cell.imageView.image = image;
                                      [cell setNeedsLayout];
                                      [cell layoutIfNeeded];
                                  }];
//    [manager requestImageForAsset:asset
//                       targetSize:targetSize
//                      contentMode:PHImageContentModeAspectFill
//                          options:self.requestOptions
//                    resultHandler:^(UIImage *image, NSDictionary *info){
//                        cell.imageView.image = image;
//                        [cell setNeedsLayout];
//                        [cell layoutIfNeeded];
//                    }];

    return cell;
    
}

#pragma mark - Assets Picker Delegate相册选择完毕回调
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    self.assets = [NSMutableArray arrayWithArray:assets];
    [self.tableView reloadData];
}


@end
