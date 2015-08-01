//
//  AddressBook.h
//  YUAddressBook
//
//  Created by yuzhx on 15/8/1.
//  Copyright (c) 2015年 BruceYu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddressBookObj.h"

@interface AddressBook : NSObject
+(AddressBook*)sharedInstance;

/**
 * 返回通讯录对象
 *
 * @return (AddressBookObj)
 **/

+(NSMutableArray*)addressBooks;


/**
 * 判断是否存在 phoneNum
 *
 * @param phoneNum 联系人电话
 *
 * @return (NSMutableArray)
 **/

+(BOOL)containPhoneNum:(NSString*)phoneNum;


@end
