//
//  KwkOverlayViewController.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 14/02/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KwkOverlayViewController.h"
#import "KWKMraidAdView.h"

@interface KwkOverlayViewController () <KWKAdBaseViewDelegate>
{
    BOOL isAdViewSetup;
    BOOL isTimeBeforeOverlaySetup;
}


@end

@implementation KwkOverlayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.view setClipsToBounds:NO];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view.superview bringSubviewToFront:self.view];
    
    int x = 0;
    int y = 0;
    int width = self.view.frame.size.width;
    int height = self.view.frame.size.height;

    if (!CGSizeEqualToSize(self.adData.contentSize, CGSizeZero))
    {
        if (self.adData.sizeStrategy == KWK_AD_SZ_STRATEGY_RATIO)
        {
            if (self.adData.contentSize.width != 0) //no sense in treating the case where one of the size attribs is 0. THis check is here to avoid crashes. 0 should never come in a response!!
            {
                float aspectRatio = self.adData.contentSize.height / self.adData.contentSize.width;
                if (aspectRatio < 1) 
                {
                    width = height / aspectRatio;
                    if (width > self.view.frame.size.width)
                    {
                        float factor = self.view.frame.size.width / width;
                        width *= factor;
                        height *= factor;
                    }
                }
                else
                {
                    height = width * aspectRatio;
                    if (height > self.view.frame.size.height)
                    {
                        float factor = self.view.frame.size.height / height;
                        width *= factor;
                        height *= factor;
                    }
                }
            }
        }
        else if (self.adData.sizeStrategy == KWK_AD_SZ_STRATEGY_PIXELS)
        {
            width = self.adData.contentSize.width;
            height = self.adData.contentSize.height;
        }
    }


    x = (self.view.frame.size.width - width)/2;
    if (self.adRequest.adPosition == KWK_AD_POSITION_TOP)
    {
        y = 0;
        self.view.autoresizingMask |= UIViewAutoresizingFlexibleTopMargin;
    }
    else if (self.adRequest.adPosition == KWK_AD_POSITION_BOTTOM)
    {
        y = self.view.frame.size.height - height;
        self.view.autoresizingMask |= UIViewAutoresizingFlexibleBottomMargin;
    }
    else
    {
        y = (self.view.frame.size.height - height)/2;
        self.view.autoresizingMask |= UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    }
    
    self.view.frame = CGRectMake(x, y, width, height);
  
    
    KWKMraidAdView * adview = [[KWKMraidAdView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) andData:self.adData];
    [self.view addSubview:adview];
    adview.adDelegate = self;
    
    self.adView = adview;
    
    self.adView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.adView];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (!isTimeBeforeOverlaySetup)
    {

        if (self.adData.overlayCountdown)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.adData.overlayCountdown * NSEC_PER_SEC),
                           dispatch_get_main_queue(),
                           ^{
                               UIViewController *rootVC = [[self delegate] rootViewController];
                               UIViewController *presentedVC = [rootVC presentedViewController];
                               
                               if (presentedVC)
                               {
                                   while ([presentedVC presentingViewController]!= rootVC)
                                   {
                                       [rootVC dismissViewControllerAnimated:NO completion:nil];
                                   }
                                   
                                   [rootVC dismissViewControllerAnimated:NO completion:nil];
                               }
                               
                               [self.adView destroyAd]; 
                           });
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) close
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
    if ([self.delegate respondsToSelector:@selector(didCloseOverlayViewController)])
    {
        [self.delegate didCloseOverlayViewController];
    }
}

#pragma mark KWKAdBaseViewDelegate -
- (KWKAdContainerType)containerType
{
    return KWK_AD_CONTAINER_TYPE_INTERSTITIAL;
}

- (void) containerDidClose
{
    [self close];
}

@end
