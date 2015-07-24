//
//  PIdiomService.h
//  QMCapture
//
//  Created by 刘永生 on 15/7/24.
//  Copyright (c) 2015年 刘永生. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PIdiomService : NSObject

@property (nonatomic, assign) int location;

+ (PIdiomService *)sharedManager;


+ (void)idiomList;


@end

@interface PIdiom : NSObject

@property (nonatomic, assign) int mid;
@property (nonatomic, copy) NSString * hanzi;
@property (nonatomic, copy) NSString * jieshi;
@property (nonatomic, copy) NSString * biaoji;

@end