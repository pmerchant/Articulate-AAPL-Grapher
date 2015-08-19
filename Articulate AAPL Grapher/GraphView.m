//
//  GraphView.m
//  Articulate AAPL Grapher
//
//  Created by Peter Merchant on 8/12/15.
//  Copyright (c) 2015 Peter Merchant. All rights reserved.
//

#import "GraphView.h"

#import <QuartzCore/CAAnimation.h>

#import "GraphValueLayer.h"

@interface GraphView ()

- (NSRect) calculateGraphRect;
- (CGPoint) graphPointForDataValue: (double) value atIndex: (int) index;
- (CGPathRef) graphPathForDataValue: (double) value atIndex: (int) index;

- (void) setMinMaxFromValues;

- (NSRect) calculateYAxisRect;
- (void) drawYAxis;

- (NSRect) calculateRectForLabel: (NSString*) label atIndex: (NSUInteger) index;
- (NSRect) calculateXAxisRect;
- (double) calculateXAxisOffsetForIndex: (NSUInteger) index;
- (void) drawXAxis;

- (void) refreshValues;
- (void) resizeValues: (CGRect) newRect;
@end

@implementation GraphView

@synthesize dataSource;

- (void) awakeFromNib
{
    _xAxisOffsets = NULL;
	
	self.valueColor = [NSColor greenColor];
	self.valueAlpha = 1.0;
	self.labelFont = [NSFont labelFontOfSize: 14];
	
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(viewDidResize:) name: NSViewFrameDidChangeNotification object: self];
}

- (void) setDataSource: (id<GraphDataSourceProtocol>) newSource
{
	NSRect	graphRect;
	int		index;
	
	dataSource = newSource;

	[self setMinMaxFromValues];
	
	if (_graphDataView)
		[_graphDataView removeFromSuperviewWithoutNeedingDisplay];
	_graphDataView = NULL;
	
	[self resetGraphView];
	
	_graphDataView = [[NSView alloc] initWithFrame: [self calculateGraphRect]];
	[self addSubview: _graphDataView];
	
	graphRect = [self calculateGraphRect];
	
	_graphDataView.layer = [CALayer layer];
    _graphDataView.layer.frame = graphRect;
    _graphDataView.layer.name = @"Line Layer";
    _graphDataView.layer.delegate = self;
	
	double	defaultValue = (_minValue + _maxValue) / 2.0;
	
	for (index = 0; index < [dataSource count]; index++)
	{
		GraphValueLayer*	eachLayer = [GraphValueLayer layer];
		
		eachLayer.frame = NSMakeRect(0, 0, graphRect.size.width, graphRect.size.height);
		eachLayer.name = [NSString stringWithFormat: @"Data #%d Layer", index];
		eachLayer.delegate = self;
		eachLayer.dataIndex = index;
		eachLayer.value = [dataSource yAxisValueAtIndex: index];

		[_graphDataView.layer addSublayer: eachLayer];
		[eachLayer setNeedsDisplay];

        CABasicAnimation*	animation = [CABasicAnimation animationWithKeyPath: @"value"];
    
        animation.fromValue = [NSNumber numberWithDouble: defaultValue];
        animation.duration = 5;
        animation.delegate = self;
		animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
        
        [eachLayer addAnimation: animation forKey: @"value"];
    }
	
	_graphDataView.wantsLayer = YES;
	[_graphDataView.layer setNeedsDisplay];
}

- (void) setValueColor: (NSColor*) newValueColor
{
	_valueColor = newValueColor;
	[self refreshValues];
}

- (void) setValueAlpha: (double) newValueAlpha
{
	_valueAlpha = newValueAlpha;
	[self refreshValues];
}

- (NSFont*) labelFont
{
	return [_labelAttributes objectForKey: NSFontAttributeName];
}

- (void) setLabelFont: (NSFont*) newFont
{
	if (! _labelAttributes)
		_labelAttributes = [NSMutableDictionary dictionary];
	
	[self willChangeValueForKey: @"labelFont"];
	[_labelAttributes setObject: newFont forKey: NSFontAttributeName];
	[self didChangeValueForKey: @"labelFont"];
	
	[self resetGraphView];
}

- (NSFontDescriptor*) labelDescriptor
{
	return [NSFontDescriptor fontDescriptorWithFontAttributes: _labelAttributes];
}

- (void) setLabelDescriptor: (NSFontDescriptor*) labelDescriptor
{
	_labelAttributes = [[labelDescriptor fontAttributes] mutableCopy];
	
	[self resetGraphView];
}

- (void)drawRect: (NSRect) dirtyRect
{
	[super drawRect: dirtyRect];

	if (dataSource)
	{
		[self drawXAxis];
		[self drawYAxis];
	}
}

- (void) viewDidResize: (NSNotification*) note
{
	[self resetGraphView];
}

#pragma mark -

- (void) resetGraphView
{
	_xAxisRect = [self calculateXAxisRect];
	_yAxisRect = [self calculateYAxisRect];
	
	// Because the start of the X-Axis is based on the width of the Y axis (whose start is based on the height of the
	// X-Axis), it's easier to just recompute the X-Axis after calculating the Y.
	_xAxisRect = [self calculateXAxisRect];
	
	if (_graphDataView)
	{
		NSRect	graphRect = [self calculateGraphRect];
		
		[_graphDataView setFrame: graphRect];
		
		CGRect	layerFrameRect = NSRectToCGRect(NSMakeRect(0, 0, graphRect.size.width, graphRect.size.height));
		
		_graphDataView.layer.frame = layerFrameRect;
		[self resizeValues: layerFrameRect];
		[self refreshValues];
	}

	_xAxisOffsets = [NSMutableArray array];
	for (int index = 0; index < [dataSource count]; index++)
		[_xAxisOffsets addObject: [NSNumber numberWithDouble: [self calculateXAxisOffsetForIndex: index]]];

}

- (NSRect) calculateGraphRect
{
	NSRect	graphRect;
	
	graphRect = NSMakeRect(_yAxisRect.size.width, _xAxisRect.size.height, self.bounds.size.width - _yAxisRect.size.width, self.bounds.size.height - _xAxisRect.size.height);
	
	return graphRect;
}

- (CGPoint) graphPointForDataValue: (double) value atIndex: (int) index
{
    double		offset = _yAxisRect.size.height / (_maxValue - _minValue);
    CGPoint		valuePoint;
    
    valuePoint.x = [_xAxisOffsets[index] doubleValue];
    valuePoint.y = offset * (value - _minValue);

    return valuePoint;
}

- (CGPathRef) graphPathForDataValue: (double) value atIndex: (int) index
{
    CGPoint		valuePoint = [self graphPointForDataValue: value atIndex: index];
		
	CGMutablePathRef	dataPath = CGPathCreateMutable();
	
	CGPathMoveToPoint(dataPath, NULL, valuePoint.x, valuePoint.y);
	CGPathAddEllipseInRect(dataPath, NULL, CGRectMake(valuePoint.x - 5, valuePoint.y - 5, 10, 10));
	CGPathMoveToPoint(dataPath, NULL, valuePoint.x, valuePoint.y);
	
	return dataPath;
}

- (void) setMinMaxFromValues
{
	int		index;
	double	firstValue = [dataSource yAxisValueAtIndex: 0];
	
	_minValue = floor(firstValue);
	_maxValue = ceil(firstValue);

	for (index = 1; index < [dataSource count]; index++)
	{
		double	eachValue = [dataSource yAxisValueAtIndex: index];
		
		if (_minValue > eachValue)
			_minValue = floor(eachValue);
		if (_maxValue < eachValue)
			_maxValue = ceil(eachValue);
	}
}

- (NSRect) calculateYAxisRect
{
	NSRect	yAxisRect;
	int		yValue;
	
	yAxisRect = NSMakeRect(0, _xAxisRect.size.height, 2, self.bounds.size.height - _xAxisRect.size.height);
	
	for (yValue = _minValue + 1; yValue < _maxValue; yValue++)
	{
		NSString*	yLabel = [NSString stringWithFormat: @"%d", yValue];
		NSSize		yLabelSize = [yLabel sizeWithAttributes: _labelAttributes];
		
		if (yLabelSize.width + 2 > yAxisRect.size.width)
			yAxisRect.size.width = yLabelSize.width + 2;
	}
	
	return yAxisRect;
}

- (void) drawYAxis
{
	NSBezierPath*	yAxisLine = [NSBezierPath bezierPath];
	int				eachYValue;
	double			offset = _yAxisRect.size.height / (_maxValue - _minValue);
	NSRect			previousLabelRect = NSZeroRect;
	
	for (eachYValue = _minValue + 1; eachYValue < _maxValue; eachYValue++)
	{
		NSString*	eachLabel = [NSString stringWithFormat: @"%d", eachYValue];
		NSSize		eachLabelSize = [eachLabel sizeWithAttributes: _labelAttributes];
		NSRect		eachLabelRect = NSMakeRect(_yAxisRect.size.width - eachLabelSize.width, ((eachYValue - _minValue) * offset) + _yAxisRect.origin.y, eachLabelSize.width, eachLabelSize.height);
		
		eachLabelRect = NSOffsetRect(eachLabelRect, -2, -(eachLabelSize.height / 2));
		
		if (! NSIntersectsRect(previousLabelRect, eachLabelRect))	// Don't draw on top of other labels
		{
			[eachLabel drawInRect: eachLabelRect withAttributes: _labelAttributes];
			previousLabelRect = eachLabelRect;
		}
		
		NSBezierPath*	eachLine = [NSBezierPath bezierPath];
		
		[eachLine moveToPoint: NSMakePoint(_yAxisRect.size.width, ((eachYValue - _minValue) * offset) + _yAxisRect.origin.y)];
		[eachLine lineToPoint: NSMakePoint(_xAxisRect.size.width, ((eachYValue - _minValue) * offset) + _yAxisRect.origin.y)];
		
		[[NSColor grayColor] set];
		[eachLine stroke];
	}
	
	[yAxisLine setLineWidth: 2.0];
	[yAxisLine moveToPoint: NSMakePoint(_yAxisRect.origin.x + _yAxisRect.size.width, _yAxisRect.origin.y)];
	[yAxisLine lineToPoint: NSMakePoint(_yAxisRect.origin.x + _yAxisRect.size.width, _yAxisRect.origin.y + _yAxisRect.size.height)];
	[yAxisLine stroke];

}

- (NSRect) calculateRectForLabel: (NSString*) label atIndex: (NSUInteger) index
{
	NSSize		labelSize = [label sizeWithAttributes: _labelAttributes];
	int			labelOffset = _xAxisRect.size.width  / ([dataSource count] - 1);	// first label is at 0,0
	NSRect		labelRect;
	
	if (index == 0)
		labelRect.origin.x = _xAxisRect.origin.x;
	else if (index == [dataSource count]-1)
		labelRect.origin.x = self.bounds.size.width - labelSize.width;
	else
		labelRect.origin.x = (labelOffset * index) - (0.5 * labelSize.width);
	
	labelRect.origin.y = 0;
	labelRect.size = labelSize;
	
	return labelRect;
}

- (NSRect) calculateXAxisRect
{
	NSString*	label = [dataSource xAxisLabelAtIndex: [dataSource count] - 1];
	NSSize		labelSize = [label sizeWithAttributes: _labelAttributes];
	NSRect		xAxisRect;
	
	xAxisRect = NSMakeRect(_yAxisRect.size.width, 0, self.bounds.size.width - (0.5 * labelSize.width), labelSize.height);
	
	label = [dataSource xAxisLabelAtIndex: 0];
	labelSize = [label sizeWithAttributes: _labelAttributes];
	
	xAxisRect.origin.x -= labelSize.width * 0.5;
	xAxisRect.size.width += labelSize.width * 0.5;
	xAxisRect.size.height += 2;
	
	return xAxisRect;
}

- (double) calculateXAxisOffsetForIndex: (NSUInteger) index
{
	NSRect labelRect = [self calculateRectForLabel: [dataSource xAxisLabelAtIndex: index] atIndex: index];
	
	return labelRect.origin.x + (labelRect.size.width / 2) - _yAxisRect.size.width;
}

- (void) drawXAxis
{
	NSUInteger	count = [dataSource count];
	NSUInteger	index;
	NSRect		previousRect = NSZeroRect;
	
	for (index = 0; index < count; index++)
	{
		NSString*	eachLabel = [dataSource xAxisLabelAtIndex: index];
		NSRect		eachLabelRect = [self calculateRectForLabel: eachLabel atIndex: index];
		
		if (! NSIntersectsRect(previousRect, eachLabelRect))	// Make sure that the labels don't draw on top of each other
		{
			[eachLabel drawInRect: eachLabelRect withAttributes: _labelAttributes];
			previousRect = eachLabelRect;
		}
	}
	
	NSBezierPath*	xAxisLine = [NSBezierPath bezierPath];
	
	[xAxisLine setLineWidth: 2.0];
	[[NSColor blackColor] setStroke];
	[xAxisLine moveToPoint: NSMakePoint(_yAxisRect.size.width, _xAxisRect.size.height)];
	[xAxisLine lineToPoint: NSMakePoint(_yAxisRect.size.width + _xAxisRect.size.width, _xAxisRect.size.height)];
	[xAxisLine stroke];
}

#pragma mark - CALayerDelegate methods

- (void) drawLayer: (CALayer*) layer inContext: (CGContextRef) context
{
	if ([layer isMemberOfClass: [GraphValueLayer class]])
	{
		GraphValueLayer*	gvLayer = (GraphValueLayer*)layer;
		
		CGPathRef	path = [self graphPathForDataValue: gvLayer.value atIndex: gvLayer.dataIndex];
		CGContextSaveGState(context);

		CGContextAddPath(context, path);
		CGContextSetFillColorWithColor(context, [self.valueColor CGColor]);
		CGContextSetAlpha(context, _valueAlpha);
		CGContextFillPath(context);
		CGPathRelease(path);

		CGContextRestoreGState(context);
        
        [_graphDataView.layer setNeedsDisplay];
	}
    else if ([layer.name isEqualToString: @"Line Layer"])
    {
        GraphValueLayer*    eachLayer;
        CGMutablePathRef	linePath = NULL;
		
        for (eachLayer in layer.sublayers)
        {
            if ([eachLayer isKindOfClass: [GraphValueLayer class]] && eachLayer.presentationLayer)
            {
                GraphValueLayer*    presentationLayer = eachLayer.presentationLayer;
                CGPoint     valuePt = [self graphPointForDataValue: presentationLayer.value atIndex: presentationLayer.dataIndex];
                
                if (! linePath)
                    linePath = CGPathCreateMutable();
                
                if (presentationLayer.dataIndex == 0)
                    CGPathMoveToPoint(linePath, NULL, valuePt.x, valuePt.y);
                else
                    CGPathAddLineToPoint(linePath, NULL, valuePt.x, valuePt.y);
            }
        }
        
        if (linePath)
        {
            CGContextSaveGState(context);
            
            CGContextAddPath(context, linePath);
            CGContextStrokePath(context);
            CGPathRelease(linePath);
            
            CGContextRestoreGState(context);
        }
	}
	else
		NSLog(@"[GraphView drawLayer: %@ inContext: %@] -- Don't know what to do with layer.  Ignoring.", layer, context);
}

- (void) refreshValues
{
	CALayer*	eachValueLayer;
	
	for (eachValueLayer in _graphDataView.layer.sublayers)
		[eachValueLayer setNeedsDisplay];
}

- (void) resizeValues: (CGRect) newRect
{
	CALayer*	eachValueLayer;
	
	for (eachValueLayer in _graphDataView.layer.sublayers)
		[eachValueLayer setFrame: newRect];
}
@end
