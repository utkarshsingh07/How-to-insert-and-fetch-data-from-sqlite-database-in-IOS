//
//  ContactsViewController.m
//  Insert_and_fetch_data_with_sqlite
//
//  Created by utk@rsh on 27/08/14.
//  Copyright (c) 2014 Utkarsh Singh. All rights reserved.
//

#import "ContactsViewController.h"
#import "AppDelegate.h" // Import appdelegate.h (check and create DB method).

// Create a object of our AppDelegate -

AppDelegate *objApp;

@interface ContactsViewController ()

@end

@implementation ContactsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Delegate for our AppDelegate -
    objApp = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    // Assing our Database Name to strDatabaseName -
    strDatabaseName = @"con.sqlite";
    
    
// ******* Right here we are inserting data to our DB from json *******
    
    // Fetching json file -
    
    // 1. create URL for our json:
    NSURL *url = [[NSBundle mainBundle]URLForResource:@"con" withExtension:@"json"];
    
    // 2. create NSURLRequest:
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30.0];
    
    // 3. create Response:
    NSURLResponse *response;
    
    // 4. Get Data:
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    [self performSelectorOnMainThread:@selector(fetchLocalData:) withObject:data waitUntilDone:true];
    
}

// Create Method for our Main thread selector -

-(void)fetchLocalData:(NSData *)data{
    int count = [self countFromDB];
    
    // Check for non-repeatation of data -
    if (!count>0) {
        
  
    NSError *error;
    
    // Perform NSJSONSerialization:
    NSArray *arrLocalData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
  
    // for loop for storing data in DB to the count of json array data:
    for (int i=0; i< arrLocalData.count; i++) {
        
        [self insertDataIntoDB:[NSString stringWithFormat:@"%@",[[arrLocalData objectAtIndex:i]valueForKey:@"id"]]:[NSString stringWithFormat:@"%@",[[arrLocalData objectAtIndex:i]valueForKey:@"name"]]: [NSString stringWithFormat:@"%@",[[arrLocalData objectAtIndex:i]valueForKey:@"lati"]]: [NSString stringWithFormat:@"%@",[[arrLocalData objectAtIndex:i]valueForKey:@"longi"]]: [NSString stringWithFormat:@"%@",[[arrLocalData objectAtIndex:i]valueForKey:@"imagename"]]];
        
     }
        
    }else{

        [self getDataFromDB];
    
    }
}


// Method for insert data into our DB through json (local Data) -
-(void)insertDataIntoDB:(NSString *)strId :(NSString *)strName :(NSString *)strLati :(NSString *)strLongi :(NSString *)strImagename {
    
    NSArray *arrPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSString *strTempPath = [arrPath objectAtIndex:0];
    strDatabasePath = [strTempPath stringByAppendingPathComponent:strDatabaseName];
    [objApp checkAndCreateData:strDatabasePath :strDatabaseName];
    
    sqlite3 *database;
    
    if (sqlite3_open([strDatabasePath UTF8String], &database)== SQLITE_OK) {
        
        // Insert Query:
        NSString *strTempQuery = [NSString stringWithFormat:@"insert into tblContactInventory (id,name,lati,longi,imagename) values ('%@','%@','%@','%@','%@')",strId,strName,strLati,strLongi,strImagename];
        
        const char *SQLQUERY = [strTempQuery UTF8String];
        
        // Define sqlite_statement:
        static sqlite3_stmt *compiledStatement;
        sqlite3_exec(database, SQLQUERY, NULL, NULL, NULL);
        sqlite3_finalize(compiledStatement);
        
    }
    // getting data from Database.
     [self getDataFromDB];
    sqlite3_close(database); // Close DB.
}

// Getting Data from Database -

-(void)getDataFromDB
{
    NSArray *arrPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSString *strTempPath = [arrPath objectAtIndex:0];
    strDatabasePath = [strTempPath stringByAppendingPathComponent:strDatabaseName];
    [objApp checkAndCreateData:strDatabasePath :strDatabaseName];
    
    sqlite3 *database;
    
    if (sqlite3_open([strDatabasePath UTF8String], &database)==SQLITE_OK){
        
        NSString*strQuery=@"SELECT * FROM tblContactInventory";
        
        const char *SQLQuery = [strQuery UTF8String];
        
        static sqlite3_stmt *compiledStatment;
        
        if (sqlite3_prepare_v2(database, SQLQuery, -1, &compiledStatment, NULL)==SQLITE_OK) {
            
            NSString *strDataDB;
            
            arrTempData = [[NSMutableArray alloc]init];
           
            while (sqlite3_step(compiledStatment)==SQLITE_ROW) {
                
            strDataDB=[NSString stringWithUTF8String:(char*) sqlite3_column_text(compiledStatment, 0)];
            strDataDB=[strDataDB stringByAppendingString:@"||"];
            strDataDB=[strDataDB stringByAppendingString:[NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStatment, 1)]];
                
            [arrTempData addObject:strDataDB];
                
            }
        }
    }
    [self.tblData reloadData]; // Reload Table.
    sqlite3_close(database); // Close DB.
}

// Method for check data already exist or Not -

-(int)countFromDB
{
    NSArray *arrPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSString *strTempPath = [arrPath objectAtIndex:0];
    strDatabasePath = [strTempPath stringByAppendingPathComponent:strDatabaseName];
    [objApp checkAndCreateData:strDatabasePath :strDatabaseName];
    
    sqlite3 *database;
    
    int count = 0;
    if (sqlite3_open([strDatabasePath UTF8String], &database)==SQLITE_OK){
        
        NSString*strQuery=@"SELECT COUNT (*) FROM tblContactInventory";
        
        const char *SQLQuery = [strQuery UTF8String];
        
        static sqlite3_stmt *compiledStatment;
        
        if (sqlite3_prepare_v2(database, SQLQuery, -1, &compiledStatment, NULL)==SQLITE_OK) {
            
            while (sqlite3_step(compiledStatment)==SQLITE_ROW) {
                count = sqlite3_column_int(compiledStatment, 0);
                
            }
        }
    }
    
    sqlite3_close(database); // Close DB.
    
    return count;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [arrTempData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSString *strTmp=[arrTempData objectAtIndex:indexPath.row];
    NSArray *arr=[strTmp componentsSeparatedByString:@"||"]; // separating the indexes || 
    
    cell.textLabel.text = [arr objectAtIndex:0];
    cell.detailTextLabel.text = [arr objectAtIndex:1];
    
    return cell;
}



@end
