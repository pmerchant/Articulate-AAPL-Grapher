//
//  AppDelegate.h
//  Articulate AAPL Grapher
//
//  Created by Peter Merchant on 8/12/15.
//  Copyright (c) 2015 Peter Merchant. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "GraphViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
}

@property (readwrite, strong) IBOutlet GraphViewController* graphViewController;

@end

