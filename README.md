# WBWebViewBrowser
内置浏览器，调用简单方便，欢迎使用～
# 功能介绍
 - 下拉可以显示当前网页的host，类似QQ、微信等内置浏览器效果
 - UIWebView、WKWebView的自由切换，默认用UIWebView
 - 设置请求头Token
 - 加载Html字符串
# API说明
```
/** token,如不传则不会设置请求头 */
@property (nonatomic,copy)                          NSString *token;
/** 加载网页地址 */
@property (nonatomic,copy)                          NSString *urlString;
/** 加载HTMLString */
@property (nonatomic,copy)                          NSString *HTMLString;
/** UIWebView:NO WKWebView:YES 默认UIWebView */
@property (nonatomic,assign,getter=isWKWebView)         BOOL  isWKWebView;
```
# 使用事例
```
- (IBAction)gotoBrowser:(id)sender {
    WBWebViewController *webVC = [[WBWebViewController alloc] init];
    webVC.urlString = @"http://weibo.com/535478908";
    webVC.isWKWebView = YES;
    [self.navigationController pushViewController:webVC animated:YES];
}

```
# 总结
- 我在写下拉网页由xxx提供遇到了困难，我的思路的是设置webView的背景为透明，在ViewController的view上添加label，在此遇到一个小bug，在某些网页透明处label也显示了，现在的处理是监听上移隐藏label，下拉不隐藏，这样就完美解决啦，其他的代码也比较简单，也有注释，就不解释啦～
- 如果在使用过程遇到问题，可以联系[小斌斌工作室](http://weibo.com/535478908)关注我哦，我会第一时间回复，一直更新～
