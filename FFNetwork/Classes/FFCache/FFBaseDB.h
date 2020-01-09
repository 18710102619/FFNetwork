//
//  FFDB.h
//  FFKit
//
//  Created by 张玲玉 on 2018/8/30.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>

#define kCreateTable_Sql @"create table if not exists %@(id integer primary key autoincrement)"

typedef void(^FFDBResultBlock)(BOOL ret);

@interface FFBaseDB : NSObject

@property(nonatomic,copy)NSString *path;
@property(nonatomic,strong)FMDatabase *db;
@property(nonatomic,copy)NSString *tableName;
@property(nonatomic,copy)NSString *version;
@property(nonatomic,copy)NSString *createTime;

#pragma mark - 基本操作
- (BOOL)createTable:(NSString *)tableName andSql:(NSString *)sql;
- (BOOL)deleteTable:(NSString *)tableName;
- (BOOL)existsTable:(NSString *)tableName;

@end
