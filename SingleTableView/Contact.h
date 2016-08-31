//
//  Contact.h
//  SingleTableView
//
//  Created by xiong on 16/8/30.
//  Copyright © 2016年 xiong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>


@interface Contact : NSObject

@property (nonatomic) ABRecordRef aBRecordRef;

@property (nonatomic, copy  ) NSString *firstName;

@property (nonatomic, copy  ) NSString *lastName;
//读取middlename
@property (nonatomic, copy  ) NSString *middlename;

@property (nonatomic, copy  ) NSString *pinyinName;

//读取prefix前缀
@property (nonatomic, copy  ) NSString *prefix;
//读取suffix后缀
@property (nonatomic, copy  ) NSString *suffix;
//读取nickname呢称
@property (nonatomic, copy  ) NSString *nickname ;
//读取firstname拼音音标
@property (nonatomic, copy  ) NSString *firstnamePhonetic;
//读取lastname拼音音标
@property (nonatomic, copy  ) NSString *lastnamePhonetic;
//读取middlename拼音音标
@property (nonatomic, copy  ) NSString *middlenamePhonetic;
//读取organization公司
@property (nonatomic, copy  ) NSString *organization;
//读取jobtitle工作
@property (nonatomic, copy  ) NSString *jobtitle;
//读取department部门
@property (nonatomic, copy  ) NSString *department;
//读取birthday生日
@property (nonatomic, copy  ) NSDate   *birthday;
//读取note备忘录
@property (nonatomic, copy  ) NSString *note;
//第一次添加该条记录的时间
@property (nonatomic, copy  ) NSString *firstknow;
//最后一次修改該条记录的时间
@property (nonatomic, copy  ) NSString *lastknow;

// 照片
@property (nonatomic, strong) NSData   *image;

//email
@property (nonatomic, strong) NSMutableArray  *emails;

@property (nonatomic, strong) NSMutableArray  *address;

@property (nonatomic, strong) NSMutableArray  *dates;

@property (nonatomic, strong) NSMutableArray  *instantMessage;

@property (nonatomic, strong) NSMutableArray  *phone;

@property (nonatomic, strong) NSMutableArray  *url;

@end

@interface Email : NSObject
//获取email Label
@property (nonatomic, copy) NSString* emailLabel;
//获取email值
@property (nonatomic, copy) NSString* emailContent;
@end


@interface Address : NSObject
@property (nonatomic, copy) NSString* addressLabel;
//获取該label下的地址6属性
@property (nonatomic, copy) NSString* country ;
@property (nonatomic, copy) NSString* city;
@property (nonatomic, copy) NSString* state;
@property (nonatomic, copy) NSString* street;
@property (nonatomic, copy) NSString* zip;
@property (nonatomic, copy) NSString* coutntry;
@end


@interface Date : NSObject
//获取dates Label
@property (nonatomic, copy) NSString* datesLabel;
//获取dates值
@property (nonatomic, copy) NSString* datesContent;
@end


@interface Message : NSObject
@property (nonatomic, copy) NSString* instantMessageLabel;
//获取該label下的2属性
@property (nonatomic, copy) NSString* username;

@property (nonatomic, copy) NSString* service;
@end


@interface Phone : NSObject
//获取电话Label
@property (nonatomic, copy) NSString * personPhoneLabel;
//获取該Label下的电话值
@property (nonatomic, copy) NSString * personPhone;
                     

@end


@interface Url : NSObject
//获取电话Label
@property (nonatomic, copy) NSString * urlLabel;
//获取該Label下的电话值
@property (nonatomic, copy) NSString * urlContent;
@end