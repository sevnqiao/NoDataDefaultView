//
//  ViewController.m
//  SingleTableView
//
//  Created by xiong on 16/8/29.
//  Copyright © 2016年 xiong. All rights reserved.
//

#import "ViewController.h"
#import "UIView+NoDataDefaultView.h"
#import "Contact.h"

#import <AddressBookUI/ABPeoplePickerNavigationController.h>
#import <AddressBook/ABPerson.h>
#import <AddressBookUI/ABPersonViewController.h>
#import <AddressBook/AddressBook.h>


@interface ViewController ()<ABPeoplePickerNavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource,ABPersonViewControllerDelegate>
@property (strong, nonatomic) UITableView         *tableView;
@property (nonatomic, strong) NSMutableDictionary *dataDict;
@property (nonatomic, strong) NSMutableArray *titleArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.title = @"通讯录";
    
    _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    [self loadPerson];
}


#pragma mark - UITableViewDelegate/UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return _titleArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    NSString *character = _titleArray[section];
    
    NSMutableArray *arr = [_dataDict valueForKey:character];
    
    if(arr.count>0){

        return arr.count;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identify"];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"identify"];
    }

    NSString *character = _titleArray[indexPath.section];
    
    NSMutableArray *arr = [_dataDict valueForKey:character];
    
    Contact *contact = arr[indexPath.row];
    NSString *name = [NSString stringWithFormat:@"%@%@%@",contact.lastName?:@"",contact.firstName?:@"",contact.middlename?:@""];
    if (name.length == 0) {
         cell.textLabel.text  = [contact.phone.firstObject personPhone];
    }else{
         cell.textLabel.text  = name;
    }
   


    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _titleArray[section];
}



#pragma mark - 右侧索引
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _titleArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSInteger count = 0;
    
    for(NSString *character in _titleArray)
    {
        if([character isEqualToString:title]){
            
            return count;
        }
        count ++;
    }
    return 0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *character = _titleArray[indexPath.section];
    
    NSMutableArray *arr = [_dataDict valueForKey:character];
    
    Contact *contact = arr[indexPath.row];
    
    ABPersonViewController *nav = [[ABPersonViewController alloc] init];
    
    nav.personViewDelegate = self;
    
    nav.navigationItem.title = [NSString stringWithFormat:@"%@%@%@",contact.lastName?:@"",contact.firstName?:@"",contact.middlename?:@""];

    nav.displayedPerson = contact.aBRecordRef;
    
    [self.navigationController pushViewController:nav animated:YES];
}


- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    NSMutableString *returnStr = [NSMutableString string];

    switch (property) {
//        case   3://  3:电话
//        case   4://  4:邮箱
//        case   5://  5:地址
//        case  12:// 12:纪念日
//        case  13:// 13:qq
//        case  22:// 22:网址
//        case  23:// 23:亲属
//        case  46:// 46:微博
            
//        case 999://999:生日
//            return NO;
//            break;
    }
    id value;
    
    if (property == 999) { // 这里很奇怪  生日的这个 property 返回的一直是999 正常来说不是999 , 原因未知
        value = (__bridge NSDictionary *)(ABRecordCopyValue(person, kABPersonBirthdayProperty));
    }else{
        value = (__bridge id)(ABMultiValueCopyValueAtIndex(ABRecordCopyValue(person, property), ABMultiValueGetIndexForIdentifier(ABRecordCopyValue(person, property),identifier)));
    }
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = value;
        [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {

            [returnStr appendString:[NSString stringWithFormat:@"\n%@=%@",key, obj]];
            
        }];
    }else if ([value isKindOfClass:[NSDate class]]){
        NSDate *date = value;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"yyyy-MM-dd";
        
        returnStr = [NSMutableString stringWithString:[formatter stringFromDate:date]];
    }else{

        if([value hasPrefix:@"+"]){
            value = [value substringFromIndex:3];
        }
        returnStr = (NSMutableString *)[value stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
        
     
    }
    NSLog(@"%@",returnStr);
    return NO;
    
    
}

#pragma mark - 获取联系人
- (void)loadPerson{
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error){
            
            CFErrorRef *error1 = NULL;
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error1);
            [self copyAddressBook:addressBook];
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        [self copyAddressBook:addressBook];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 更新界面
            //            [hud turnToError:@"没有获取通讯录权限"];
        });
    }
}

// 转换为联系人实体
- (void)copyAddressBook:(ABAddressBookRef)addressBook{
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    NSMutableArray *contactArr = [NSMutableArray array];
    
    for ( int i = 0; i < numberOfPeople; i++){
        Contact *contact = [Contact new];
        
        contact.aBRecordRef = addressBook;
        
        ABRecordRef person = CFArrayGetValueAtIndex(people, i);
        
        contact.aBRecordRef = person;
        
        contact.firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        contact.lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
        
        //读取middlename
        contact.middlename = (__bridge NSString*)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
        
        contact.pinyinName = [self transform:[NSString stringWithFormat:@"%@%@%@",contact.lastName?:@"" ,contact.firstName?:@"" ,contact.middlename?:@"" ]];
        
        //读取prefix前缀
        contact.prefix = (__bridge NSString*)ABRecordCopyValue(person, kABPersonPrefixProperty);
        //读取suffix后缀
        contact.suffix = (__bridge NSString*)ABRecordCopyValue(person, kABPersonSuffixProperty);
        //读取nickname呢称
        contact.nickname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonNicknameProperty);
        //读取firstname拼音音标
        contact.firstnamePhonetic = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNamePhoneticProperty);
        //读取lastname拼音音标
        contact.lastnamePhonetic = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNamePhoneticProperty);
        //读取middlename拼音音标
        contact.middlenamePhonetic = (__bridge NSString*)ABRecordCopyValue(person, kABPersonMiddleNamePhoneticProperty);
        //读取organization公司
        contact.organization = (__bridge NSString*)ABRecordCopyValue(person, kABPersonOrganizationProperty);
        //读取jobtitle工作
        contact.jobtitle = (__bridge NSString*)ABRecordCopyValue(person, kABPersonJobTitleProperty);
        //读取department部门
        contact.department = (__bridge NSString*)ABRecordCopyValue(person, kABPersonDepartmentProperty);
        //读取birthday生日
        contact.birthday = (__bridge NSDate*)ABRecordCopyValue(person, kABPersonBirthdayProperty);
        //读取note备忘录
        contact.note = (__bridge NSString*)ABRecordCopyValue(person, kABPersonNoteProperty);
        //第一次添加该条记录的时间
        contact.firstknow = (__bridge NSString*)ABRecordCopyValue(person, kABPersonCreationDateProperty);
        //最后一次修改該条记录的时间
        contact.lastknow = (__bridge NSString*)ABRecordCopyValue(person, kABPersonModificationDateProperty);
        
        //获取email多值
        ABMultiValueRef emailInfo = ABRecordCopyValue(person, kABPersonEmailProperty);
        
        for (int x = 0; x < ABMultiValueGetCount(emailInfo); x++)
        {
            Email *email = [Email new];
            //获取email Label
            email.emailLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(emailInfo, x));
            //获取email值
            email.emailContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emailInfo, x);
            
            [contact.emails addObject:email];
        }
        //读取地址多值
        ABMultiValueRef addressInfo = ABRecordCopyValue(person, kABPersonAddressProperty);
        
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
            
            [contact.address addObject:address];
        }
        
        //获取dates多值
        ABMultiValueRef datesInfo = ABRecordCopyValue(person, kABPersonDateProperty);
        
        for (int y = 0; y < ABMultiValueGetCount(datesInfo); y++)
        {
            Date *date = [Date new];
            
            date.datesLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(datesInfo, y));
            date.datesContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(datesInfo, y);
            
            [contact.dates addObject:date];
        }
        //获取kind值
        //        CFNumberRef recordType = ABRecordCopyValue(person, kABPersonKindProperty);
        //        if (recordType == kABPersonKindOrganization) {
        //            // it's a company
        //            NSLog(@"it's a company\n");
        //        } else {
        //            // it's a person, resource, or room
        //            NSLog(@"it's a person, resource, or room\n");
        //        }
        
        
        //获取IM多值
        ABMultiValueRef instantMessage = ABRecordCopyValue(person, kABPersonInstantMessageProperty);
        for (int l = 1; l < ABMultiValueGetCount(instantMessage); l++)
        {
            Message *message = [Message new];
            //获取IM Label
            message.instantMessageLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(instantMessage, l);
            //获取該label下的2属性
            NSDictionary* instantMessageContent =(__bridge NSDictionary*) ABMultiValueCopyValueAtIndex(instantMessage, l);
            message.username = [instantMessageContent valueForKey:(NSString *)kABPersonInstantMessageUsernameKey];
            
            message.service = [instantMessageContent valueForKey:(NSString *)kABPersonInstantMessageServiceKey];
            
            [contact.instantMessage addObject:message];
        }
        
        //读取电话多值
        ABMultiValueRef phoneInfo = ABRecordCopyValue(person, kABPersonPhoneProperty);
        for (int k = 0; k<ABMultiValueGetCount(phoneInfo); k++)
        {
            Phone *phone = [Phone new];
            //获取电话Label
            phone.personPhoneLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phoneInfo, k));
            //获取該Label下的电话值
            phone.personPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phoneInfo, k);
            
            [contact.phone addObject:phone];
        }
        
        //获取URL多值
        ABMultiValueRef urlInfo = ABRecordCopyValue(person, kABPersonURLProperty);
        for (int m = 0; m < ABMultiValueGetCount(urlInfo); m++)
        {
            Url *url = [Url new];
            //获取电话Label
            url.urlLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(urlInfo, m));
            //获取該Label下的电话值
            url.urlContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(urlInfo,m);
            
            [contact.url addObject:url];
        }
        
        //读取照片
        contact.image = (__bridge NSData*)ABPersonCopyImageData(person);
        
        [contactArr addObject:contact];
    }
    
    [self.tableView configDefaultView:contactArr.count>0 title:@"暂无联系人" type: DefaultViewTypeDefault reloadHandler:^(UIButton *sender) {
        [self loadPerson];
    }];
    
    [self getDataDcitWithContactArr:contactArr];
}

- (void)getDataDcitWithContactArr:(NSArray *)contactArr{
    
    _dataDict = [NSMutableDictionary dictionary];
    
    [contactArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx != contactArr.count-1) {
            
            Contact *contact = (Contact *)obj;
            NSString *name = [NSString stringWithFormat:@"%@%@%@",contact.lastName?:@"",contact.firstName?:@"",contact.middlename?:@""];
            
            NSString *sortStr = [self transform:name].length>0?[[self transform:name] substringToIndex:1]:@"";
            
            if ([_dataDict valueForKey:sortStr]) {
                NSMutableArray *arr = [_dataDict valueForKey:sortStr];
                [arr addObject:contact];
                
                [self sortArray:arr withKey:@"pinyinName"];
                
                [_dataDict removeObjectForKey:sortStr];
                [_dataDict setObject:arr forKey:sortStr];
            }else{
                NSMutableArray *arr = [NSMutableArray array];
                [arr addObject:contact];
                [_dataDict setObject:arr forKey:sortStr];
            }

        }else{
            
            NSMutableArray *keysArr = [NSMutableArray arrayWithArray:_dataDict.allKeys];
            
            [self sortArray:keysArr withKey:@""];
            
            _titleArray = [NSMutableArray arrayWithArray:keysArr];
            
            NSMutableArray *tempArr = _titleArray;
            
            [tempArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if ([obj length] == 0) {
                    [_titleArray removeObject:obj];
                    
                    [_titleArray addObject:@"#"];
                    
                    NSMutableArray *arr = [_dataDict objectForKey:obj];
                    
                    [_dataDict removeObjectForKey:obj];
                    
                    [_dataDict setObject:arr forKey:@"#"];
                }
                
            }];

            [_tableView reloadData];
        }
        
        
    }];
}

- (NSString *)transform:(NSString *)chinese
{
    NSMutableString *pinyin = [chinese mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    return [[pinyin uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (void)sortArray:(NSMutableArray *)arr withKey:(NSString *)sortKey{
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:YES];
    
    [arr sortUsingDescriptors:@[sortDescriptor]];

}
@end
