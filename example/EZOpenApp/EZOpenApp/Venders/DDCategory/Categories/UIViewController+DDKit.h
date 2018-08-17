//
//  UIViewController+DDKit.h
//  MBBCommon
//
//  Created by DeJohn Dong on 15-3-18.
//  Copyright (c) 2015年 DDKit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (DDKit)

/**
 *  Instance a viewController as use the 'nitWithNibName:bundle:' method with the same name xib file
 *
 *  @return Initlialized viewController object
 */
+ (instancetype)dd_loadWithNib;

@end
