# UzaerCoreDataThink
iOS原生数据库Coredata快捷操作

# 因使用到runtime 顾请将项目中的 Enable Strict Checking of objc_msgSend Calls 设置为NO;

coredata建表
![Image](https://raw.githubusercontent.com/siyecao/image-folder/master/images/file_watchers.png)

coredata数据库增删改查等操作

1.增
[[[UzaerCoreDataThink tool] entity:@"数据表名"] insert:@{@"数据库字段名":@"数据",@"key":@"value"}];

2.删
[[[[UzaerCoreDataThink tool] entity:@"数据表名"] where:@{@"key":@"value"}] del];

3.改
[[[[UzaerCoreDataThink tool] entity:@"数据表名"] where:@{@"key":@"value"}] update:@{@"key":@"new_value"}];

4.查
[[[UzaerCoreDataThink tool] entity:@"Test"] select];//查询多条数据
[[[[UzaerCoreDataThink tool] entity:@"Test"] where:@{@"id":find_id.text}] find];//查询单挑数据


where方法:
where是指条件
可传原生sql语句如 @" id == 1 ";  @" name <> 'uzaer'";  模糊查询:@" value like[cd] '*key*'";
可传字典NSDictionary 如 @{@"id":@"8",@"name":@"uzaer"}; 则将自动转变为sql语句: @" id == 8 && name == 'uzaer'";
也可传数组NSArray 数组中为NSDictionary的集合，规则跟传NSDictionary相同

where方法可以连续多个叠加 如:[[[[[UzaerCoreDataThink tool] entity:@"数据表名"] where:@{@"key0":@"value0"}] where:@"value1 like[cd] '*key1*'"] find];

whereOr方法:
用法与where相同，与where配合使用可以进行or查询 如 [[DB where:@{@"key0":@"value0"}] whereOr:@{@"key1":@"value1"}];
则等同的sql语句为: @"key0 == value0 || key1 == value1";

descWith ascWith 方法:
分别是倒序 正序查询
如按照字段id倒叙查询 [[DB descWith:@"id"] select];

limit方法：
自定义返回数据数量
[[[DB descWith:@"id"] limit:10] select];//查询10条数据

offset:Count:方法
从某个位置开始查询一定条数据
[[[DB descWith:@"id"] offset:50 Count::10] select];//从第50条数据开始 查询10条数据

count方法
查询符合条件的数据量，如where不传，则返回整个表数据条数

完整查询示例:[[[[[[UzaerCoreDataThink tool] entity:@"表名"] where:@{@"name":@"uzaer"}] where:@"id > 1"] offset:0 Count:50] select];
