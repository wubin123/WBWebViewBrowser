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
