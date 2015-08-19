//
//  StockPrices.m
//  Articulate AAPL Grapher
//
//  Created by Peter Merchant on 8/13/15.
//  Copyright (c) 2015 Peter Merchant. All rights reserved.
//

#import "StockPrices.h"

@interface StockPrices (StockPrices_Private)

- (NSArray*) buildPriceDateArray: (NSArray*) rawDataArray;

@end

@implementation StockPrices

- (id) initWithJSONData: (NSData*) jsonData
{
	if ((self = [self init]))
	{
		NSError*		err;
		NSDictionary*	jsonDict = [NSJSONSerialization JSONObjectWithData: jsonData options: 0 error: &err];
		
		if (err)	// Problem with reading file?
			self = NULL;
		else if (! [jsonDict isKindOfClass: [NSDictionary class]])	// We should start with a dictionary...
			self = NULL;
		else
		{
			NSArray*	dataArray = [jsonDict objectForKey: @"stockdata"];
			
			if (! dataArray)
				self = NULL;
			else
				priceDateArray = [self buildPriceDateArray: dataArray];
		}
	}
	
	return self;
}

#pragma mark -

- (NSArray*) buildPriceDateArray: (NSArray*) rawDataArray
{
	NSMutableArray*		newPriceDateArray = [NSMutableArray array];
	NSDictionary*		eachPriceDate;
	NSDateFormatter*	dateFormat = [[NSDateFormatter alloc] init];

	[dateFormat setDateFormat: @"yyyy-MM-dd HH:mmZ"];
	
	for (eachPriceDate in rawDataArray)
	{
		NSString*	closeString = [eachPriceDate objectForKey: @"close"];
		NSNumber*	closeValue = [NSNumber numberWithDouble: [closeString doubleValue]];
		NSString*	closeDateString = [eachPriceDate objectForKey: @"date"];
		NSDate*		closeDate;
		
		closeDateString = [closeDateString stringByAppendingString: @" 20:00Z"];
		closeDate = [dateFormat dateFromString: closeDateString];
		
		NSDictionary*	priceDate = [NSDictionary dictionaryWithObjectsAndKeys: closeDate, @"date",
																				closeValue, @"price", nil];
		
        NSUInteger minIndex = 0;
        NSUInteger maxIndex;
        
        if (newPriceDateArray.count == 0)
            [newPriceDateArray addObject: priceDate];
        else
        {
            maxIndex = newPriceDateArray.count;

            while (maxIndex - minIndex > 1 )
            {
                NSUInteger center = (minIndex + maxIndex) / 2;
                
                NSComparisonResult  closeCompare = [closeDate compare: newPriceDateArray[center][@"date"]];
                
                if (closeCompare == NSOrderedAscending || closeCompare == NSOrderedSame)
                    maxIndex = center;
                else if (closeCompare == NSOrderedDescending)
                    minIndex = center;
            }
            
            if (minIndex == maxIndex || [closeDate compare: newPriceDateArray[minIndex][@"date"]] == NSOrderedDescending)
                [newPriceDateArray insertObject: priceDate atIndex: maxIndex];
            else if ([closeDate compare: newPriceDateArray[minIndex][@"date"]] == NSOrderedAscending)
                [newPriceDateArray insertObject: priceDate atIndex: minIndex];
            else
                [newPriceDateArray insertObject: priceDate atIndex: maxIndex];
        }
	}
	
	return newPriceDateArray;
}

#pragma mark - GraphView Datasource Protocol Methods

- (NSUInteger) count
{
	return [priceDateArray count];
}

- (NSString*) xAxisLabelAtIndex: (NSUInteger) index
{
	NSDateFormatter*	dateFormatter = [[NSDateFormatter alloc] init];
	NSDictionary*		priceDate = [priceDateArray objectAtIndex: index];
	NSString*			dateFormat = [NSDateFormatter dateFormatFromTemplate: @"M/d" options: 0 locale: [NSLocale currentLocale]];
	NSDate*				date =[priceDate objectForKey: @"date"];
	NSString*			label;
	
	[dateFormatter setDateFormat: dateFormat];
	label = [dateFormatter stringFromDate: date];
	
	return label;
}

- (double) yAxisValueAtIndex: (NSUInteger) index
{
	NSDictionary*	priceDate = [priceDateArray objectAtIndex: index];
	
	return [[priceDate objectForKey: @"price"] doubleValue];
}

@end
