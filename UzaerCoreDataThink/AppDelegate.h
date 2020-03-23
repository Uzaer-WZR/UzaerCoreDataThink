//
//  AppDelegate.h
//  UzaerCoreDataThink
//
//  Created by Uzaer on 2020/3/24.
//  Copyright © 2020 Uzaer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

