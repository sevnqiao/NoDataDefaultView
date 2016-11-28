//
//  ContactsManager.h
//  SingleTableView
//
//  Created by xiong on 16/8/31.
//  Copyright © 2016年 xiong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Contacts/Contacts.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ContactsManager : NSObject

+ (ContactsManager *)shareManager;

- (BOOL)authorizationStatus;

/**
 *  获取转化为实体的联系人数组
 *
 *  @return  Contact 数组
 */
- (NSArray *)loadAllSystemContacts;

- (id)contactDetailViewControllerWithContactRef:(id)contactRef;

- (id)newContactViewControllerWithContactRef:(id)contactRef;

- (BOOL)removeContactRef:(id)contactRef;

@end


@interface NSString (Pinyin)
+ (NSString *)transform:(NSString *)chinese;
@end

@interface NSMutableArray (Sort)
- (NSMutableArray *)sortWithKey:(NSString *)sortKey;
@end