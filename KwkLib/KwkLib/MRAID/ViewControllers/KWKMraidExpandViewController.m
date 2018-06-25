//
//  KWKMraidExpandViewController.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 13/01/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKMraidExpandViewController.h"
#import "KWKClosableView.h"

@interface KWKMraidExpandViewController ()

@end

@implementation KWKMraidExpandViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor clearColor]];
}


- (void)setOrientationProperties:(KWKJSOrientaionProprety *)orientationProperties
{
    _orientationProperties = orientationProperties;
}

#pragma mark -

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (![[[self orientationProperties] forceOrientationString] isEqualToString:kMraidExpandInterfaceOrientatonNone])
    {
        return [[self orientationProperties] forcedInterfaceOrientationMask];
    }
    
    return [super supportedInterfaceOrientations];
}

#pragma mark -

- (void) close
{
    if ([self closeBlock])
    {
        [self closeBlock]();
    }
}



@end
