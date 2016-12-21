//
//  ViewController.m
//  OCBridgeJS
//
//  Created by ydz on 16/8/17.
//  Copyright © 2016年 jonie. All rights reserved.
//

#import "ViewController.h"
#import  <WebKit/WebKit.h>
@interface ViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>
{
    WKUserContentController * userContentController;
}
@property(nonatomic,strong) WKWebView * wkwebView;
@property(nonatomic,strong) UIProgressView * progressView;
@end

#define screenWidth [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc]init];
    //注册供js调用的方法
    userContentController =[[WKUserContentController alloc]init];
    [userContentController addScriptMessageHandler:self  name:@"LocationModel"];
    [userContentController addScriptMessageHandler:self name:@"AppModel"];
    configuration.userContentController = userContentController;
    configuration.preferences.javaScriptEnabled = YES;
    _wkwebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0.0f, screenWidth, screenHeight) configuration:configuration];
    _wkwebView.backgroundColor = [UIColor clearColor];
    _wkwebView.UIDelegate = self;
    _wkwebView.navigationDelegate = self;
    _wkwebView.allowsBackForwardNavigationGestures =YES;//打开网页间的 滑动返回
    _wkwebView.allowsLinkPreview = YES;//允许预览链接
    NSString* path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
    NSURL* url = [NSURL fileURLWithPath:path];
    NSURLRequest* request = [NSURLRequest requestWithURL:url] ;
    //    NSString *path=[[NSBundle mainBundle]pathForResource:@"test" ofType:@"html"];
    [_wkwebView loadRequest:request];
    
    [self.view addSubview:_wkwebView];
    
    [self initProgressView];
    
    [_wkwebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];//注册observer 拿到加载进度
}
-(void)initProgressView
{
    _progressView =[[UIProgressView alloc]initWithFrame:CGRectMake(0,64.0f, screenWidth, 10.0f)];
    _progressView.tintColor = [UIColor blueColor];
    _progressView.trackTintColor = [UIColor whiteColor];
    [self.view addSubview:_progressView];
}
// observe get 进度条
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if([keyPath isEqualToString:@"estimatedProgress"])
    {
        _progressView.hidden = NO;
        CGFloat  progress = [ change[@"new"] floatValue];
        [_progressView setProgress:progress];
        if(progress==1.0)
        {
            _progressView.hidden =YES;
        }
    }
    
}
-(void)dealloc
{
    
    [_wkwebView removeObserver:self forKeyPath:@"estimatedProgress"];
    NSLog(@"wkwebview dealloc");
}
-(void)viewDidDisappear:(BOOL)animated
{
    [userContentController removeScriptMessageHandlerForName:@"LocationModel"];
    [userContentController removeScriptMessageHandlerForName:@"AppModel"];
    [super viewDidDisappear:animated];
}
//MARK:wkwebviewDelegate

//发送请求前 决定是否允许跳转
/*
 typedef NS_ENUM(NSInteger, WKNavigationActionPolicy) {
 WKNavigationActionPolicyCancel,不允许
 WKNavigationActionPolicyAllow, 允许
 } NS_ENUM_AVAILABLE(10_10, 8_0);
 */

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    decisionHandler(WKNavigationActionPolicyAllow);
}
//接收到服务器响应 后决定是否允许跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler;
{
    decisionHandler(WKNavigationResponsePolicyAllow);
    
}
//接收到服务器跳转响应后 调用
-(void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"tiaozhuan");
    
}

//开始加载页面
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation;
{
}
//加载页面数据完成
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    //    NSLog(@"加载页面完成");
    //    NSLog(@"backlist ===%@",webView.backForwardList.backList);
    //    NSLog(@"forwordlst==%@",webView.backForwardList.forwardList);
    //    NSLog(@"url===%@",webView.backForwardList.currentItem.URL);
    
    //加载完成后 设置导航栏相关
    if(webView.backForwardList.backList.count !=0)
        [self setNavBarhaveCloseBtn:YES reloadBtn:YES];
    else
        [self setNavBarhaveCloseBtn:NO reloadBtn:NO];
}
//接收数据
-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    
}

//加载失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error;
{
    
}
//关闭webView
-(void)webViewDidClose:(WKWebView *)webView
{
    
}
//实现注册的供js调用的oc方法

-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if(message.name ==nil || [message.name isEqualToString:@""])
        return;
    //message body : js 传过来值
    NSLog(@"message.body ==%@",message.body);
    //message.name  js发送的方法名称
    if ([message.name isEqualToString:@"AppModel"]) {
        NSString *body=[message.body objectForKey:@"body"];
        if ([body isEqualToString:@"客户端调用JS成功"]) {
#warning 调用JS方法
            [self.wkwebView evaluateJavaScript:@"getIndexArea('hahaha')" completionHandler:nil];
        }
    }
    if ([message.name isEqualToString:@"ChatModel"]) {
        //        NSString *body=[message.body objectForKey:@""];
    }
    
    
}
//MARK:webview 导航栏操作相关

-(void)setNavBarhaveCloseBtn:(BOOL)have reloadBtn:(BOOL)reload
{
    //    UIBarButtonItem * item0 =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRedo target:self action:@selector(goback)];
    UIBarButtonItem *item0=[[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(goback)];
    
    //    UIBarButtonItem * item =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(closeWeb)];
    //    UIBarButtonItem *item=[[UIBarButtonItem alloc]initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(closeWeb)];
    
    
    //    UIBarButtonItem * item1 =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(relaodWeb)];
    UIBarButtonItem *item1=[[UIBarButtonItem alloc]initWithTitle:@"刷新" style:UIBarButtonItemStyleDone target:self action:@selector(relaodWeb)];
    
    NSMutableArray * items =[NSMutableArray array];
    if(have && reload)
    {
        [items addObject:item0];
        //        [items addObject:item];
        [items addObject:item1];
    }
    else if (have)
    {
        [items addObject:item0];
        //        [items addObject:item];
    }
    else if (reload)
        [items addObject:item1];
    
    self.navigationItem.leftBarButtonItems=items;
}
-(void)closeWeb
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)relaodWeb
{
    [_wkwebView reload];
}
-(void)goback
{
    [_wkwebView goBack];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
