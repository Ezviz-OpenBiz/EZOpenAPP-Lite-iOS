//
//  NSString+DDKit.h
//  DDCategory
//
//  Created by DeJohn Dong on 15-3-20.
//  Copyright (c) 2015年 DDKit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DDKit)

@end

@interface NSString (DDDate)

/**
 *  Get date info string from a date type object
 *
 *  @param date date type object
 *
 *  @return a date info string
 */
+ (NSString *)dd_formatInfoFromDate:(NSDate *)date;

/**
 *  Get sns date info string form date type object
 *
 *  @param date date type object
 *
 *  @return a date info string of sns
 */
+ (NSString *)dd_formatDateFromDate:(NSDate *)date;

@end

@interface NSString (DDPredicate)

/**
 *  check the string is email
 *
 *  @param input input string
 *
 *  @return true/false value
 */
+ (BOOL)dd_checkEmail:(NSString *)input;

/**
 *  check the string is phone Number
 *
 *  @param input input string
 *
 *  @return true/false value
 */
+ (BOOL)dd_checkPhoneNumber:(NSString *)input;

/**
 *  check the string is chinese name
 *
 *  @param input input string
 *
 *  @return true/false value
 */
+ (BOOL)dd_checkChineseName:(NSString *)input;

/**
 *  check the string is valudate code
 *
 *  @param input input string
 *
 *  @return true/false value
 */
+ (BOOL)dd_checkValidateCode:(NSString *)input;

/**
 *  check the string is strong password string
 *
 *  @param input input string
 *
 *  @return true/false value
 */
+ (BOOL)dd_checkPassword:(NSString *)input;


/**
 *  check the string is mobile number
 *
 *  @param input input string
 *
 *  @return true/false value
 */
+ (BOOL)dd_checkMobileNumber:(NSString *)input;

/**
 *  check the string is validate money
 *
 *  @param input input string
 *
 *  @return true/false value
 */
+ (BOOL)dd_checkWithDrawMoney:(NSString *)input;

@end

@interface NSString (md5)

/**
 *  Get a md5 string - encrypt method
 *
 *  @return The md5 encrypt string
 */
- (NSString *)dd_md5;

@end

@interface NSString (DDSubString)

/**
 *  Get substring from origin string with condition
 *
 *  @param bKey The begin key
 *  @param eKey The end key
 *
 *  @return The result string
 */
- (NSString *)dd_getSubStringBeginKey:(NSString *)bKey endKey:(NSString *)eKey;

@end

@interface NSString (DDPrice)

+ (NSString *)dd_formatPrice:(NSNumber *)price;

@end

