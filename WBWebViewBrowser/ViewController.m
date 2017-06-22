//
//  ViewController.m
//  WBWebViewBrowser
//
//  Created by 吴斌 on 2017/6/22.
//  Copyright © 2017年 吴斌. All rights reserved.
//

#import "ViewController.h"
#import "WBWebViewController.h"
@interface ViewController ()
@end

@implementation ViewController

#pragma mark - 生命周期 Life Circle
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)gotoBrowser:(id)sender {
    WBWebViewController *webVC = [[WBWebViewController alloc] init];
    webVC.urlString = @"http://weibo.com/535478908";
    webVC.isWKWebView = YES;
    [self.navigationController pushViewController:webVC animated:YES];
}

@end
