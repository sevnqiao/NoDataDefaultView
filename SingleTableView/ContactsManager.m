//
//  ContactsManager.m
//  SingleTableView
//
//  Created by xiong on 16/8/31.
//  Copyright © 2016年 xiong. All rights reserved.
//

#import "ContactsManager.h"
#import "Contact.h"

#import <ContactsUI/ContactsUI.h>

#define DiveSysVersion 9.0

@implementation ContactsManager


+ (ContactsManager *)shareManager
{
    static ContactsManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ContactsManager alloc]init];
    });
    return manager;
}

+ (CNContactStore *)shareStore{
    static CNContactStore *store;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[CNContactStore alloc]init];
    });
    return store;
}

// 获取通讯录授权
- (BOOL)authorizationStatus
{
    if ([UIDevice currentDevice].systemVersion.floatValue >= DiveSysVersion)
    {
        if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized)
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    else
    {
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    
}

// 转换为联系人实体
- (NSArray *)loadAllSystemContacts
{
    NSMutableArray *contactArr = [NSMutableArray array];
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= DiveSysVersion)
    {
        CNContactStore *contactStore = [ContactsManager shareStore];
        
        
        //        NSArray *keys = @[CNContactIdentifierKey, CNContactNamePrefixKey ,CNContactGivenNameKey ,CNContactMiddleNameKey ,CNContactFamilyNameKey ,CNContactPreviousFamilyNameKey ,CNContactNameSuffixKey ,CNContactNicknameKey ,CNContactPhoneticGivenNameKey ,CNContactPhoneticMiddleNameKey ,CNContactPhoneticFamilyNameKey ,CNContactOrganizationNameKey ,CNContactDepartmentNameKey ,CNContactJobTitleKey ,CNContactBirthdayKey ,CNContactNonGregorianBirthdayKey ,CNContactNoteKey ,CNContactImageDataKey ,CNContactThumbnailImageDataKey ,CNContactImageDataAvailableKey ,CNContactTypeKey ,CNContactPhoneNumbersKey ,CNContactEmailAddressesKey ,CNContactPostalAddressesKey ,CNContactDatesKey ,CNContactUrlAddressesKey ,CNContactRelationsKey ,CNContactSocialProfilesKey ,CNContactInstantMessageAddressesKey];
        
        
        // 这个地方甚是奇怪, 系统给出的 key 只有上面那些,  可是如果少了下面里面多出来的几个,就跳转不了呢,
        NSMutableArray *keys2 =[NSMutableArray arrayWithArray:@[@"fullscreenImageData",@"textAlert",@"dates",@"middleName",@"nickname",@"preferredForImage",@"socialProfiles",@"organizationName",@"imageData",@"calendarURIs",@"pronunciationGivenName",@"pronunciationFamilyName",@"emailAddresses",@"birthday",@"imageDataAvailable",@"nameSuffix",@"nonGregorianBirthday",@"phoneNumbers",@"phoneticGivenName",@"previousFamilyName",@"familyName",@"urlAddresses",@"identifier",@"thumbnailImageData",@"contactType",@"departmentName",@"callAlert",@"cropRect",@"contactRelations",@"postalAddresses",@"instantMessageAddresses",@"mapsData",@"preferredForName",@"linkIdentifier",@"namePrefix",@"phoneticMiddleName",@"jobTitle",@"iOSLegacyIdentifier",@"phoneticFamilyName",@"note",@"givenName"]];
        
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc]initWithKeysToFetch:keys2];
        
        [contactStore enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
            if (contact) {
                [contactArr addObject:[self transformContactWithPersonData:contact]];
            }
        }];

    }
    else
    {
    
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
        
        CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
        CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);

        for ( int i = 0; i < numberOfPeople; i++){

            ABRecordRef person = CFArrayGetValueAtIndex(people, i);

             [contactArr addObject:[self transformContactWithPersonData:(__bridge id)(person)]];
        }
    }
    
    return contactArr;
}

- (Contact *)transformContactWithPersonData:(id)person
{
    Contact *contact = [Contact new];
    
    contact.person = person;
    
    contact.firstName = [self firstNameWithContactRef:person];
    
    contact.lastName = [self lastNameWithContactRef:person];
    
    contact.middlename = [self middlenameWithContactRef:person];
    
    contact.pinyinName = [NSString transform:[NSString stringWithFormat:@"%@%@%@",contact.lastName?:@"" ,contact.firstName?:@"" ,contact.middlename?:@""]];
    
    contact.prefix = [self prefixWithContactRef:person];
    
    contact.suffix = [self suffixWithContactRef:person];
    
    contact.nickname = [self nicknameWithContactRef:person];
    
    contact.firstnamePhonetic = [self firstnamePhoneticWithContactRef:person];
    
    contact.lastnamePhonetic = [self lastnamePhoneticWithContactRef:person];
    
    contact.middlenamePhonetic = [self middlenamePhoneticWithContactRef:person];
    
    contact.organization = [self organizationWithContactRef:person];
    
    contact.jobtitle = [self jobtitleWithContactRef:person];
    
    contact.department = [self departmentWithContactRef:person];
    
    contact.birthday = [self birthdayWithContactRef:person];
    
    contact.note = [self noteWithContactRef:person];
    
    contact.firstknow = [self firstknowWithContactRef:person];
    
    contact.lastknow = [self lastknowWithContactRef:person];
    
    contact.image = [self imageWithContactRef:person];
    
    contact.emails = [self transformEmailInfoWithABRecordRef:person];
    
    contact.address = [self transformAddressInfoWithABRecordRef:person];
    
    contact.dates = [self transformDatesInfoWithABRecordRef:person];
    
    contact.instantMessage = [self transformInstantMessageWithABRecordRef:person];
    
    contact.phone = [self transformPhoneInfoWithABRecordRef:person];
    
    contact.url = [self transformUrlInfoWithABRecordRef:person];
    
    return contact;
    
}

- (id)firstNameWithContactRef:(id)contactRef
{
    if ([contactRef isKindOfClass:[CNContact class]])
    {
        if ([((CNContact *)contactRef) isKeyAvailable:CNContactGivenNameKey]) {
            return ((CNContact *)contactRef).givenName;
        }
        return nil;
    }
    else
    {
        return (__bridge id)ABRecordCopyValue((__bridge ABRecordRef)(contactRef), kABPersonFirstNameProperty);
    }
}

- (id)lastNameWithContactRef:(id)contactRef
{
    if ([contactRef isKindOfClass:[CNContact class]])
    {
        if ([((CNContact *)contactRef) isKeyAvailable:CNContactFamilyNameKey]) {
            return ((CNContact *)contactRef).familyName;
        }
        return nil;
    }
    else
    {
        return (__bridge id)ABRecordCopyValue((__bridge ABRecordRef)(contactRef), kABPersonLastNameProperty);
    }
}

- (id)middlenameWithContactRef:(id)contactRef
{
    if ([contactRef isKindOfClass:[CNContact class]])
    {
        if ([((CNContact *)contactRef) isKeyAvailable:CNContactMiddleNameKey]) {
            return ((CNContact *)contactRef).middleName;
        }
        return nil;
    }
    else
    {
        return (__bridge id)ABRecordCopyValue((__bridge ABRecordRef)(contactRef), kABPersonMiddleNameProperty);
    }
}

- (id)prefixWithContactRef:(id)contactRef
{
    if ([contactRef isKindOfClass:[CNContact class]])
    {
        if ([((CNContact *)contactRef) isKeyAvailable:CNContactNamePrefixKey]) {
            return ((CNContact *)contactRef).namePrefix;
        }
        return nil;
    }
    else
    {
        return (__bridge id)ABRecordCopyValue((__bridge ABRecordRef)(contactRef), kABPersonPrefixProperty);
    }
}

- (id)suffixWithContactRef:(id)contactRef
{
    if ([contactRef isKindOfClass:[CNContact class]])
    {
        if ([((CNContact *)contactRef) isKeyAvailable:CNContactNameSuffixKey]) {
            return ((CNContact *)contactRef).nameSuffix;
        }
        return nil;
    }
    else
    {
        return (__bridge id)ABRecordCopyValue((__bridge ABRecordRef)(contactRef), kABPersonSuffixProperty);
    }
}

- (id)nicknameWithContactRef:(id)contactRef
{
    if ([contactRef isKindOfClass:[CNContact class]])
    {
        if ([((CNContact *)contactRef) isKeyAvailable:CNContactNicknameKey]) {
            return ((CNContact *)contactRef).nickname;
        }
        return nil;
    }
    else
    {
        return (__bridge id)ABRecordCopyValue((__bridge ABRecordRef)(contactRef), kABPersonNicknameProperty);
    }
}

- (id)firstnamePhoneticWithContactRef:(id)contactRef
{
    if ([contactRef isKindOfClass:[CNContact class]])
    {
        if ([((CNContact *)contactRef) isKeyAvailable:CNContactPhoneticGivenNameKey]) {
            return ((CNContact *)contactRef).phoneticGivenName;
        }
        return nil;
    }
    else
    {
        return (__bridge id)ABRecordCopyValue((__bridge ABRecordRef)(contactRef), kABPersonFirstNamePhoneticProperty);
    }
}

- (id)lastnamePhoneticWithContactRef:(id)contactRef
{
    if ([contactRef isKindOfClass:[CNContact class]])
    {
        if ([((CNContact *)contactRef) isKeyAvailable:CNContactPhoneticFamilyNameKey]) {
            return ((CNContact *)contactRef).phoneticFamilyName;
        }
        return nil;
    }
    else
    {
        return (__bridge id)ABRecordCopyValue((__bridge ABRecordRef)(contactRef), kABPersonLastNamePhoneticProperty);
    }
}

- (id)middlenamePhoneticWithContactRef:(id)contactRef
{
    if ([contactRef isKindOfClass:[CNContact class]])
    {
        if ([((CNContact *)contactRef) isKeyAvailable:CNContactPhoneticMiddleNameKey]) {
            return ((CNContact *)contactRef).phoneticMiddleName;
        }
        return nil;
    }
    else
    {
        return (__bridge id)ABRecordCopyValue((__bridge ABRecordRef)(contactRef), kABPersonMiddleNamePhoneticProperty);
    }
}

- (id)organizationWithContactRef:(id)contactRef
{
    if ([contactRef isKindOfClass:[CNContact class]])
    {
        if ([((CNContact *)contactRef) isKeyAvailable:CNContactOrganizationNameKey]) {
            return ((CNContact *)contactRef).organizationName;
        }
        return nil;
    }
    else
    {
        return (__bridge id)ABRecordCopyValue((__bridge ABRecordRef)(contactRef), kABPersonOrganizationProperty);
    }
}

- (id)jobtitleWithContactRef:(id)contactRef
{
    if ([contactRef isKindOfClass:[CNContact class]])
    {
        if ([((CNContact *)contactRef) isKeyAvailable:CNContactJobTitleKey]) {
            return ((CNContact *)contactRef).jobTitle;
        }
        return nil;
    }
    else
    {
        return (__bridge id)ABRecordCopyValue((__bridge ABRecordRef)(contactRef), kABPersonJobTitleProperty);
    }
}

- (id)departmentWithContactRef:(id)contactRef
{
    if ([contactRef isKindOfClass:[CNContact class]])
    {
        if ([((CNContact *)contactRef) isKeyAvailable:CNContactDepartmentNameKey]) {
            return ((CNContact *)contactRef).departmentName;
        }
        return nil;
    }
    else
    {
        return (__bridge id)ABRecordCopyValue((__bridge ABRecordRef)(contactRef), kABPersonDepartmentProperty);
    }
}

- (id)birthdayWithContactRef:(id)contactRef
{
    if ([contactRef isKindOfClass:[CNContact class]])
    {
        if ([((CNContact *)contactRef) isKeyAvailable:CNContactBirthdayKey]) {
            return ((CNContact *)contactRef).birthday;
        }
        return nil;
    }
    else
    {
        return (__bridge id)ABRecordCopyValue((__bridge ABRecordRef)(contactRef), kABPersonBirthdayProperty);
    }
}

- (id)noteWithContactRef:(id)contactRef
{
    if ([contactRef isKindOfClass:[CNContact class]])
    {
        if ([((CNContact *)contactRef) isKeyAvailable:CNContactNoteKey]) {
            return ((CNContact *)contactRef).note;
        }
        return nil;
    }
    else
    {
        return (__bridge id)ABRecordCopyValue((__bridge ABRecordRef)(contactRef), kABPersonNoteProperty);
    }
}

- (id)firstknowWithContactRef:(id)contactRef
{
    if ([contactRef isKindOfClass:[CNContact class]])
    {
        return nil;
    }
    else
    {
        return (__bridge id)ABRecordCopyValue((__bridge ABRecordRef)(contactRef), kABPersonCreationDateProperty);
    }
}

- (id)lastknowWithContactRef:(id)contactRef
{
    if ([contactRef isKindOfClass:[CNContact class]])
    {
        return nil;
    }
    else
    {
        return (__bridge id)ABRecordCopyValue((__bridge ABRecordRef)(contactRef), kABPersonModificationDateProperty);
    }
}

- (id)imageWithContactRef:(id)contactRef
{
    if ([contactRef isKindOfClass:[CNContact class]])
    {
        if ([((CNContact *)contactRef) isKeyAvailable:CNContactImageDataKey]) {
            return ((CNContact *)contactRef).imageData;
        }
        return nil;
    }
    else
    {
        return (__bridge NSData*)ABPersonCopyImageData((__bridge ABRecordRef)(contactRef));
    }
}

//获取email多值
- (NSMutableArray *)transformEmailInfoWithABRecordRef:(id)aBRecordRef
{
    NSMutableArray *array = [NSMutableArray array];
    
    if ([aBRecordRef isKindOfClass:[CNContact class]])
    {
        if (![aBRecordRef isKeyAvailable:CNContactEmailAddressesKey]) {
            return nil;
        }
        for (int x = 0; x < ((CNContact *)aBRecordRef).emailAddresses.count; x++)
        {
            Email *email = [Email new];
            
            CNLabeledValue *labelValue = ((CNContact *)aBRecordRef).emailAddresses[x];
            
            //获取email Label
            email.emailLabel = [CNLabeledValue localizedStringForLabel:labelValue.label];
            //获取email值
            email.emailContent = labelValue.value;
            
            [array addObject:email];
        }
        
    }
    else
    {
        ABMultiValueRef emailInfo = ABRecordCopyValue((__bridge ABRecordRef)(aBRecordRef), kABPersonEmailProperty);
        
        for (int x = 0; x < ABMultiValueGetCount(emailInfo); x++)
        {
            Email *email = [Email new];
            //获取email Label
            email.emailLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(emailInfo, x));
            //获取email值
            email.emailContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emailInfo, x);
            
            [array addObject:email];
        }
    }
    return array;
}

//读取地址多值
- (NSMutableArray *)transformAddressInfoWithABRecordRef:(id)aBRecordRef
{
    NSMutableArray *array = [NSMutableArray array];
    
    if ([aBRecordRef isKindOfClass:[CNContact class]])
    {
        if (![aBRecordRef isKeyAvailable:CNContactPostalAddressesKey]) {
            return nil;
        }
        for (int x = 0; x < ((CNContact *)aBRecordRef).postalAddresses.count; x++)
        {
            Address *address = [Address new];
            
            CNLabeledValue *labelValue = ((CNContact *)aBRecordRef).postalAddresses[x];
            CNPostalAddress *postalAddress = labelValue.value;
            
            address.addressLabel = [CNLabeledValue localizedStringForLabel:labelValue.label];
            address.country = postalAddress.country;
            address.city = postalAddress.city;
            address.street = postalAddress.street;
            address.state = postalAddress.state;
            address.zip = postalAddress.postalCode;
            address.coutntry = postalAddress.ISOCountryCode;
            
            [array addObject:address];
        }
    }
    else
    {
        ABMultiValueRef addressInfo = ABRecordCopyValue((__bridge ABRecordRef)(aBRecordRef), kABPersonAddressProperty);
        
        for(int j = 0; j < ABMultiValueGetCount(addressInfo); j++)
        {
            Address *address = [Address new];
            
            address.addressLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(addressInfo, j));
            NSDictionary *personaddress =(__bridge NSDictionary*) ABMultiValueCopyValueAtIndex(addressInfo, j);
            address.country = [personaddress valueForKey:(NSString *)kABPersonAddressCountryKey];
            address.city = [personaddress valueForKey:(NSString *)kABPersonAddressCityKey];
            address.state = [personaddress valueForKey:(NSString *)kABPersonAddressStateKey];
            address.street = [personaddress valueForKey:(NSString *)kABPersonAddressStreetKey];
            address.zip = [personaddress valueForKey:(NSString *)kABPersonAddressZIPKey];
            address.coutntry = [personaddress valueForKey:(NSString *)kABPersonAddressCountryCodeKey];
            
            [array addObject:address];
        }
        
     
    }

    return array;

}

//获取dates多值
- (NSMutableArray *)transformDatesInfoWithABRecordRef:(id)aBRecordRef
{
    NSMutableArray *array = [NSMutableArray array];
    
    if ([aBRecordRef isKindOfClass:[CNContact class]])
    {
        if (![aBRecordRef isKeyAvailable:CNContactDatesKey]) {
            return nil;
        }
        for (int x = 0; x < ((CNContact *)aBRecordRef).dates.count; x++)
        {
            Date *date = [Date new];
            CNLabeledValue *labelValue = ((CNContact *)aBRecordRef).dates[x];
            date.datesLabel = [CNLabeledValue localizedStringForLabel:labelValue.label];
            date.datesContent = [labelValue.value date];
            
            [array addObject:date];
        }
        
    }
    else
    {
        ABMultiValueRef datesInfo = ABRecordCopyValue((__bridge ABRecordRef)(aBRecordRef), kABPersonDateProperty);
        
        for (int y = 0; y < ABMultiValueGetCount(datesInfo); y++)
        {
            Date *date = [Date new];
            
            date.datesLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(datesInfo, y));
            date.datesContent = (__bridge NSDate*)ABMultiValueCopyValueAtIndex(datesInfo, y);
            
            [array addObject:date];
        }
    }
    return array;
}

//获取IM多值
- (NSMutableArray *)transformInstantMessageWithABRecordRef:(id)aBRecordRef
{
    NSMutableArray *array = [NSMutableArray array];
    
    if ([aBRecordRef isKindOfClass:[CNContact class]])
    {
        if (![aBRecordRef isKeyAvailable:CNContactInstantMessageAddressesKey]) {
            return nil;
        }
        for (int x = 0; x < ((CNContact *)aBRecordRef).instantMessageAddresses.count; x++)
        {
            Message *message = [Message new];
            CNLabeledValue *labelValue = ((CNContact *)aBRecordRef).instantMessageAddresses[x];
            message.instantMessageLabel = [CNLabeledValue localizedStringForLabel:labelValue.label];
            
            CNInstantMessageAddress *instantMessage = labelValue.value;
            
            message.username = instantMessage.username;
            message.service = instantMessage.service;
            
            [array addObject:message];
        }
    }
    else
    {
        ABMultiValueRef instantMessage = ABRecordCopyValue((__bridge ABRecordRef)(aBRecordRef), kABPersonInstantMessageProperty);
        for (int l = 1; l < ABMultiValueGetCount(instantMessage); l++)
        {
            Message *message = [Message new];
            //获取IM Label
            message.instantMessageLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(instantMessage, l);
            //获取該label下的2属性
            NSDictionary* instantMessageContent =(__bridge NSDictionary*) ABMultiValueCopyValueAtIndex(instantMessage, l);
            message.username = [instantMessageContent valueForKey:(NSString *)kABPersonInstantMessageUsernameKey];
            
            message.service = [instantMessageContent valueForKey:(NSString *)kABPersonInstantMessageServiceKey];
            
            [array addObject:message];
        }
    }
    return array;
}

//读取电话多值
- (NSMutableArray *)transformPhoneInfoWithABRecordRef:(id)aBRecordRef
{
    NSMutableArray *array = [NSMutableArray array];
    
    if ([aBRecordRef isKindOfClass:[CNContact class]])
    {
        if (![aBRecordRef isKeyAvailable:CNContactPhoneNumbersKey]) {
            return nil;
        }
        for (int x = 0; x < ((CNContact *)aBRecordRef).phoneNumbers.count; x++)
        {
            Phone *phone = [Phone new];
            CNLabeledValue *labelValue = ((CNContact *)aBRecordRef).phoneNumbers[x];
            phone.personPhoneLabel = [CNLabeledValue localizedStringForLabel:labelValue.label];
            CNPhoneNumber *number = labelValue.value;
            phone.personPhone = number.stringValue;
            
            [array addObject:phone];
        }
    }
    else
    {
        ABMultiValueRef phoneInfo = ABRecordCopyValue((__bridge ABRecordRef)(aBRecordRef), kABPersonPhoneProperty);
        for (int k = 0; k<ABMultiValueGetCount(phoneInfo); k++)
        {
            Phone *phone = [Phone new];
            //获取电话Label
            phone.personPhoneLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phoneInfo, k));
            //获取該Label下的电话值
            phone.personPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phoneInfo, k);
            
            [array addObject:phone];
        }
    }
    return array;
}

//获取URL多值
- (NSMutableArray *)transformUrlInfoWithABRecordRef:(id)aBRecordRef
{
    NSMutableArray *array = [NSMutableArray array];
    
    if ([aBRecordRef isKindOfClass:[CNContact class]])
    {
        if (![aBRecordRef isKeyAvailable:CNContactUrlAddressesKey]) {
            return nil;
        }
        for (int x = 0; x < ((CNContact *)aBRecordRef).urlAddresses.count; x++)
        {
            Url *url = [Url new];
            CNLabeledValue *labelValue = ((CNContact *)aBRecordRef).urlAddresses[x];
            url.urlLabel = [CNLabeledValue localizedStringForLabel:labelValue.label];
            url.urlContent = labelValue.value;
            
            [array addObject:url];
        }
        
    }
    else
    {
        ABMultiValueRef urlInfo = ABRecordCopyValue((__bridge ABRecordRef)(aBRecordRef), kABPersonURLProperty);
        for (int m = 0; m < ABMultiValueGetCount(urlInfo); m++)
        {
            Url *url = [Url new];
            //获取电话Label
            url.urlLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(urlInfo, m));
            //获取該Label下的电话值
            url.urlContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(urlInfo,m);
            [array addObject:url];
        }
    }
    return array;
}




- (id)contactDetailViewControllerWithContactRef:(id)contactRef
{
    if ([contactRef isKindOfClass:[CNContact class]])
    {
        CNContactViewController *vc = [CNContactViewController viewControllerForContact:(CNContact *)contactRef];
        
        return vc;
    }
    else
    {
        ABPersonViewController *vc = [[ABPersonViewController alloc] init];
        
        vc.displayedPerson = (__bridge ABRecordRef _Nonnull)(contactRef);
        
        return vc;
    }
}

- (id)newContactViewControllerWithContactRef:(id)contactRef
{
    if ([UIDevice currentDevice].systemVersion.floatValue >= DiveSysVersion){
        CNContactViewController *vc = [CNContactViewController viewControllerForNewContact:contactRef];
        
        return vc;
    }else{
        
        ABNewPersonViewController *vc = [[ABNewPersonViewController alloc]init];
        
        vc.displayedPerson = (__bridge ABRecordRef _Nullable)(contactRef);
        
        return vc;
    }
    
    
}

- (BOOL)removeContactRef:(id)contactRef
{
    if ([contactRef isKindOfClass:[CNContact class]]) {
        CNSaveRequest *request = [[CNSaveRequest alloc]init];
        
        CNMutableContact *mContact = [contactRef mutableCopy];
        
        [request deleteContact:mContact];
        
        CNContactStore *store = [ContactsManager shareStore];
        
        NSError *error = nil;
        
        BOOL success = [store executeSaveRequest:request error:&error];
        
        return success;
        
    }else{
        
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
        
        ABAddressBookRemoveRecord(addressBook, (__bridge ABRecordRef)(contactRef), nil);
        
        BOOL success = ABAddressBookSave(addressBook, nil);
        
        return success;
    }
}

- (void)queryContact{
//    CNContactStore *store = [ContactsManager shareStore];
//    
//    NSPredicate *predicate = [CNContact predicateForContactsWithIdentifiers:<#(nonnull NSArray<NSString *> *)#>]
//    
}

@end



@implementation NSString (Pinyin)
+ (NSString *)transform:(NSString *)chinese
{
    NSMutableString *pinyin = [chinese mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    return [[pinyin uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

@end

@implementation NSMutableArray (Sort)
- (NSMutableArray *)sortWithKey:(NSString *)sortKey
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:YES];
    
    [self sortUsingDescriptors:@[sortDescriptor]];
    
    return self;
}
@end
