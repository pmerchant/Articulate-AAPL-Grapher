//
//  StockPrices.h
//  Articulate AAPL Grapher
//
//  Created by Peter Merchant on 8/13/15.
//  Copyright (c) 2015 Peter Merchant. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GraphDataSourceProtocol.h"

@interface StockPrices : NSObject <GraphDataSourceProtocol>
{
	NSArray*	priceDateArray;
}

- (id) initWithJSONData: (NSData*) jsonData;

@end
