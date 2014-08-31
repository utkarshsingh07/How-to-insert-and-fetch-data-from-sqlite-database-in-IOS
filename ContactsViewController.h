//
//  ContactsViewController.h
//  Insert_and_fetch_data_with_sqlite
//
//  Created by utk@rsh on 27/08/14.
//  Copyright (c) 2014 Utkarsh Singh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h> // Import sqlite3 header

@interface ContactsViewController : UITableViewController < UITableViewDataSource, UITableViewDelegate > {
    
    NSString *strDatabasePath; // string for database path.
    NSString *strDatabaseName; // string for database name.
    
     // declare our sqlite3 database.
    
    NSMutableArray *arrTempData; // NSMutable Array for store the fetched data.
    
}
@property (strong, nonatomic) IBOutlet UITableView *tblData;

@end
