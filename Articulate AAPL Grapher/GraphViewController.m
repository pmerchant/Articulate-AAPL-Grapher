//
//  GraphViewController.m
//  Articulate AAPL Grapher
//
//  Created by Peter Merchant on 8/18/15.
//  Copyright (c) 2015 Peter Merchant. All rights reserved.
//

#import "GraphViewController.h"

#import "StockPrices.h"

@interface GraphViewController ()

@end

@implementation GraphViewController

- (GraphView*) graphView
{
	return (GraphView*) self.view;
}

- (void) setGraphView: (GraphView*) graphView
{
	self.view = (NSView*) graphView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	NSURL*			url = [[NSBundle mainBundle] URLForResource: @"stockprices" withExtension: @"json"];
	NSData*			jsonData = [NSData dataWithContentsOfURL: url];
	StockPrices*	prices = [[StockPrices alloc] initWithJSONData: jsonData];
	
	self.graphView.dataSource = prices;
	[self.graphView setNeedsDisplay: YES];
}

- (IBAction) showFontPanel: (id) sender
{
	NSFontPanel*	sharedPanel = [[NSFontManager sharedFontManager] fontPanel: YES];
	
	[[NSFontManager sharedFontManager] setSelectedFont: self.graphView.labelFont isMultiple: NO];
	
	[[NSFontManager sharedFontManager] setDelegate: self];
	[[NSFontManager sharedFontManager] setTarget: self];
	[[NSFontManager sharedFontManager] setAction: @selector(fontChanged:)];
	
	[sharedPanel makeKeyAndOrderFront: sender];
}

- (void) fontChanged: (id) sender
{
	NSFont*	newFont = [sender convertFont: [sender selectedFont]];
	
	if (! [newFont isEqualTo: self.graphView.labelFont])
	{
		self.graphView.labelFont = newFont;
		[self.graphView setNeedsDisplay: YES];
	}
}

- (NSUInteger) validModesForFontPanel: (NSFontPanel*) fontPanel
{
	return NSFontPanelFaceModeMask | NSFontPanelSizeModeMask;
}

- (void) changeAttributes: (id) sender
{
	NSDictionary* attrs = [sender convertAttributes: [self.graphView.labelDescriptor fontAttributes]];
	NSLog(@"orig attrs = %@, attrs = %@", [self.graphView.labelDescriptor fontAttributes], attrs);
	
	self.graphView.labelDescriptor = [NSFontDescriptor fontDescriptorWithFontAttributes: attrs];
	[self.graphView setNeedsDisplay: YES];
	return;
}
@end
