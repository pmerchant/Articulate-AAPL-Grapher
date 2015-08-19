//
//  GraphValueLayer.m
//  Articulate AAPL Grapher
//
//  Created by Peter Merchant on 8/16/15.
//  Copyright (c) 2015 Peter Merchant. All rights reserved.
//

#import "GraphValueLayer.h"

@implementation GraphValueLayer

@dynamic value;
@dynamic dataIndex;

+ (BOOL) needsDisplayForKey: (NSString*) key
{
	if ([key isEqualToString: @"value"])
		return YES;
	else
		return [super needsDisplayForKey: @"value"];
}

- (id) initWithLayer: (id) layer
{
	if ((self = [super initWithLayer: layer]))
	{
		if ([layer isMemberOfClass: [GraphValueLayer class]])
		{
			self.value = ((GraphValueLayer*)layer).value;
			self.dataIndex = ((GraphValueLayer*)layer).dataIndex;
		}
	}
	
	return self;
}

@end
