//
//  FFDB.m
//  FFKit
//
//  Created by 张玲玉 on 2018/8/30.
//

#import "FFBaseDB.h"
#import <FMDB/FMDB.h>

@implementation FFBaseDB

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.version=[[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleShortVersionString"];
    }
    return self;
}

- (FMDatabase *)db
{
    if (_db.databasePath==nil) {
        _db=[FMDatabase databaseWithPath:self.path];
        _db.shouldCacheStatements=YES;
        _db.dateFormat = [FMDatabase storeableDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return _db;
}

- (NSString *)createTime
{
    if (_createTime==nil) {
        NSDateFormatter *format=[[NSDateFormatter alloc]init];
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        _createTime=[format stringFromDate:[NSDate date]];
    }
    return _createTime;
}

#pragma mark - 基本操作

- (BOOL)createTable:(NSString *)tableName andSql:(NSString *)sql
{
    if (!self.db) {
        NSLog(@"database does not exist");
        return NO;
    }
    BOOL ret=NO;
    if ([self.db open]) {
        if (![self existsTable:tableName])
        {
            if ([self.db executeUpdate:sql]) {
                NSLog(@"%@ create table success",tableName);
                ret=YES;
            }
            else{
                NSLog(@"%@ create table fail",tableName);
            }
        }else {
            NSLog(@"%@ table is already exist",tableName);
        }
        [self.db close];
    }
    else{
        NSLog(@"database fail to open");
    }
    return ret;
}

- (BOOL)deleteTable:(NSString *)tableName
{
    if (!self.db) {
        NSLog(@"database does not exist");
        return NO;
    }
    BOOL ret=NO;
    if ([self.db open]) {
        NSMutableString *sql=[NSMutableString stringWithFormat:@"drop table %@",tableName];
        if ([self.db executeUpdate:sql]) {
            NSLog(@"%@ delete table success",tableName);
            ret=YES;
        }
        else{
            NSLog(@"%@ delete table fail",tableName);
        }
        [self.db close];
    }
    else{
        NSLog(@"database fail to open");
    }
    return ret;
}

- (BOOL)existsTable:(NSString *)tableName
{
    if (!self.db) {
        NSLog(@"database does not exist");
        return NO;
    }
    if ([self.db open]) {
        FMResultSet *result = [self.db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
        while ([result next])
        {
            NSInteger count = [result intForColumn:@"count"];
            NSLog(@"%@",[NSString stringWithFormat:@"table exists:%ld", (long)count]);
            if (count == 0){
                return NO;
            }
            else{
                return YES;
            }
        }
        [self.db close];
    }
    return NO;
}

@end
