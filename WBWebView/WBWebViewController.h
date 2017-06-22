//
//  WBWebViewController.h
//  封装webView
//
//  Created by 吴斌 on 2017/6/3.
//  Copyright © 2017年 吴斌. All rights reserved.
//
/**                 **********************************
 *                          如有疑问欢迎交流学习          
 *                  新浪微博:http://weibo.com/535478908  
 *                  github:https://github.com/wubin123 
 *                  **********************************
 */

#import <UIKit/UIKit.h>

@interface WBWebViewController : UIViewController

/** token,如不传则不会设置请求头 */
@property (nonatomic,copy)                          NSString *token;
/** 加载网页地址 */
@property (nonatomic,copy)                          NSString *urlString;
/** 加载HTMLString */
@property (nonatomic,copy)                          NSString *HTMLString;
/** UIWebView:NO WKWebView:YES 默认UIWebView */
@property (nonatomic,assign,getter=isWKWebView)         BOOL  isWKWebView;

@end
