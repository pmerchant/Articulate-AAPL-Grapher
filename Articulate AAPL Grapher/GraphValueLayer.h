//
//  GraphValueLayer.h
//  Articulate AAPL Grapher
//
//  Created by Peter Merchant on 8/16/15.
//  Copyright (c) 2015 Peter Merchant. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface GraphValueLayer : CALayer
{
}

@property (readwrite, assign) double	value;
@property (readwrite, assign) int		dataIndex;

+ (BOOL) needsDisplayForKey: (NSString*) key;

- (id) initWithLayer: (id) layer;

@end
