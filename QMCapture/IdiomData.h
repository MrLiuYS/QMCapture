//
//  IdiomData.h
//  QMCapture
//
//  Created by 刘永生 on 15/7/23.
//  Copyright (c) 2015年 刘永生. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IdiomData : NSObject

+ (void)idiomList:(void (^)(id aData, NSError *error))block;


+ (NSArray *)readDB;

+ (void)idiomInfos:(NSArray *)aInfos func:(void (^)(id aData, NSError *error))block ;

@end


@interface Idiom : NSObject

@property (nonatomic, copy) NSString * href;
@property (nonatomic, copy) NSString * title;

@property (nonatomic, copy) NSString * info;


@end

