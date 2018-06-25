//
//  KWKClosableView.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 03/02/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKClosableView.h"
#import "KWKGlobals.h"

#define KWK_CLOSE_REGION_WIDTH      50.0f
#define KWK_CLOSE_REGION_HEIGHT     50.0f
#define KWK_CLOSE_IMG_PADDING       5.0f
#define KWK_CLOSE_IMG_DEFAULT_URL   @"https://img.metaffiliation.com/na/na/res/trk/sdkjs/images/close_grey_64.png"

#define KWK_CLOSE_POS_STRING_TOP_RIGHT      @"top-right"
#define KWK_CLOSE_POS_STRING_TOP_LEFT       @"top-left"
#define KWK_CLOSE_POS_STRING_TOP_CENTER     @"top-center"
#define KWK_CLOSE_POS_STRING_BOTTOM_RIGHT   @"bottom-right"
#define KWK_CLOSE_POS_STRING_BOTTOM_LEFT    @"bottom-left"
#define KWK_CLOSE_POS_STRING_BOTTOM_CENTER  @"bottom-center"
#define KWK_CLOSE_POS_STRING_CENTER         @"center"

typedef enum
{
    KWK_CLOSABLE_VIEW_CLOSE_POSITION_TOP_RIGHT = 0,
    KWK_CLOSABLE_VIEW_CLOSE_POSITION_TOP_LEFT,
    KWK_CLOSABLE_VIEW_CLOSE_POSITION_TOP_CENTER,
    KWK_CLOSABLE_VIEW_CLOSE_POSITION_BOTTOM_RIGHT,
    KWK_CLOSABLE_VIEW_CLOSE_POSITION_BOTTOM_LEFT,
    KWK_CLOSABLE_VIEW_CLOSE_POSITION_BOTTOM_CENTER,
    KWK_CLOSABLE_VIEW_CLOSE_POSITION_CENTER
}KWK_RESIZE_CLOSE_POSOTION;

KWK_RESIZE_CLOSE_POSOTION KWKClosePositionFromString(NSString* closePosition)
{
    static NSArray* closePosStringNames;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        closePosStringNames = [NSArray arrayWithObjects: KWK_CLOSE_POS_STRING_TOP_RIGHT,
                                                        KWK_CLOSE_POS_STRING_TOP_LEFT,
                                                        KWK_CLOSE_POS_STRING_TOP_CENTER,
                                                        KWK_CLOSE_POS_STRING_BOTTOM_RIGHT,
                                                        KWK_CLOSE_POS_STRING_BOTTOM_LEFT,
                                                        KWK_CLOSE_POS_STRING_BOTTOM_CENTER,
                                                        KWK_CLOSE_POS_STRING_CENTER, nil];
        
    });
    
    NSUInteger posInArray = [closePosStringNames indexOfObjectIdenticalTo:closePosition];
    if (posInArray != NSNotFound)
    {
        return (KWK_RESIZE_CLOSE_POSOTION) posInArray;
    }
    
    return KWK_CLOSABLE_VIEW_CLOSE_POSITION_TOP_RIGHT;
}

@interface KWKClosableView ()
{
    KWK_RESIZE_CLOSE_POSOTION closePosition;
}

@property (nonatomic, strong) UIButton* closeButton;
@property (nonatomic, strong) UIImageView* closeImageView;
@property (nonatomic, strong) NSURLSessionDownloadTask* downloadCloseImageTask;

@end

@implementation KWKClosableView

- (instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        closePosition = KWK_CLOSABLE_VIEW_CLOSE_POSITION_TOP_RIGHT;
        
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.closeButton setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.closeButton];
        
        self.closeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"KWKClose"]];
        [self addSubview:self.closeImageView];
     
        [self setNeedsLayout];
        
        self.shouldDisplayCloseBtn = NO;
        self.closeImgPadding = KWK_CLOSE_IMG_PADDING;
        [self downloadCloseIMG:nil];
        
        return self;
    }
    
    return nil;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.closeButton setFrame:[self getCloseBtnFrame]];
    [self bringSubviewToFront:self.closeButton];
    
    if (self.closeImageView)
    {
        CGRect imageFrame = [self getCloseImageFrame];
//        imageFrame.origin = CGPointMake(imageFrame.origin.x + self.closeImgPadding, imageFrame.origin.y + self.closeImgPadding);
//        imageFrame.size = CGSizeMake(imageFrame.size.width - (2*self.closeImgPadding), imageFrame.size.height - (2*self.closeImgPadding));
        [self.closeImageView setFrame:imageFrame];
        [self.closeImageView setLayoutMargins:UIEdgeInsetsMake(self.closeImgPadding, self.closeImgPadding, self.closeImgPadding, self.closeImgPadding)];
        
        [self bringSubviewToFront:self.closeImageView];
    }
}

#pragma mark -

- (CGRect) getCloseBtnFrame
{
    CGRect closeBtnFrame = CGRectMake(0, 0, KWK_CLOSE_REGION_WIDTH, KWK_CLOSE_REGION_HEIGHT);
    switch (closePosition)
    {
        case KWK_CLOSABLE_VIEW_CLOSE_POSITION_TOP_RIGHT:
            closeBtnFrame.origin = CGPointMake(self.frame.size.width - KWK_CLOSE_REGION_WIDTH, 0);
            break;
        case KWK_CLOSABLE_VIEW_CLOSE_POSITION_TOP_LEFT:
            closeBtnFrame.origin = CGPointMake(0, 0);
            break;
        case KWK_CLOSABLE_VIEW_CLOSE_POSITION_TOP_CENTER:
            closeBtnFrame.origin = CGPointMake((self.frame.size.width - KWK_CLOSE_REGION_WIDTH)/2, 0);
            break;
        case KWK_CLOSABLE_VIEW_CLOSE_POSITION_BOTTOM_RIGHT:
            closeBtnFrame.origin = CGPointMake(self.frame.size.width - KWK_CLOSE_REGION_WIDTH, self.frame.size.height - KWK_CLOSE_REGION_HEIGHT);
            break;
        case KWK_CLOSABLE_VIEW_CLOSE_POSITION_BOTTOM_LEFT:
            closeBtnFrame.origin = CGPointMake(0, self.frame.size.height - KWK_CLOSE_REGION_HEIGHT);
            break;
        case KWK_CLOSABLE_VIEW_CLOSE_POSITION_BOTTOM_CENTER:
            closeBtnFrame.origin = CGPointMake((self.frame.size.width - KWK_CLOSE_REGION_WIDTH)/2, self.frame.size.height - KWK_CLOSE_REGION_HEIGHT);
            break;
        case KWK_CLOSABLE_VIEW_CLOSE_POSITION_CENTER:
            closeBtnFrame.origin = CGPointMake((self.frame.size.width - KWK_CLOSE_REGION_WIDTH)/2, (self.frame.size.height - KWK_CLOSE_REGION_HEIGHT)/2);
            break;
            
        default:
            break;
    }
    
    return closeBtnFrame;
};

- (CGRect) getCloseImageFrame
{
    CGSize closeImgSize = CGSizeMake(self.closeImgSize.width + self.closeImgPadding, self.closeImgSize.height + self.closeImgPadding);//self.closeImgSize;
    if (CGSizeEqualToSize(self.closeImgSize, CGSizeZero))
    {
        closeImgSize = CGSizeMake(KWK_CLOSE_REGION_WIDTH, KWK_CLOSE_REGION_HEIGHT);
    }
    
    CGRect closeBtnFrame = CGRectMake(0, 0, closeImgSize.width, closeImgSize.height);
    switch (closePosition)
    {
        case KWK_CLOSABLE_VIEW_CLOSE_POSITION_TOP_RIGHT:
            closeBtnFrame.origin = CGPointMake(self.frame.size.width - closeImgSize.width, 0);
            break;
        case KWK_CLOSABLE_VIEW_CLOSE_POSITION_TOP_LEFT:
            closeBtnFrame.origin = CGPointMake(0, 0);
            break;
        case KWK_CLOSABLE_VIEW_CLOSE_POSITION_TOP_CENTER:
            closeBtnFrame.origin = CGPointMake((self.frame.size.width - closeImgSize.width)/2, 0);
            break;
        case KWK_CLOSABLE_VIEW_CLOSE_POSITION_BOTTOM_RIGHT:
            closeBtnFrame.origin = CGPointMake(self.frame.size.width - closeImgSize.width, self.frame.size.height - closeImgSize.height);
            break;
        case KWK_CLOSABLE_VIEW_CLOSE_POSITION_BOTTOM_LEFT:
            closeBtnFrame.origin = CGPointMake(0, self.frame.size.height - closeImgSize.height);
            break;
        case KWK_CLOSABLE_VIEW_CLOSE_POSITION_BOTTOM_CENTER:
            closeBtnFrame.origin = CGPointMake((self.frame.size.width - closeImgSize.width)/2, self.frame.size.height - closeImgSize.height);
            break;
        case KWK_CLOSABLE_VIEW_CLOSE_POSITION_CENTER:
            closeBtnFrame.origin = CGPointMake((self.frame.size.width - closeImgSize.width)/2, (self.frame.size.height - closeImgSize.height)/2);
            break;
            
        default:
            break;
    }
    
    return closeBtnFrame;
};



-  (void)setShouldDisplayCloseBtn:(BOOL)shouldDisplayCloseBtn
{
    _shouldDisplayCloseBtn = shouldDisplayCloseBtn;
    [self.closeImageView setHidden:!shouldDisplayCloseBtn];
}

- (void) setCustomClosePosition:(NSString*) customClosePosition
{
    closePosition = KWKClosePositionFromString(customClosePosition);
}

- (void)setCloseImgPadding:(CGFloat)closeImgPadding
{
    _closeImgPadding = closeImgPadding;
    [self setNeedsLayout];
}

- (void) setCloseImgURLString:(NSString *)closeImgURLString
{
    _closeImgURLString = closeImgURLString;
    [self downloadCloseIMG:closeImgURLString];
}

- (void) setCloseImgSize:(CGSize)closeImgSize
{
    _closeImgSize = closeImgSize;
    [self setNeedsLayout];
}

#pragma mark -

- (void) closeButtonPressed:(id) sender
{
    if (_delegate)
    {
        [_delegate closeButtonPressedFromView:self];
    }
}


#pragma mark - TODO. Move this into a download service
//not movin no as separate service. we will implement a chaching sis for this. and i need server side code to be done

- (void) downloadCloseIMG:(NSString*) urlString
{
    if (nil == urlString)
    {
        urlString = KWK_CLOSE_IMG_DEFAULT_URL;
    }

    NSURL* closeImgURL = [NSURL URLWithString:urlString];
    if (![[UIApplication sharedApplication] canOpenURL:closeImgURL])
    {
        KWKLog(@"%s Close Image cannot be downloaded from: %@", __PRETTY_FUNCTION__, urlString);
        return;
    }
    
    if (self.downloadCloseImageTask)
    {
        [self.downloadCloseImageTask cancel];
        self.downloadCloseImageTask = nil;
    }
    
    __weak __typeof__(self) weakSelf = self;
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];
    self.downloadCloseImageTask = [session downloadTaskWithURL: closeImgURL
                                             completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error)
                                   {
                                       if (!error)
                                       {
                                           NSData * imgData = [NSData dataWithContentsOfURL:location];
                                           if (imgData)
                                           {
                                               KWKLog(@"%s: Image from %@ downloaded succesfully.", __FUNCTION__, closeImgURL.absoluteURL);
                                               
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   [weakSelf.closeImageView setImage:[UIImage imageWithData:imgData]];
                                                   [weakSelf setNeedsLayout];
                                               });
                                           }
                                           else
                                           {
                                               KWKLog(@"%s: failed to download. Invalid data.", __PRETTY_FUNCTION__);
                                           }
                                       }
                                       else
                                       {
                                           KWKLog(@"%s: failed to download. Err: %@", __PRETTY_FUNCTION__, error);
                                       }
                                   }];
    [self.downloadCloseImageTask resume];
}


@end
