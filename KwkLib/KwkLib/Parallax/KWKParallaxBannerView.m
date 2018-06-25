//
//  KWKParallaxBannerView.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 27/03/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKParallaxBannerView.h"
#import "KWKParallaxBannerView+Private.h"
#import "KWKBannerView.h"
#import "KWKAdProvider.h"
#import "KWKAdData.h"
#import "KWKGlobals.h"
#import "KWKAdRequest+Private.h"
#import "KWKWebViewController.h"


@interface KWKParallaxBannerView ()<UIWebViewDelegate>
{
    //if any of these change, slope and y intercept are recalculated
    CGFloat parentScrollViewHeight;
    CGFloat contentWebViewHeight;
    CGFloat selfHeight;
    
    //interpolation
    CGFloat m; //slope
    CGFloat b; //y-intercept
}


@property (nonatomic, strong) KWKParallaxBannerAdRequest* adRequest;
@property (nonatomic, strong) KWKAdData* adData;

@property (nonatomic, strong) UIWebView* webView;
@property (nonatomic, readwrite) BOOL isLoadingAd;

@end

@implementation KWKParallaxBannerView

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self setupAdWebView];
    
    [self setClipsToBounds:YES];
}

-(instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setupAdWebView];
        [self setClipsToBounds:YES];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self calculateSlopeAndIntercept];
}

- (void)setParentScrollView:(__weak UIScrollView *)parentScrollView
{
    if (_parentScrollView != parentScrollView)
    {
        [self unregisterFromParentFrameChange];
        [self unregisterFromParentContentOffsetChange];
        
        _parentScrollView = parentScrollView;
        
        [self registerForParentFrameChange];
        [self registerForParentContentOffsetChange];
    }
}

- (void) setupAdWebView
{
    if (self.webView)
    {
        return;
    }
    
    self.webView = [[UIWebView alloc] init];
    [self.webView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.webView setScalesPageToFit:YES];
    [self.webView setAutoresizingMask: UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth ];
    [self.webView setBackgroundColor:[UIColor clearColor]];
    
    [self addSubview:self.webView];
    [self.webView setDelegate:self];
    
    [self.webView setHidden:YES];
    [self.webView.scrollView setScrollEnabled:NO];
}

- (void)loadAdForRequest:(KWKParallaxBannerAdRequest *)adRequest
{
    if (self.parentScrollView)
    {
        adRequest.sizeStrategy = KWK_AD_SZ_STRATEGY_PIXELS;
        //adRequest.size = self.parentScrollView.frame.size;
    }
    
    if (self.isLoadingAd)
    {
        KWKLog(@"%s: already loading ad for view",__PRETTY_FUNCTION__);
        return;
    }
    
    self.isLoadingAd = YES;
    self.adRequest = adRequest;
    
    __weak __typeof__(self) weakself = self;
    KWKAdProvider* bannerAdProvider = [KWKAdProvider new];
    [bannerAdProvider loadAdForRequestWithRequest:adRequest completion:^(KWKAdData *adData, NSError *error)
     {
         weakself.isLoadingAd = NO;
         if (!error)
         {
             //set size of web view
             CGRect webViewFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
             
             if (!CGSizeEqualToSize(adData.contentSize, CGSizeZero))
             {
                 webViewFrame = CGRectMake((weakself.frame.size.width - adData.contentSize.width)/2.0f,
                                             0,
                                             adData.contentSize.width,
                                             adData.contentSize.height);
             }
             
             self.webView.frame = webViewFrame;
             self.webView.hidden = NO;
             
             
             //load data into web view.
             [weakself.webView loadHTMLString:adData.html baseURL:nil];
             
             
         }
         else
         {
             KWKLog(@"parralax banner for slot:%@ failed to load with error:%@", adRequest.slotID, error);
         }
     }];
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    if (self.window)
    {
        UIScrollView* scrollView = nil;
        UIView* superView = self.superview;
        
        do
        {
            if ([superView isKindOfClass:[UIScrollView class]]
                && ![superView.superview isKindOfClass:[UITableView class]])//TEMP!!
            {
                scrollView = (UIScrollView*) superView;
            }
            superView = superView.superview;
        }
        while (superView != nil && scrollView == nil);
        
        if (scrollView)
        {
            self.parentScrollView = scrollView;
        }
    }
    else
    {
        [self unregisterFromParentFrameChange];
        [self unregisterFromParentContentOffsetChange];
        _parentScrollView = nil;
    }
}

- (void) calculateSlopeAndIntercept
{
    CGRect selfFrameInParentSV = [self.superview convertRect:self.frame toView:self.parentScrollView];
    /*
     calculate new offset by interpolating
     newY = f(x) = a*x + b;
     
     B * a + b = -B; (top: banner is at B, output is -B;
     -S * a + b = I; (bottom: banner is at -S, output is I)
     
     from this a = - (I + B) / (B + S); b = I + S * a;
     */
    
    
    float S = self.parentScrollView.frame.size.height;
    float I = self.webView.frame.size.height;
    float B = selfFrameInParentSV.size.height;
    
    
    if (S != parentScrollViewHeight
        || I != contentWebViewHeight)
    {
        m = - (I + B) / (B + S);
        b = I + S * m;
        
        contentWebViewHeight = I;
        parentScrollViewHeight = S;
    }

}

- (void) parentDidScrol
{
    [self calculateWebviewScrollPosition];
}

- (void) calculateWebviewScrollPosition
{
    CGRect selfFrameInParentSV = [self.superview convertRect:self.frame toView:self.parentScrollView];
    [self calculateSlopeAndIntercept];
    
    float y = (self.parentScrollView.contentOffset.y - selfFrameInParentSV.origin.y);
    float newY = m * y + b;
    self.webView.scrollView.contentOffset = CGPointMake(self.webView.scrollView.contentOffset.x ,
                                                        newY);
}

- (void)removeFromSuperview
{
    [self unregisterFromParentFrameChange];
    [self unregisterFromParentContentOffsetChange];
    
    [super removeFromSuperview];
}

- (void)dealloc
{
    [self unregisterFromParentFrameChange];
}

#pragma mark monitor scrollview content offset change
static void * observeContext = &observeContext;

- (void) registerForParentContentOffsetChange
{
    if (_parentScrollView)
    {
        [_parentScrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionNew context:observeContext];
    }
}

- (void) unregisterFromParentContentOffsetChange
{
    if (_parentScrollView)
    {
         [_parentScrollView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) context:observeContext];
    }
}

#pragma mark monitor scrollview frame change -
- (void) registerForParentFrameChange
{
    if(_parentScrollView)
    {
        [_parentScrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(frame)) options:NSKeyValueObservingOptionNew context:observeContext];
    }
}


- (void) unregisterFromParentFrameChange
{
    if (_parentScrollView)
    {
        [_parentScrollView removeObserver:self forKeyPath:NSStringFromSelector(@selector(frame)) context:observeContext];
    }
}

#pragma KV Observer -

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == observeContext)
    {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(frame))])
        {
            [self calculateSlopeAndIntercept];
        }
        else if ([keyPath isEqualToString:NSStringFromSelector(@selector(contentOffset))])
        {
            [self parentDidScrol];
        }
    }
}



#pragma mark UIWebViewDelegate -

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        if (self.adData.urlOpenDestination == KWK_URL_OPEN_DESTINATION_UIWEBVIEV)
        {
            UIViewController* topMostViewController = [[UIApplication sharedApplication] topMostViewController];
            KWKWebViewController* openVC = [[KWKWebViewController alloc] init];
            openVC.urlToLoad = request.URL.absoluteString;
            
            [topMostViewController presentViewController:openVC animated:YES completion:nil];
            
            return NO;
        }
        else //assume safari for now
        {
            NSURL* url = request.URL;
            if ([[UIApplication sharedApplication] canOpenURL:url])
            {
                [[UIApplication sharedApplication] openURL:request.URL options:@{} completionHandler:nil];
                return NO;
            }
        }
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self calculateSlopeAndIntercept];
    [self calculateWebviewScrollPosition];
}


@end
