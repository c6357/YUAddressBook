//
//  AddressBook.m
//  YUAddressBook
//
//  Created by yuzhx on 15/8/1.
//  Copyright (c) 2015年 BruceYu. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <UIKit/UIKit.h>

#import "AddressBook.h"


#define IsSafeString(a)             ((a)&& (![(a) isEqual:[NSNull null]]) &&((a).length>0))
#define SafeString(a)               ((((a)==nil)||([(a) isEqual:[NSNull null]])||((a).length==0))?@"":(a))
static AddressBook *sharedAddressBook;
static dispatch_once_t onceToken;



@interface AddressBook()
@property (assign,nonatomic)ABAddressBookRef addressBooksRef;
@property (strong,nonatomic)NSMutableArray *addressBooksArr;
@end

@implementation AddressBook

+(AddressBook*)sharedInstance{
    dispatch_once(&onceToken, ^{
        sharedAddressBook = [[AddressBook alloc]init];
    });
    return sharedAddressBook;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}


#pragma mark -
-(ABAddressBookRef)addressBooksRef{
    
    if (!_addressBooksRef) {
        
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
        {
            _addressBooksRef =  ABAddressBookCreateWithOptions(NULL, NULL);
            
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(_addressBooksRef, ^(bool granted, CFErrorRef error){dispatch_semaphore_signal(sema);});
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            
        }else{
            
            _addressBooksRef = ABAddressBookCreateWithOptions(_addressBooksRef, nil);
        }
    }
    return _addressBooksRef;
}

-(NSMutableArray *)addressBooksArr{
    
    if (!_addressBooksArr) {
        
        _addressBooksArr = [NSMutableArray array];
        
        NSArray *contacts = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople([AddressBook sharedInstance].addressBooksRef);
        
        NSInteger contactsCount = [contacts count];
        
        for(int i = 0; i < contactsCount; i++)
        {
            ABRecordRef record = (__bridge ABRecordRef)[contacts objectAtIndex:i];
            
            AddressBookObj * addressBookObj = [[AddressBookObj alloc] init];
            
            //取得联系人的ID
            addressBookObj.recordID = (int)ABRecordGetRecordID(record);
            
            //完整姓名
            CFStringRef compositeNameRef = ABRecordCopyCompositeName(record);
            addressBookObj.compositeName = SafeString((__bridge NSString *)compositeNameRef);
            compositeNameRef != NULL ? CFRelease(compositeNameRef) : NULL;
            
            
            
            //处理联系人电话号码
            ABMultiValueRef  phones = ABRecordCopyValue(record, kABPersonPhoneProperty);
            for(int i = 0; i < ABMultiValueGetCount(phones); i++)
            {
                CFStringRef phoneLabelRef = ABMultiValueCopyLabelAtIndex(phones, i);
                CFStringRef localizedPhoneLabelRef = ABAddressBookCopyLocalizedLabel(phoneLabelRef);
                CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, i);
                
                NSString * localizedPhoneLabel = (__bridge NSString *) localizedPhoneLabelRef;
                NSString * phoneNumber = (__bridge NSString *)phoneNumberRef;
                
                
                NSString *phone = [phoneNumber stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phoneNumber length])];
                
                if (i == 0) {
                    addressBookObj.pbone = SafeString(phone);
                }
                [addressBookObj.phoneInfo setValue:localizedPhoneLabel forKey:phone];
                
                //Release
                phoneLabelRef == NULL ? : CFRelease(phoneLabelRef);
                localizedPhoneLabelRef == NULL ? : CFRelease(localizedPhoneLabelRef);
                phoneNumberRef == NULL ? : CFRelease(phoneNumberRef);
            }
            if(phones != NULL) CFRelease(phones);
            
            
            if (IsSafeString(addressBookObj.pbone)) {
                [_addressBooksArr addObject:addressBookObj];
            }
            
            CFRelease(record);
        }
    }
    
    return _addressBooksArr;

}


+(NSMutableArray*)addressBooks{
    return [AddressBook sharedInstance].addressBooksArr;
}


+(BOOL)containPhoneNum:(NSString*)phoneNum{
    
    for (AddressBookObj *obj in [AddressBook sharedInstance].addressBooksArr) {
        
        if (obj.phoneInfo[phoneNum]) {
            
            return YES;
        }
    }
    return NO;
}
@end

