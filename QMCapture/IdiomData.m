//
//  IdiomData.m
//  QMCapture
//
//  Created by 刘永生 on 15/7/23.
//  Copyright (c) 2015年 刘永生. All rights reserved.
//
/**
 *  成语
 */
#import "IdiomData.h"

#import <FMDB.h>
#import <GDataXMLNode.h>
#import <AFNetworking.h>
#import <SVProgressHUD.h>

@implementation IdiomData

+ (void)idiomList:(void (^)(id aData, NSError *error))block {
    
    NSMutableArray *mutableOperations = [NSMutableArray array];
//    458
    for (int index = 1; index < 2; index++) {
        
        NSString * tempUrlStr  =  [NSString stringWithFormat:@"http://chengyu.supfree.net/small.asp?id=4&page=%d",index];
        
        NSURL *url3 = [NSURL URLWithString:tempUrlStr];
        
        NSURLRequest *request3 = [NSURLRequest requestWithURL:url3];
        
        AFHTTPRequestOperation *operation3 = [[AFHTTPRequestOperation alloc] initWithRequest:request3];
        
        [operation3 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            
            [IdiomData parseFengshuList:responseObject];
            
            NSLog(@"%@",operation.request.URL);
            //            NSLog(@"Response3: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"Error: %@", error);
            
        }];
        
        [mutableOperations addObject:operation3];
        
    }
    
    
    
    NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:mutableOperations
                                                               progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations)
                           {
                               
                               float value = (float)numberOfFinishedOperations/totalNumberOfOperations;
                               [SVProgressHUD showProgress:value status:[NSString stringWithFormat:@"%.2f%%",value*100] maskType:SVProgressHUDMaskTypeBlack] ;
                               
                               NSLog(@"%lu of %lu complete", numberOfFinishedOperations, totalNumberOfOperations);
                               
                               if (numberOfFinishedOperations == totalNumberOfOperations) {
                                   
                                    block(@"asdf",nil);
                                   
                               }
                               
                               
                           } completionBlock:^(NSArray *operations) {
                               
                               //                               NSLog(@"All operations in batch complete: %@",operations);
                               
                           }];
    
    [[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];
    
    
}

+ (NSArray *)parseFengshuList:(id)response {
    
    NSMutableArray * mainArray = [NSMutableArray array];
    
    @autoreleasepool {
        GDataXMLDocument * doc = [[GDataXMLDocument alloc]initWithHTMLData:response
                                                                  encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)
                                                                     error:NULL];
        if (doc) {
            
            NSArray * trArray = [doc nodesForXPath:@"//div[@class='cdiv']" error:NULL];
            
            for (GDataXMLElement * item0 in trArray) {
                
                NSArray * tr = [item0 elementsForName:@"ul"];
                
                for (GDataXMLElement * item1 in tr) {
                    
                    NSArray * td = [item1 elementsForName:@"li"];
                    
                    for (GDataXMLElement * item2 in td) {
                        
                        NSArray * a = [item2  elementsForName:@"a"];
                        
                        for (GDataXMLElement * element in a) {
                            
                            Idiom * model = [Idiom new];
                            
                            model.title = element.stringValue;
                            
                            model.href = [[element attributeForName:@"href"] stringValue];
                            
                            [mainArray addObject:model];
                            
                        }
                    }
                }
            }
        }
    }
    
    
    [self insertArray:mainArray];
    
    return mainArray;
    
}

#pragma mark - 数据库
+ (NSString *)FMDBPath {
    
    NSString* docsdir = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Identifer = [infoDictionary objectForKey:@"CFBundleIdentifier"];
    
    NSLog(@"%@",docsdir);
    return [NSString stringWithFormat:@"%@/%@.db",docsdir,app_Identifer];
    
}

+ (FMDatabase *)db {
    FMDatabase *_db = [FMDatabase databaseWithPath:[self FMDBPath]];
    if ([_db open]) {
        
        [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS idiom (href TEXT PRIMARY KEY, title TEXT)"];
    }
    
    return _db;
}

+ (void)insertArray:(NSArray *)aArray {
    
    FMDatabase * db = [self db];
    
    [db beginTransaction];
    
    for (Idiom * m in aArray) {
        
        [db executeUpdate:@"REPLACE INTO idiom (href, title) VALUES (?,?)",m.href,m.title];
        
    }
    [db commit];
    [db close];
}


+ (NSArray *)readDB {
    
    NSMutableArray * array = [NSMutableArray array];
    
    FMDatabase * db = [self db];
    
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM idiom "];
    
    while ([rs next]) {

        Idiom * model = [Idiom new];
        
        model.href = [rs stringForColumn:@"href"];
        model.title = [rs stringForColumn:@"title"];
        
        [array addObject:model];
        
    }
    
    return array;
    
}

@end

@implementation Idiom



@end


