//
//  KWKClosableView.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 03/02/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KWKClosableViewDelegate <NSObject>

@required
- (void) closeButtonPressedFromView:(UIView*) closableView;

@end

@interface KWKClosableView : UIView

@property (nonatomic, readwrite) BOOL shouldDisplayCloseBtn;
@property (nonatomic, readwrite) CGFloat closeImgPadding;
@property (nonatomic, readwrite) CGSize closeImgSize;
@property (nonatomic, strong) NSString* closeImgURLString;

@property (nonatomic, weak) id<KWKClosableViewDelegate> delegate;

- (void) setCustomClosePosition:(NSString*) customClosePosition;

@end
