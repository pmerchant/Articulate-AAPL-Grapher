//
//  GraphView.h
//  Articulate AAPL Grapher
//
//  Created by Peter Merchant on 8/12/15.
//  Copyright (c) 2015 Peter Merchant. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <QuartzCore/CAShapeLayer.h>

#import "GraphDataSourceProtocol.h"

@interface GraphView : NSView 
{
@protected
	CAShapeLayer*			_graphLayer;
	NSView*					_graphDataView;
	NSRect					_xAxisRect;
	NSRect					_yAxisRect;
	NSMutableDictionary*	_labelAttributes;
    NSMutableArray*			_xAxisOffsets;
}

@property (nonatomic, readwrite, strong, setter=setDataSource:) id <GraphDataSourceProtocol>	dataSource;
@property (nonatomic, readwrite, assign)	int	minValue;
@property (nonatomic, readwrite, assign)	int	maxValue;
@property (nonatomic, readwrite, strong, setter=setValueColor:)	NSColor* valueColor;
@property (nonatomic, readwrite, assign, setter=setValueAlpha:) double valueAlpha;
@property (nonatomic, readwrite, weak) NSFont* labelFont;
@property (nonatomic, readwrite, weak) NSFontDescriptor* labelDescriptor;

- (void) awakeFromNib;

- (NSFont*) labelFont;
- (void) setLabelFont: (NSFont*) labelFont;

- (void) drawRect: (NSRect) dirtyRect;

@end
