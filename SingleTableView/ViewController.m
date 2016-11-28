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
#import "ContactsManager.h"
#import <ContactsUI/ContactsUI.h>

//#import <AddressBookUI/ABPeoplePickerNavigationController.h>
//#import <AddressBook/ABPerson.h>
//#import <AddressBookUI/ABPersonViewController.h>
//#import <AddressBook/AddressBook.h>
//
//#import <MessageUI/MessageUI.h>


@interface ViewController ()<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, ABPersonViewControllerDelegate, CNContactViewControllerDelegate, ABNewPersonViewControllerDelegate>
@property (strong, nonatomic) UITableView *tableView;

@property (nonatomic, strong) UIView *searchBackView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIButton *searchCancleBtn;

@property (nonatomic, strong) NSMutableDictionary *dataDict;
@property (nonatomic, strong) NSMutableArray *titleArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    // 解决代码上升的问题
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;
    
    self.navigationItem.title = @"通讯录";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addContact:)];
    
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editContactList:)];
    
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshContactList:)];
    
    self.navigationItem.leftBarButtonItems = @[editItem, refreshItem];
    
    _searchBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
    _searchBackView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_searchBackView];
    
    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
    _searchBar.backgroundColor = [UIColor lightGrayColor];
    _searchBar.placeholder = @"搜索";
    _searchBar.delegate = self;
    [_searchBackView addSubview:_searchBar];
    
    _searchCancleBtn = [[UIButton alloc]initWithFrame:CGRectMake( [UIScreen mainScreen].bounds.size.width, 0, 60, 40)];
    [_searchCancleBtn setTitle:@"取消" forState: UIControlStateNormal];
    [_searchCancleBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    _searchCancleBtn.backgroundColor = [UIColor lightGrayColor];
    [_searchCancleBtn addTarget:self action:@selector(cancleSearch:) forControlEvents:UIControlEventTouchUpInside];
    [_searchBackView addSubview:_searchCancleBtn];
    
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 40, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-104) style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_tableView];
    
    [self loadPerson];
}

#pragma mark - UITableViewDataSource
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

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
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

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return _titleArray;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        NSString *character = _titleArray[indexPath.section];
        
        NSMutableArray *arr = [_dataDict valueForKey:character];
        
        Contact *contact = arr[indexPath.row];
        
        BOOL success = [[ContactsManager shareManager]removeContactRef:contact.person];
        
        if (!success) {
            return;
        }
        [arr removeObject:contact];
        
        [_dataDict removeObjectForKey:character];
        
        if (arr.count == 0) {
            [_titleArray removeObject:character];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }else{
            [_dataDict setValue:arr forKey:character];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }

    }
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return _titleArray[section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *character = _titleArray[indexPath.section];
    
    NSMutableArray *arr = [_dataDict valueForKey:character];
    
    Contact *contact = arr[indexPath.row];
    
    id vc = [[ContactsManager shareManager]contactDetailViewControllerWithContactRef:contact.person];
    if ([vc isKindOfClass:[CNContactViewController class]]) {
        
        ((CNContactViewController *)vc).delegate = self;
        
    }else if ([vc isKindOfClass:[ABPersonViewController class]]) {
        
        ((ABPersonViewController *)vc).personViewDelegate = self;
    }
    
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}


#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [UIView animateWithDuration:0.25 animations:^{
        
        _searchBackView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60);
        
        _searchBar.frame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width - 60, 40);

        _searchCancleBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 60, 20, 60, 40);
        
        _tableView.frame = CGRectMake(0, 60, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-40);
        
    }];
}
- (void)cancleSearch:(UIButton *)sender{
    [self.view endEditing:YES];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [UIView animateWithDuration:1 animations:^{
        
        _searchBackView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40);
        
        _searchBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40);
        
        _searchCancleBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width, 0, 60, 40);
        
        _tableView.frame = CGRectMake(0, 40, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-104);
    }];
}



#pragma mark - CNContactViewControllerDelegate
- (BOOL)contactViewController:(CNContactViewController *)viewController shouldPerformDefaultActionForContactProperty:(CNContactProperty *)property{
    NSString *resultStr = [self getResultStrWithValue:property.value property:property];
    
    NSLog(@"%@", resultStr);
    
    return NO;
}

- (void)contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(nullable CNContact *)contact{
    if (contact == nil) {
        [viewController dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self refreshContactList:nil];
    }
}

- (NSString *)getResultStrWithValue:(id)value property:(CNContactProperty *)property{
    __block NSString *resultStr;
    if ([value isKindOfClass:[NSDate class]]) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"yyyy-MM-dd";
        resultStr = [formatter stringFromDate:value];
        
    }else if ([value isKindOfClass:[CNPostalAddress class]]) {
        
        CNPostalAddress *address = value;
        resultStr = [NSString stringWithFormat:@"%@%@%@%@(%@)",address.country, address.city, address.state, address.street, address.postalCode];
        
    }else if ([value isKindOfClass:[CNPhoneNumber class]]) {
        
        CNPhoneNumber *phone = value;
        resultStr = [NSString stringWithFormat:@"%@", phone.stringValue];
        
    }else if ([value isKindOfClass:[NSDateComponents class]]) {
        
        NSDateComponents *componets = value;
        
        resultStr = [NSString stringWithFormat:@"%04ld-%02ld-%02ld", componets.year, componets.month, componets.day];
        
    }else if ([value isKindOfClass:[CNContactRelation class]]) {
        
        CNContactRelation *relation = value;
        
        resultStr = [NSString stringWithFormat:@"name = %@", relation.name];
        
    }else if ([value isKindOfClass:[CNSocialProfile class]]) {
        
        CNSocialProfile *profile = value;
        
        resultStr = [NSString stringWithFormat:@"name = %@, url = %@", profile.username, profile.urlString];
        
    }else {
        if (value) {
            
            resultStr = value;
        }else{
            
            NSArray *arr = [property.contact valueForKey:property.key];
            
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[CNLabeledValue class]]) {
                    CNLabeledValue *value = obj;
                    if ([value.identifier isEqualToString:property.identifier]) {
                        resultStr = [self getResultStrWithValue:value.value property:nil];
                    }
                }
            }];
        }
    }
    
    return resultStr;
}

#pragma mark - ABPersonViewControllerDelegate
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
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

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(nullable ABRecordRef)person{
    if (person) {
        [self refreshContactList:nil];
    }
    [newPersonView dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 获取联系人
- (void)loadPerson{
    
    if ([[ContactsManager shareManager] authorizationStatus]) {
        
        NSArray *contactArr = [[ContactsManager shareManager] loadAllSystemContacts];
        
        [self.tableView configDefaultView:contactArr.count>0 title:@"暂无联系人" type: DefaultViewTypeDefault reloadHandler:^(UIButton *sender) {
            [self loadPerson];
        }];
        
        [self getDataDcitWithContactArr:contactArr];
        
    }else{
        
    }
}

- (void)getDataDcitWithContactArr:(NSArray *)contactArr{// 排序和分类
    
    _dataDict = [NSMutableDictionary dictionary];
    
    [contactArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        Contact *contact = (Contact *)obj;
        NSString *name = [NSString stringWithFormat:@"%@%@%@",contact.lastName?:@"",contact.firstName?:@"",contact.middlename?:@""];
        
        NSString *sortStr = [NSString transform:name].length>0?[[NSString transform:name] substringToIndex:1]:@"";
        
        if ([_dataDict valueForKey:sortStr]) {
            NSMutableArray *arr = [_dataDict valueForKey:sortStr];
            [arr addObject:contact];
            
            [arr sortWithKey:@"pinyinName"];
            
            [_dataDict removeObjectForKey:sortStr];
            [_dataDict setObject:arr forKey:sortStr];
        }else{
            NSMutableArray *arr = [NSMutableArray array];
            [arr addObject:contact];
            [_dataDict setObject:arr forKey:sortStr];
        }
        
        if (idx == contactArr.count-1) {
            
            NSMutableArray *keysArr = [NSMutableArray arrayWithArray:_dataDict.allKeys];
            
            [keysArr sortWithKey:@""];
            
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

#pragma mark - barButtonItemEvent
- (void)addContact:(UIBarButtonItem *)item{
    
    id vc = [[ContactsManager shareManager]newContactViewControllerWithContactRef:nil];
    
    if ([vc isKindOfClass:[CNContactViewController class]]) {
        
        ((CNContactViewController *)vc).delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if ([vc isKindOfClass:[ABNewPersonViewController class]]){
        
        ((ABNewPersonViewController *)vc).newPersonViewDelegate = self;
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
    }
    
    
}

- (void)editContactList:(UIBarButtonItem *)item{
    if (self.tableView.isEditing) {
        
        [self.tableView setEditing:NO animated:YES];
        item.style = UIBarButtonSystemItemAdd;
    }else{
        
        [self.tableView setEditing:YES animated:YES];
        item.style = UIBarButtonSystemItemCancel;
    }
    
}

- (void)refreshContactList:(UIBarButtonItem *)item{
    
    [_titleArray removeAllObjects];
    
    [_dataDict removeAllObjects];
    
    [self loadPerson];
    
    [self.tableView reloadData];
    
}

@end
