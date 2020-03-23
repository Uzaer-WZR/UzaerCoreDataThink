//
//  UzaerCoreDataThink.h
//  FWDemo
//
//  Created by qk on 2018/12/27.
//  Copyright © 2018年 Uzaer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
NS_ASSUME_NONNULL_BEGIN

@interface UzaerCoreDataThink : NSObject
{
    
}
@property(strong,nonatomic)NSManagedObjectContext *context;
//@property(assign,nonatomic)BOOL working;
@property(strong,atomic)NSFetchRequest*baseRequest;
@property(strong,nonatomic)NSString*conditions;
+(UzaerCoreDataThink*)tool;

///操作的数据库名
-(UzaerCoreDataThink*)entity:(NSString*)name;

///and条件:可传sql字符串/NSDictionary/NSArray
-(UzaerCoreDataThink*)where:(id)where;

///or条件:可传sql字符串/NSDictionary/NSArray
-(UzaerCoreDataThink*)whereOr:(id)where;

///根据某个字段倒叙查询
-(UzaerCoreDataThink*)descWith:(NSString*)key;

///根据某个字段正叙查询
-(UzaerCoreDataThink*)ascWith:(NSString*)key;

///查询limit条数据
-(UzaerCoreDataThink*)limit:(NSUInteger)limit;

///查询符合条件的多条数据
-(id)select;

///查询符合条件的第一条数据
-(id)find;

///添加一条数据
-(BOOL)insert:(NSDictionary*)dict;

///更新符合条件的数据(如没有传where 则更新所有)
-(BOOL)update:(NSDictionary*)dict;

///删除符合条件的数据(如没有传where 则删除所有)
-(BOOL)del;

/// 从offset位置开始查询count条数据(select下有效)
-(UzaerCoreDataThink*)offset:(NSUInteger)offset Count:(NSUInteger)count;

/// 查询数量
-(NSUInteger)count;
@end

NS_ASSUME_NONNULL_END
