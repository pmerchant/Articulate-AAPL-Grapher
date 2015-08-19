//
//  GraphViewController.h
//  Articulate AAPL Grapher
//
//  Created by Peter Merchant on 8/18/15.
//  Copyright (c) 2015 Peter Merchant. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "GraphView.h"

@interface GraphViewController : NSViewController

@property (nonatomic, weak) GraphView* graphView;

@end
