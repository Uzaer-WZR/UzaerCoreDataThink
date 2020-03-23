//
//  ViewController.m
//  UzaerCoreDataThink
//
//  Created by Uzaer on 2020/3/24.
//  Copyright © 2020 Uzaer. All rights reserved.
//

#import "ViewController.h"
#import "UzaerCoreDataThink.h"
@interface ViewController ()
{
    __weak IBOutlet UITextField *ins_id;
    __weak IBOutlet UITextField *ins_name;
    __weak IBOutlet UITextField *ins_sex;
    
    __weak IBOutlet UITextField *find_id;
    
    __weak IBOutlet UITextField *del_name;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [UzaerCoreDataThink tool];
}
- (IBAction)insert:(id)sender
{
    BOOL whe=[[[UzaerCoreDataThink tool] entity:@"Test"] insert:@{@"id":ins_id.text,@"name":ins_name.text,@"sex":ins_sex.text}];
    if (whe)
    {
        NSLog(@"添加数据成功");
    }
    else
    {
        NSLog(@"添加数据失败");
    }
}
- (IBAction)select:(id)sender
{
    NSArray*arr=[[[UzaerCoreDataThink tool] entity:@"Test"] select];
    
    
    
    NSLog(@"%@",arr);
}
- (IBAction)find:(id)sender
{
    NSDictionary*dict=[[[[UzaerCoreDataThink tool] entity:@"Test"] where:@{@"id":find_id.text}] find];
    NSLog(@"%@",dict);
}
- (IBAction)del:(id)sender
{
    BOOL whe=[[[[UzaerCoreDataThink tool] entity:@"Test"] where:@{@"name":del_name.text}] del];
    if (whe)
    {
        NSLog(@"删除数据成功");
    }
    else
    {
        NSLog(@"删除数据失败");
    }
}


@end
