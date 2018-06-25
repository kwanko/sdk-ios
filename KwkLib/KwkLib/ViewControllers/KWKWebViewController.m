//
//  KWKWebViewController.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 09/01/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKWebViewController.h"

#define KWK_OPEN_UITOOLBAR_HEIGHT 50.0f

@interface KWKWebViewController () <UIWebViewDelegate>
{
    UIWebView*  webView;
    UIToolbar*  toolBar;
    BOOL        isLoading;
}

@end

@implementation KWKWebViewController

- (void) setupUI
{
    if (webView == nil)
    {
        [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin];
        
        toolBar = [[UIToolbar alloc] init];
        [toolBar setFrame:CGRectMake(0, self.view.frame.size.height - KWK_OPEN_UITOOLBAR_HEIGHT, self.view.frame.size.width, KWK_OPEN_UITOOLBAR_HEIGHT)];
        [toolBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
        
        webView = [[UIWebView alloc] init];
        [webView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - toolBar.frame.size.height)];
        [webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        
        UIFont *systemFnt30 = [UIFont systemFontOfSize:30];
        UIFont *systemFntBold30 = [UIFont boldSystemFontOfSize:30];
        
        NSString *backArrowString = @"\U000025C0\U0000FE0E"; //◀
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [backBtn setFrame:CGRectMake(0, 0, toolBar.frame.size.height, toolBar.frame.size.height)];
        [backBtn setTitle:backArrowString forState:UIControlStateNormal];
        [backBtn.titleLabel setFont:systemFnt30];
        [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(doActionDone:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backBarBtnItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setFrame:CGRectMake(0, 0, toolBar.frame.size.height, toolBar.frame.size.height)];
        [closeBtn setTitle:@"X" forState:UIControlStateNormal];
        [closeBtn.titleLabel setFont:systemFntBold30];
        [closeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(doActionDone:) forControlEvents:UIControlEventTouchUpInside];

        UIBarButtonItem *closeBarBtnItem = [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        NSArray *toolBarItems = [NSArray arrayWithObjects:backBarBtnItem, flexibleSpace, closeBarBtnItem, nil];
        [toolBar setItems:toolBarItems];
        
        [self.view addSubview:webView];
        [self.view addSubview:toolBar];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupUI];
    
    if ([self urlToLoad])
    {
        NSURLRequest *requset = [NSURLRequest requestWithURL:[NSURL URLWithString:[self urlToLoad]]];
        [webView loadRequest:requset];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

#pragma mark -

- (void) close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Actions -

- (void) doActionDone:(id) sender
{
    [self close];
}

- (void) doActionGoBack:(id) sender
{
    if (webView.canGoBack)
    {
        [webView goBack];
    }
    else
    {
        [self close];
    }
}

@end
