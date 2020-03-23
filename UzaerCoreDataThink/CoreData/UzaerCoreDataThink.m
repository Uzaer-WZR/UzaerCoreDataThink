//
//  UzaerCoreDataThink.m
//  FWDemo
//
//  Created by qk on 2018/12/27.
//  Copyright © 2018年 Uzaer. All rights reserved.
//

#import "UzaerCoreDataThink.h"
#import <objc/runtime.h>
#import <objc/message.h>
@implementation UzaerCoreDataThink
@synthesize context;
-(instancetype)init
{
    self=[super init];
    if (self)
    {
        
    }
    return self;
}
+(instancetype)new
{
    UzaerCoreDataThink*obj=[super new];
    if (self)
    {
        obj.context=[UzaerCoreDataThink newTool].context;
    }
    return obj;
}
+(UzaerCoreDataThink*)newTool
{
    static UzaerCoreDataThink*db=nil;
    if (!db)
    {
        db=[[UzaerCoreDataThink alloc] init];
        [db run];
    }
    return db;
}
+(UzaerCoreDataThink*)tool
{
    return [UzaerCoreDataThink new];
}
-(void)run
{
    // 1. 上下文
    context = [[NSManagedObjectContext alloc] initWithConcurrencyType:(NSPrivateQueueConcurrencyType)];
    // 2. 上下文关连数据库
    // 2.1 model模型文件
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    // 2.2 持久化存储调度器
    // 持久化，把数据保存到一个文件，而不是内存
    NSPersistentStoreCoordinator *store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    //    [store persistentStoreCoordinator];
    // 2.3 设置CoreData数据库的名字和路径
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleName"];
    
    NSString *sqlitePath = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",app_Name]];
    
    NSLog(@"sqlitePath:%@",sqlitePath);
    
    //预防数据库更新时,旧版与新版数据库不同导致错误而奔溃
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    [store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:sqlitePath] options:options error:nil];
    
    context.persistentStoreCoordinator = store;
}
- (id)sendObjcMsg:(id)_target _sel:(SEL)_sel withObj:(id)_obj
{
    id (*objc_msgSendTyped)(id self, SEL _cmd, id _ddservice) = (id (*)(id self, SEL _cmd, id _ddservice))objc_msgSend;
    return objc_msgSendTyped(_target, _sel, _obj);
}

-(UzaerCoreDataThink*)entity:(NSString*)name
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:name];
    self.baseRequest=request;
    return self;
}
-(BOOL)insert:(NSDictionary*)dict
{
    if (!dict)
    {
        return NO;
    }
    id obj=[NSEntityDescription insertNewObjectForEntityForName:self.baseRequest.entityName inManagedObjectContext:context];
    NSArray*keyNames=[dict allKeys];
    for (int i=0; i<keyNames.count; i++)
    {
        NSString*keyName=keyNames[i];
        NSString*firstChar = [keyNames[i] substringWithRange:NSMakeRange(0,1)];
        firstChar = [firstChar uppercaseString];//转成大写
        NSString *keyname = [keyName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstChar];
        if([[dict objectForKey:keyNames[i]] isEqual:[NSNull null]])
        {
            continue;
        }
        NSString*value=[NSString stringWithFormat:@"%@",[dict objectForKey:keyNames[i]]];
        #if (TARGET_IPHONE_SIMULATOR)
        // 在模拟器的情况下
        NSLog(@"模拟器");
        objc_msgSend(obj, NSSelectorFromString([NSString stringWithFormat:@"set%@:",keyname]),value);
        #else
        // 在真机情况下
        NSLog(@"真机");
        [self sendObjcMsg:obj _sel:NSSelectorFromString([NSString stringWithFormat:@"set%@:",keyname]) withObj:value];
        #endif
    }
    NSError *error = nil;
    [context save:&error];
    self.conditions=@"";
    if (error) {
        NSLog(@"%@",error);
        return NO;
    }
    return YES;
}
-(UzaerCoreDataThink*)where:(id)where
{
    if (!self.conditions||self.conditions.length==0)
    {
        self.conditions=[NSString stringWithFormat:@"%@",[self whereInObj:where]];
    }
    else
    {
        self.conditions=[NSString stringWithFormat:@"%@ && %@",self.conditions,[self whereInObj:where]];
    }
    return self;
}
-(UzaerCoreDataThink*)whereOr:(id)where
{
    if (!self.conditions||self.conditions.length==0)
    {
        self.conditions=[NSString stringWithFormat:@"%@",[self whereInObj:where]];
    }
    else
    {
        self.conditions=[NSString stringWithFormat:@"%@ || %@",self.conditions,[self whereInObj:where]];
    }
    return self;
}
-(UzaerCoreDataThink*)descWith:(NSString*)key
{
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:key ascending:NO];
    self.baseRequest.sortDescriptors = [NSArray arrayWithObject:sort];
    return self;
}
-(UzaerCoreDataThink*)ascWith:(NSString*)key
{
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:key ascending:YES];
    self.baseRequest.sortDescriptors = [NSArray arrayWithObject:sort];
    return self;
}
-(UzaerCoreDataThink*)limit:(NSUInteger)limit
{
    self.baseRequest.fetchLimit=limit;
    return self;
}

-(UzaerCoreDataThink*)offset:(NSUInteger)offset Count:(NSUInteger)count
{
    self.baseRequest.fetchLimit=count;
    self.baseRequest.fetchOffset=offset;
    return self;
}
-(NSUInteger)count
{
    if (self.conditions&&self.conditions.length>0)
    {
        NSPredicate *pre = [NSPredicate predicateWithFormat:self.conditions];
        self.baseRequest.predicate = pre;
    }
    NSUInteger count = [context countForFetchRequest:self.baseRequest error:nil];
    self.conditions=@"";
    return count;
}
-(id)find
{
//    NSLog(@"self.conditions:%@",self.conditions);
    if (self.conditions&&self.conditions.length>0)
    {
        NSPredicate *pre = [NSPredicate predicateWithFormat:self.conditions];
        self.baseRequest.predicate = pre;
    }
    //发送请求
    NSArray *resArray = [context executeFetchRequest:self.baseRequest error:nil];
    self.conditions=@"";
    //修改
    NSLog(@"---%@",[resArray class]);
    if(resArray&&resArray.count>0)
    {
        id obj=resArray[0];
        NSArray*proper=[self getAllPropertiesFor:obj];
        NSMutableDictionary*mutableDict=[[NSMutableDictionary alloc]init];
        for (int j=0; j<proper.count; j++)
        {
            NSString*keyName=proper[j];
            #if (TARGET_IPHONE_SIMULATOR)
            id pObj=objc_msgSend(obj, NSSelectorFromString([NSString stringWithFormat:@"%@",keyName]),nil);
            #else
            id pObj=[self sendObjcMsg:obj _sel:NSSelectorFromString([NSString stringWithFormat:@"%@",keyName]) withObj:nil];
            #endif
            if (!pObj)
            {
                pObj=@"";
            }
            [mutableDict setObject:pObj forKey:keyName];
        }
        return [NSDictionary dictionaryWithDictionary:mutableDict];
    }
    else
    {
        return nil;
    }
}
-(id)select
{
    NSLog(@"self.conditions:%@",self.conditions);
    if (self.conditions&&self.conditions.length>0)
    {
        NSPredicate *pre = [NSPredicate predicateWithFormat:self.conditions];
        self.baseRequest.predicate = pre;
    }
    //发送请求
    NSArray *resArray = [context executeFetchRequest:self.baseRequest error:nil];
    //    NSLog(@"%@",resArray);
    //修改
    self.conditions=@"";
    if(resArray)
    {
        NSMutableArray*resMutableArr=[[NSMutableArray alloc]init];
        for (int i=0; i<resArray.count; i++)
        {
            id obj=resArray[i];
            NSArray*proper=[self getAllPropertiesFor:obj];
            NSMutableDictionary*mutableDict=[[NSMutableDictionary alloc]init];
            for (int j=0; j<proper.count; j++)
            {
                NSString*keyName=proper[j];
                #if (TARGET_IPHONE_SIMULATOR)
                id pObj=objc_msgSend(obj, NSSelectorFromString([NSString stringWithFormat:@"%@",keyName]),nil);
                #else
                id pObj=[self sendObjcMsg:obj _sel:NSSelectorFromString([NSString stringWithFormat:@"%@",keyName]) withObj:nil];
                #endif
                [mutableDict setObject:pObj?pObj:@"" forKey:keyName];
            }
            [resMutableArr addObject:mutableDict];
        }
        return [NSArray arrayWithArray:resMutableArr];
    }
    else
    {
        return nil;
    }
}
-(BOOL)update:(NSDictionary*)dict
{
    NSLog(@"self.conditions:%@",self.conditions);
    if (self.conditions&&self.conditions.length>0)
    {
        NSPredicate *pre = [NSPredicate predicateWithFormat:self.conditions];
        self.baseRequest.predicate = pre;
    }
    //发送请求
    NSArray *resArray = [context executeFetchRequest:self.baseRequest error:nil];
    
    NSArray*keyNames=[dict allKeys];
    for (id obj in resArray) {
        for (int i=0; i<keyNames.count; i++)
        {
            NSString*keyName=keyNames[i];
            NSString*firstChar = [keyNames[i] substringWithRange:NSMakeRange(0,1)];
            firstChar = [firstChar uppercaseString];//转成大写
            NSString *keyname = [keyName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstChar];
            if([[dict objectForKey:keyNames[i]] isEqual:[NSNull null]])
            {
                continue;
            }
            NSString*value=[NSString stringWithFormat:@"%@",[dict objectForKey:keyNames[i]]];
#if (TARGET_IPHONE_SIMULATOR)
            objc_msgSend(obj, NSSelectorFromString([NSString stringWithFormat:@"set%@:",keyname]),value);
#else
            [self sendObjcMsg:obj _sel:NSSelectorFromString([NSString stringWithFormat:@"set%@:",keyname]) withObj:value];
#endif
        }
    }
    
    //保存
    self.conditions=@"";
    NSError *error = nil;
    if ([context save:&error]) {
        return YES;
    }else{
        NSLog(@"更新数据失败, %@", error);
        return NO;
    }
    return NO;
}
-(BOOL)del
{
//    NSLog(@"self.conditions:%@",self.conditions);
    if (self.conditions&&self.conditions.length>0)
    {
        NSPredicate *pre = [NSPredicate predicateWithFormat:self.conditions];
        self.baseRequest.predicate = pre;
    }
    //发送请求
    NSArray *resArray = [context executeFetchRequest:self.baseRequest error:nil];
    for (id obj in resArray) {
        [context deleteObject:obj];
    }
    NSError *error = nil;
    self.conditions=@"";
    if ([context save:&error]) {
        return YES;
    }else{
        NSLog(@"删除数据失败,%@", error);
        return NO;
    }
    return NO;
}
-(NSArray*)getAllPropertiesFor:(id)sender
{
    u_int count;
    objc_property_t*properties =class_copyPropertyList([sender class], &count);
    NSMutableArray*propertiesArray = [NSMutableArray arrayWithCapacity:count];
    for(int i =0; i<count; i++)
    {
        const char* propertyName =property_getName(properties[i]);
        [propertiesArray addObject: [NSString stringWithUTF8String: propertyName]];
    }
    free(properties);
    return propertiesArray;
}
-(NSString*)whereInObj:(id)obj
{
    if([obj isKindOfClass:[NSString class]])
    {
        return obj;
    }
    else if ([obj isKindOfClass:[NSDictionary class]])
    {
        NSString*where=@"";
        NSArray*keys=[obj allKeys];
        for (int i=0; i<keys.count; i++)
        {
            NSString*where0=[NSString stringWithFormat:@"%@ == '%@'",keys[i],[obj objectForKey:keys[i]]];
            if (i==0)
            {
                if (keys.count>1)
                {
                    where=[NSString stringWithFormat:@"( %@",where0];
                }
                else
                {
                    where=[NSString stringWithFormat:@"( %@ )",where0];
                }
            }
            else if(i==(keys.count-1))
            {
                where=[NSString stringWithFormat:@"%@ && %@ )",where,where0];
            }
            else
            {
                where=[NSString stringWithFormat:@"%@ && %@ ",where,where0];
            }
        }
        return where;
    }
    else if ([obj isKindOfClass:[NSArray class]])
    {
        NSString*where=@"";
        NSArray*objs=[NSArray arrayWithArray:obj];
        for (int i=0; i<objs.count; i++)
        {
            NSString*where0=[NSString stringWithFormat:@"%@",objs[i]];
            if (i==0)
            {
                where=[NSString stringWithFormat:@"%@",where0];
            }
            else
            {
                where=[NSString stringWithFormat:@"%@ && %@",where,where0];
            }
        }
        return where;
    }
    return @"";
}
-(void)dealloc
{
    NSLog(@"释放%@",[self class]);
}
@end
