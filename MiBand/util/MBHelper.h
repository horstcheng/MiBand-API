//
//  MBHelper.h
//  MiBandApiSample
//
//  Created by TracyYih on 15/1/2.
//  Copyright (c) 2015年 esoftmobile.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MLCounter)();

@interface MBHelper : NSObject

+ (NSUInteger)hexString2Int:(NSString *)value;
+ (NSString *)byte2HexString:(Byte)value;
+ (NSUInteger)CRC8WithBytes:(Byte *)bytes length:(NSUInteger)length;
+ (MLCounter)counter:(NSUInteger)count withBlock:(void (^)())counterCallback;

@end