//
//  AppDelegate.h
//  Insert_and_fetch_data_with_sqlite
//
//  Created by utk@rsh on 27/08/14.
//  Copyright (c) 2014 Utkarsh Singh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// Method for check the existing Data otherwise Create the Data -

-(void) checkAndCreateData: (NSString *)databasePath : (NSString *)databaseName;

@end
