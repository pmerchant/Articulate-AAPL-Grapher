//
//  GraphDataSourceProtocol.h
//  Articulate AAPL Grapher
//
//  Created by Peter Merchant on 8/12/15.
//  Copyright (c) 2015 Peter Merchant. All rights reserved.
//

/*!
 @protocol GraphDataSourceProtocol
 @discussion The Graph Data Source Protocol allows an object to retrieve labels and data for a graph.
*/

#import <Foundation/Foundation.h>

@protocol GraphDataSourceProtocol <NSObject>

/*!
 @method count
 @discussion Returns the number of data items.
*/
- (NSUInteger) count;

/*! 
 @method xAxisLabelAtIndex:
 @discussion Return what the Label for a data item, to be shown along the X-Axis.
 @example If you have data for the months on January, February, March, etc., you could return the strings "J", "F", "M"
	or "Jan", "Feb", "Mar", etc.
*/
- (NSString*) xAxisLabelAtIndex: (NSUInteger) index;

/*!
 @method yAxisValueAtIndex:
 @discussion Return the value for a data item.
 */
- (double) yAxisValueAtIndex: (NSUInteger) index;

@end