//
//  Contact.m
//  SingleTableView
//
//  Created by xiong on 16/8/30.
//  Copyright © 2016年 xiong. All rights reserved.
//

#import "Contact.h"

@implementation Contact
- (NSMutableArray *)emails{
    if (!_emails) {
        _emails = [NSMutableArray array];
    }
    return _emails;
}
- (NSMutableArray *)address{
    if (!_address) {
        _address = [NSMutableArray array];
    }
    return _address;
}
- (NSMutableArray *)dates{
    if (!_dates) {
        _dates = [NSMutableArray array];
    }
    return _dates;
}
-(NSMutableArray *)instantMessage{
    if (!_instantMessage) {
        _instantMessage = [NSMutableArray array];
    }
    return _instantMessage;
}
-(NSMutableArray *)phone{
    if (!_phone) {
        _phone = [NSMutableArray array];
    }
    return _phone;
}
-(NSMutableArray *)url{
    if (!_url) {
        _url = [NSMutableArray array];
    }
    return _url;
}
@end


@implementation Address

@end


@implementation Date

@end


@implementation Message

@end


@implementation Phone

@end


@implementation Email

@end


@implementation Url

@end