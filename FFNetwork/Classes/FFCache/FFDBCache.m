//
//  FFDBCache.m
//  FFKit
//
//  Created by 张玲玉 on 2018/8/30.
//

#import "FFDBCache.h"
#import "FFCacheManager.h"

@implementation FFDBCacheModel

@end

@interface FFDBCache ()

@property(nonatomic,copy)NSString *createTableSql;

@end

@implementation FFDBCache

- (NSString *)createTableSql
{
    if (_createTableSql==nil) {
        NSMutableString *sql=[NSMutableString stringWithFormat:kCreateTable_Sql,self.tableName];
        [sql insertString:@",key char" atIndex:sql.length-1];
        [sql insertString:@",size integer" atIndex:sql.length-1];
        [sql insertString:@",data text" atIndex:sql.length-1];
        [sql insertString:@",type integer" atIndex:sql.length-1];
        [sql insertString:@",version char" atIndex:sql.length-1];
        [sql insertString:@",createTime char" atIndex:sql.length-1];
        _createTableSql=sql;
    }
    return _createTableSql;
}

- (instancetype)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        self.path=path;
        self.tableName=@"FFCache";
        [self createTable:self.tableName andSql:self.createTableSql];
    }
    return self;
}

- (void)setData:(NSData *)data forKey:(NSString *)key cacheType:(FFDiskCacheType)type
{
    NSData *cacheData=data;
    if (type==FFDiskCacheTypeFile) {
        cacheData=nil;
    }
    BOOL ret=[self.db open];
    if (ret) {
        NSMutableString *sql1=[NSMutableString stringWithFormat:@"delete from %@ where key='%@'",self.tableName,key];
        ret=[self.db executeUpdate:sql1];
        
        NSString *sql2=[NSString stringWithFormat:@"insert into %@(key,size,data,type,version,createTime) values(?,?,?,?,?,?)",self.tableName];
        ret=[self.db executeUpdate:sql2,key,@(data.length),cacheData,@(type),[FFCacheManager getVersion],self.createTime];
        
        [self.db close];
    }
}

- (FFDBCacheModel *)dataForKey:(NSString *)key
{
    FFDBCacheModel *dbCacheModel=[[FFDBCacheModel alloc]init];
    if ([self.db open]) {
        NSString *sql=[NSString stringWithFormat:@"select * from %@ where key='%@'",self.tableName,key];
        FMResultSet *result = [self.db executeQuery:sql];
        while ([result next]){
            dbCacheModel.key=[result stringForColumn:@"key"];
            dbCacheModel.size=[result intForColumn:@"size"];
            dbCacheModel.data=[result dataForColumn:@"data"];
            dbCacheModel.type=[result intForColumn:@"type"];
            dbCacheModel.version=[result stringForColumn:@"version"];
            dbCacheModel.createTime=[result stringForColumn:@"createTime"];
        }
        [self.db close];
    }
    return dbCacheModel;
}

- (void)removeDataForKey:(NSString *)key
{
    BOOL ret=[self.db open];
    if (ret) {
        NSMutableString *sql=[NSMutableString stringWithFormat:@"delete from %@ where key='%@'",self.tableName,key];
        ret=[self.db executeUpdate:sql];
        [self.db close];
    }
}

- (NSUInteger)getSumSize
{
    NSInteger sumSize=0;
    if ([self.db open]) {
        NSString *sql=[NSString stringWithFormat:@"select sum(size) as sumSize from %@",self.tableName];
        FMResultSet *result = [self.db executeQuery:sql];
        while ([result next]){
            sumSize=[result intForColumn:@"sumSize"];
        }
        [self.db close];
    }
    return sumSize;
}

@end
