//
//  SEED.h
//  cereal
//
//  Created by DaeHoon Chung on 2023/04/11.
//  Copyright © 2023 srkang. All rights reserved.
//


#import <Foundation/Foundation.h>



@interface SEED : NSObject

+ (NSString*)encrypt:(NSString*)plainText;
+ (NSString*)encrypt:(NSString*)masterKey plainText:(NSString*)plainText;
+ (NSString*)encrypt:(Byte*)masterKey userIV:(Byte*)userIv plainText:(NSString*)plainText;

+ (NSString*)decrypt:(NSString*)cipherText;
+ (NSString*)decrypt:(NSString*)masterKey cipherText:(NSString*)cipherText;
+ (NSString*)decrypt:(Byte*)masterKey userIV:(Byte*)userIv cipherText:(NSString*)cipherText;
@end

