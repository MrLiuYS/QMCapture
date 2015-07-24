//
//  PIdiomService.m
//  QMCapture
//
//  Created by 刘永生 on 15/7/24.
//  Copyright (c) 2015年 刘永生. All rights reserved.
//

#import "PIdiomService.h"

#import <FMDB.h>
#import <GDataXMLNode.h>
#import <AFNetworking.h>
#import <SVProgressHUD.h>

@implementation PIdiomService

+ (PIdiomService *)sharedManager
{
    static PIdiomService *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        if (!sharedInstance) {
            
            sharedInstance = [[PIdiomService alloc]init];
            
        }
    });
    return sharedInstance;
}


+ (void)idiomList {
    
    NSMutableArray *mutableOperations = [NSMutableArray array];
    
    for (int index = 1; index < 21; index++) {
        
        NSString * tempUrlStr  =  [NSString stringWithFormat:@"http://xiaoxue.hujiang.com/cyu/xiaoxuechengyu_%d/",index];
        
        NSURL *url3 = [NSURL URLWithString:tempUrlStr];
        
        NSURLRequest *request3 = [NSURLRequest requestWithURL:url3];
        
        AFHTTPRequestOperation *operation3 = [[AFHTTPRequestOperation alloc] initWithRequest:request3];
        
        [operation3 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            
            [self parseFengshuList:responseObject];
            
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
                               
                           } completionBlock:^(NSArray *operations) {
                               
                               //                               NSLog(@"All operations in batch complete: %@",operations);
                               
                           }];
    
    [[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];
    
    
}

+ (NSArray *)parseFengshuList:(id)response {
    
    NSMutableArray * mainArray = [NSMutableArray array];
    
    @autoreleasepool {
        GDataXMLDocument * doc = [[GDataXMLDocument alloc]initWithHTMLData:response
                                                                  encoding:NSUTF8StringEncoding
                                                                     error:NULL];
        if (doc) {
            
            NSArray * trArray = [doc nodesForXPath:@"//div[@class='list_content']" error:NULL];
            
            for (GDataXMLElement * item0 in trArray) {
                
                NSArray * tr = [item0 elementsForName:@"ul"];
                
                for (GDataXMLElement * item1 in tr) {
                    
                    NSArray * td = [item1 elementsForName:@"li"];
                    
                    for (GDataXMLElement * item2 in td) {
                        
                        
                        PIdiom * model = [PIdiom new];
                        
                        
                        NSArray * a = [item2  elementsForName:@"a"];
                        
                        for (GDataXMLElement * element in a) {
                            
                            NSString * string = element.stringValue;
                            
                            string = [string substringToIndex:4];
                            
  
                            model.hanzi = string;

                            
                        }
                        
                        NSArray * div11 = [item2  elementsForName:@"div"];
                        
                        for (GDataXMLElement * element in div11) {
                            
                            model.jieshi = element.stringValue;
                          
                        }
                        
                        
                        
                        
                        [mainArray addObject:model];
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
        
        [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS idioms (chengyuId varchar PRIMARY KEY, hanzi varchar(16), jieshi text DEFAULT(NULL) , biaoji varchar DEFAULT(NULL))"];
    }
    
    return _db;
}

+ (void)insertArray:(NSArray *)aArray {
    
    FMDatabase * db = [self db];
    
    [db beginTransaction];
    
    for (PIdiom * m in aArray) {
        
//        PIdiom * m =  aArray[index];
        
        [db executeUpdate:@"insert INTO idioms (chengyuId, hanzi , jieshi) VALUES (?,?,?)",[NSNumber numberWithInt:[PIdiomService sharedManager].location],m.hanzi,m.jieshi];
        
        [PIdiomService sharedManager].location ++;
        
    }
    [db commit];
    [db close];
}


@end


@implementation PIdiom


@end

