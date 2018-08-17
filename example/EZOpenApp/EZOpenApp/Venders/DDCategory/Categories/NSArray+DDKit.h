//
//  NSArray+DDKit.h
//  DDCategory
//
//  Created by DeJohn Dong on 15/4/25.
//  Copyright (c) 2015年 DDKit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (DDKit)

/**
 *  Fixed the issue of array index beyond bounds
 *
 *  @param index The array index
 *
 *  @return Object in array
 */
- (id)dd_objectAtIndex:(NSUInteger)index;

@end
