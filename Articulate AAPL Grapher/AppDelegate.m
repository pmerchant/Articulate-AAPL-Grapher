//
//  AppDelegate.m
//  Articulate AAPL Grapher
//
//  Created by Peter Merchant on 8/12/15.
//  Copyright (c) 2015 Peter Merchant. All rights reserved.
//

#import "AppDelegate.h"

#import "StockPrices.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
}


- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

@end
