//
//  WBWebViewController.m
//  封装webView
//
//  Created by 吴斌 on 2017/6/3.
//  Copyright © 2017年 吴斌. All rights reserved.
//

#import "WBWebViewController.h"
#import <WebKit/WebKit.h>
static inline UIColor *webRGBAColor(float r,float g,float b, float a) { return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];}
/*! 大于8.0 */
#define IOS8x ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define Support @"小斌斌工作室"

@interface WBWebViewController ()<UIWebViewDelegate,UIActionSheetDelegate,WKNavigationDelegate,WKUIDelegate,UIScrollViewDelegate>
/** 进度条 */
@property (nonatomic,strong) UIProgressView   *progressView;
/** UIWebView */
@property (nonatomic,strong) UIWebView        *webView;
/** WKWebView */
@property (nonatomic,strong) WKWebView        *wkWebView;
/** 网页提供方 */
@property (nonatomic,strong) UILabel          *supportLabel;

@property (assign, nonatomic) NSUInteger       loadCount;
@end

@implementation WBWebViewController

#pragma mark - 生命周期 Life Circle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configUI];
    [self configBackItem];
}
#pragma mark - ***** UI创建
- (void)configUI{
    self.supportLabel.hidden = NO;
    self.progressView.hidden = NO;
    if (_isWKWebView) {
        WKWebView *wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        wkWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        wkWebView.backgroundColor = [UIColor clearColor];
        wkWebView.navigationDelegate = self;
        wkWebView.UIDelegate = self;
        wkWebView.scrollView.delegate = self;
        
        /*! 适应屏幕 */
//      wkWebView.scalesPageToFit = YES;
//        ! 解决iOS9.2以上黑边问题 
        wkWebView.opaque = NO;
        /*! 关闭多点触控 */
        wkWebView.multipleTouchEnabled = YES;
        /*! 加载网页中的电话号码，单击可以拨打 */
//                wkWebView.dataDetectorTypes = YES;
        
        [self.view insertSubview:wkWebView belowSubview:_progressView];

        [wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        
        if (self.HTMLString != nil) {
            [wkWebView loadHTMLString:self.HTMLString baseURL:nil];
        }else{
            NSString *encodeStr=[_urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:encodeStr]];
            
            if (![self.token isEqualToString:@""] && ![self.token isKindOfClass:[NSNull class]] && self.token != nil) {
                NSMutableURLRequest *mutableRequest = [request mutableCopy];
                [mutableRequest setValue:self.token forHTTPHeaderField:@"token"];
                request = [mutableRequest copy];
            }
            [wkWebView loadRequest:request];
        }
        self.wkWebView = wkWebView;
    }else{
        UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        webView.backgroundColor = [UIColor clearColor];
        webView.delegate = self;
        webView.scrollView.delegate = self;
        
        /*! 适应屏幕 */
        webView.scalesPageToFit = YES;
        /*! 解决iOS9.2以上黑边问题 */
        webView.opaque = NO;
        /*! 关闭多点触控 */
        webView.multipleTouchEnabled = YES;
        /*! 加载网页中的电话号码，单击可以拨打 */
        webView.dataDetectorTypes = YES;
        
        [self.view insertSubview:webView belowSubview:_progressView];
        
        NSString *encodeStr=[_urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:encodeStr]];
        
        if (![self.token isEqualToString:@""] && ![self.token isKindOfClass:[NSNull class]] && self.token != nil) {
            NSMutableURLRequest *mutableRequest = [request mutableCopy];
            //        [mutableRequest setHTTPMethod:@"POST"];
            //        NSString *body = [NSString stringWithFormat: @"token=%@",[[NSUserDefaults standardUserDefaults]objectForKey:Token]];
            //        [mutableRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
            [mutableRequest setValue:self.token forHTTPHeaderField:@"token"];
            request = [mutableRequest copy];
        }
        [webView loadRequest:request];
        self.webView = webView;
    }
}

#pragma mark - ***** 导航栏的反回按钮
- (void)configBackItem{
    UIImage *backImage = [UIImage imageNamed:@"WebViewImage.bundle/navigation_back"];
    backImage = [backImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIButton *backBtn = [[UIButton alloc] init];
    [backBtn setBackgroundImage:backImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn sizeToFit];
    
    UIBarButtonItem *colseItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = colseItem;
}

- (void)backBtnAction:(UIButton *)sender{
    if (_isWKWebView) {
        if (self.wkWebView.canGoBack) {
            [self.wkWebView goBack];
            if (self.navigationItem.leftBarButtonItems.count == 1) {
                [self configCloseItem];
            }
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else {
        if (self.webView.canGoBack) {
            [self.webView goBack];
            if (self.navigationItem.leftBarButtonItems.count == 1) {
                [self configCloseItem];
            }
        }else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - ***** 导航栏的关闭按钮
- (void)configCloseItem{
    UIButton *colseBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [colseBtn setImage:[UIImage imageNamed:@"WebViewImage.bundle/close"] forState:UIControlStateNormal];
    [colseBtn addTarget:self action:@selector(colseBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [colseBtn sizeToFit];
    
    UIBarButtonItem *colseItem = [[UIBarButtonItem alloc] initWithCustomView:colseBtn];
    NSMutableArray *newArr = [NSMutableArray arrayWithObjects:self.navigationItem.leftBarButtonItem,colseItem, nil];
    self.navigationItem.leftBarButtonItems = newArr;
}

#pragma mark 关闭按钮点击
- (void)colseBtnAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 计算wkWebView进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (object == self.wkWebView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        NSLog(@"%f",newprogress);
        if (newprogress < 1.0) {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newprogress animated:YES];
        }else{
            self.progressView.hidden = YES;
            [self.progressView setProgress:0 animated:NO];
        }
    }
}

#pragma mark - ***** dealloc 取消监听
- (void)dealloc{
    if (_isWKWebView) {
        [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    }
}

#pragma mark - WKNavigationDelegate 【该代理提供的方法，可以用来追踪加载过程（页面开始加载、加载完成、加载失败）、决定是否执行跳转。】
#pragma mark 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    // 类似UIWebView的 -webViewDidStartLoad:
    NSLog(@"didStartProvisionalNavigation");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    NSLog(@"didCommitNavigation");
}

#pragma mark 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    // 类似 UIWebView 的 －webViewDidFinishLoad:
    NSLog(@"didFinishNavigation");
    self.navigationItem.title = webView.title;
    self.supportLabel.text = [NSString stringWithFormat:@"网页由 %@ 提供\n%@提供技术支持",webView.URL.host,Support];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
     //获取内容高度
//        CGFloat height =  [[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollHeight"] intValue];
//        
//        NSLog(@"html 的高度：%f", height);
}

#pragma mark 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    // 类似 UIWebView 的- webView:didFailLoadWithError:
    NSLog(@"didFailProvisionalNavigation");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

/*! 页面跳转的代理方法有三种，分为（收到跳转与决定是否跳转两种）*/
#pragma mark 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    
}

#pragma mark 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    decisionHandler(WKNavigationResponsePolicyAllow);
}

#pragma mark 在发送请求之前，决定是否跳转，如果不添加这个，那么wkwebview跳转不了AppStore
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if ([webView.URL.absoluteString hasPrefix:@"https://itunes.apple.com"])
    {
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    else
    {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

//- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
//{
//    
//}

#pragma mark 创建一个新的WebView
//- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
//{
//    // 接口的作用是打开新窗口委托
//    [self createNewWebViewWithURL:webView.URL.absoluteString config:configuration];
//    return _wkWebView2;
//}
//
//- (void)createNewWebViewWithURL:(NSString *)url config:(WKWebViewConfiguration *)configuration
//{
//    _wkWebView2 = [[WKWebView alloc] initWithFrame:self.wkWebView.frame configuration:configuration];
//    [_wkWebView2 loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
//}

#pragma mark 针对于web界面的三种提示框（警告框、确认框、输入框）分别对应三种代理方法。下面只举了警告框的例子。
/**
 *  web界面中有弹出警告框时调用
 *
 *  @param webView           实现该代理的webview
 *  @param message           警告框中的内容
 *  @param frame             主窗口
 *  @param completionHandler 警告框消失调用
 */
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    //  js 里面的alert实现，如果不实现，网页的alert函数无效  ,
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler(YES);
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action){
                                                          completionHandler(NO);
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark 从web界面中接收到一个脚本时调用
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
}


#pragma mark - ***** UIWebViewDelegate
#pragma mark 计算webView进度条
- (void)setLoadCount:(NSUInteger)loadCount
{
    _loadCount = loadCount;
    if (loadCount == 0)
    {
        self.progressView.hidden = YES;
        [self.progressView setProgress:0 animated:NO];
    }
    else
    {
        self.progressView.hidden = NO;
        CGFloat oldP = self.progressView.progress;
        CGFloat newP = (1.0 - oldP) / (loadCount + 1) + oldP;
        if (newP > 0.95)
        {
            newP = 0.95;
        }
        [self.progressView setProgress:newP animated:YES];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.loadCount ++;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.loadCount --;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSString *currentURL = [webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
    NSURL *url = [NSURL URLWithString:currentURL];
    self.supportLabel.text = [NSString stringWithFormat:@"网页由 %@ 提供\n%@提供技术支持",url.host,Support];
    // 获取内容高度
    CGFloat height =  [[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollHeight"] intValue];
    
    NSLog(@"html 的高度：%f", currentURL);
    
    //    CGFloat htmlHeight;
    //    // 防止死循环
    //    if (height != htmlHeight)
    //    {
    //        
    //        htmlHeight = height;
    //        
    //        if (height > 0)
    //        {
    //            // 更新布局
    //            CGFloat paddingEdge = 10;
    //            [webView mas_remakeConstraints:^(MASConstraintMaker *make) {
    //                
    //                make.left.equalTo(self.view).with.offset(paddingEdge);
    //                make.right.mas_equalTo(-paddingEdge);
    //                make.top.equalTo(self.view).with.offset(paddingEdge);
    //                make.bottom.mas_equalTo(-paddingEdge);
    //                
    //            }];
    //            
    //            // 刷新cell高度
    ////            _viewModel.cellHeight = _viewModel.otherHeight + _viewModel.htmlHeight;
    ////            [_viewModel.refreshSubject sendNext:nil];
    //        }
    //        NSLog(@"html 的高度：%f", htmlHeight);
    //    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.loadCount --;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

//设置请求头
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
//    NSMutableURLRequest *mutableRequest = [request mutableCopy];
//    NSDictionary *requestHeaders = request.allHTTPHeaderFields;
//    if (requestHeaders[@"token"]) {
//        return YES;
//    } else {
//        [mutableRequest setValue:[[NSUserDefaults standardUserDefaults]objectForKey:Token] forHTTPHeaderField:@"token"];
//        request = [mutableRequest copy];
//        [webView loadRequest:request];
//        return NO;
//    }
    return YES;
}

#pragma mark - scrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //下拉隐藏网页提供方 
    scrollView.contentOffset.y >= 0 ? (_supportLabel.hidden = YES) : (_supportLabel.hidden = NO);
}

//禁止webivew放大缩小
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return nil;
}

#pragma mark - 懒加载  Lazy Load
- (UIProgressView *)progressView{
    if (_progressView == nil) {
        UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
        progressView.tintColor = webRGBAColor(80, 140, 237, 1);
        progressView.trackTintColor = [UIColor clearColor];
        [self.view addSubview:progressView];
        self.progressView = progressView;
    }
    return _progressView;
}

- (UILabel *)supportLabel{
    if (_supportLabel == nil) {
        _supportLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.bounds.size.width - 2 * 50, 50)];
        //网页来源提示居中
        CGPoint center = _supportLabel.center;
        center.x = self.view.frame.size.width / 2;
        _supportLabel.center = center;
        
        _supportLabel.font = [UIFont systemFontOfSize:12];
        _supportLabel.textAlignment = NSTextAlignmentCenter;
        _supportLabel.textColor = [UIColor lightGrayColor];
        _supportLabel.numberOfLines = 0;
        [self.view sendSubviewToBack:_supportLabel];
        [self.view addSubview:_supportLabel];
    }
    return _supportLabel;
}

@end
