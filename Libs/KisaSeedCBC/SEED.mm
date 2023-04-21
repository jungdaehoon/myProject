//
//  SEED.c
//  cereal
//
//  Created by DaeHoon Chung on 2023/04/11.
//  Copyright © 2023 srkang. All rights reserved.
//

#import "SEED.h"
#import "CocoaSecurity.h"

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include "KISA_SEED_CBC.h"

@implementation SEED
+ (NSString*)encrypt:(NSString*)masterKey plainText:(NSString*)plainText
{
    NSData* sha256              = [self getSHA256:masterKey];
    NSData* key                 = [sha256 subdataWithRange:NSMakeRange(0, 16)];
    NSData* iv                  = [sha256 subdataWithRange:NSMakeRange(16, 16)];
    
    BYTE pbszPlainText[2048]    = {0,};
    memset(pbszPlainText, 0, [plainText length]);
    const char *byteBuff        = [plainText UTF8String];
    memcpy(pbszPlainText, (BYTE*)byteBuff, strlen(byteBuff));

    /// 암호문 출력 버퍼 입니다.
    BYTE pbszCipherText[2048]   = {0,};
    int nCipherTextLen          = encrytKeyIVSeedCBC( (BYTE*)[key bytes], (BYTE*)[iv bytes], pbszPlainText, pbszCipherText);
    NSData* data                = [[NSData alloc] initWithBytes:pbszCipherText length:nCipherTextLen];
    NSString* base64String      = [data base64EncodedStringWithOptions:0];
    
    memset(pbszPlainText, 0, nCipherTextLen);
    memset((void*)[data bytes],0,[data length]);
    [SEED printHexaLog:pbszCipherText lenght:nCipherTextLen];
    return base64String;
}


+ (NSString*)encrypt:(Byte*)masterKey userIV:(Byte*)userIv plainText:(NSString*)plainText
{
    BYTE pbszPlainText[2048]    = {0,};
    memset(pbszPlainText, 0, [plainText length]);
    const char *byteBuff        = [plainText UTF8String];
    memcpy(pbszPlainText, (BYTE*)byteBuff, strlen(byteBuff));
    
    
    /// 암호문 출력 버퍼 입니다.
    BYTE pbszCipherText[2048]   = {0,};
    int nCipherTextLen          = encrytKeyIVSeedCBC( masterKey, userIv, pbszPlainText, pbszCipherText);
    NSData* data                = [[NSData alloc] initWithBytes:pbszCipherText length:nCipherTextLen];
    NSString* base64String      = [data base64EncodedStringWithOptions:0];
    
    memset(pbszPlainText, 0, nCipherTextLen);
    memset((void*)[data bytes],0,[data length]);
    [SEED printHexaLog:pbszCipherText lenght:nCipherTextLen];
    return base64String;
}


+ (NSString*)encrypt:(NSString*)plainText
{
    BYTE pbszPlainText[2048]    = {0,};
    memset(pbszPlainText, 0, [plainText length]);
    const char *byteBuff        = [plainText UTF8String];
    memcpy(pbszPlainText, (BYTE*)byteBuff, strlen(byteBuff));
    
    /// 암호문 출력 버퍼 입니다.
    BYTE pbszCipherText[2048]   = {0,};
    int nCipherTextLen          = encrytSeedCBC(pbszPlainText, pbszCipherText);
    NSData* data                = [[NSData alloc] initWithBytes:pbszCipherText length:nCipherTextLen];
    NSString* base64String      = [data base64EncodedStringWithOptions:0];
    
    memset(pbszPlainText, 0, nCipherTextLen);
    memset((void*)[data bytes],0,[data length]);
    [SEED printHexaLog:pbszCipherText lenght:nCipherTextLen];
    return base64String;
}

+ (NSString*)decrypt:(NSString*)masterKey cipherText:(NSString*)cipherText
{
    NSData* sha256              = [self getSHA256:masterKey];
    NSData* key                 = [sha256 subdataWithRange:NSMakeRange(0, 16)];
    NSData* iv                  = [sha256 subdataWithRange:NSMakeRange(16, 16)];
    
    NSData* data                = [[NSData alloc] initWithBase64EncodedString:cipherText options:0];
    BYTE pbszCipherText[2048]   = {0,};
    memcpy(pbszCipherText, [data bytes], [data length]);
    
    /// 사용자 입력 평문 입니다.
    BYTE pbszPlainText[2048]    = {0,};
    int nPlainTextLen = decrytKeyIVSeedCBC( (BYTE*)[key bytes], (BYTE*)[iv bytes], pbszPlainText, pbszCipherText);
    NSString* plainText = [[NSString alloc] initWithBytes:pbszPlainText length:nPlainTextLen encoding:NSUTF8StringEncoding];
    memset(pbszCipherText, 0, nPlainTextLen);
    [SEED printHexaLog:pbszPlainText lenght:nPlainTextLen];
    return plainText;
}

+ (NSString*)decrypt:(Byte*)masterKey userIV:(Byte*)userIv cipherText:(NSString*)cipherText
{
    NSData* data                = [[NSData alloc] initWithBase64EncodedString:cipherText options:0];
    BYTE pbszCipherText[2048]   = {0,};
    memcpy(pbszCipherText, [data bytes], [data length]);
    
    
    /// 사용자 입력 평문 입니다.
    BYTE pbszPlainText[2048]    = {0,};
    int nPlainTextLen           = decrytKeyIVSeedCBC( masterKey, userIv, pbszPlainText, pbszCipherText);
    NSString* plainText          = [[NSString alloc] initWithBytes:pbszPlainText length:nPlainTextLen encoding:NSUTF8StringEncoding];
    memset(pbszCipherText, 0, nPlainTextLen);
    [SEED printHexaLog:pbszPlainText lenght:nPlainTextLen];
    return plainText;
}

+ (NSString*)decrypt:(NSString*)cipherText
{
    NSData* data                = [[NSData alloc] initWithBase64EncodedString:cipherText options:0];
    BYTE pbszCipherText[2048]   = {0,};
    memcpy(pbszCipherText, [data bytes], [data length]);
    
    /// 사용자 입력 평문 입니다.
    BYTE pbszPlainText[2048]    = {0,};
    int nPlainTextLen = decrytSeedCBC(pbszCipherText, pbszPlainText);
    NSString* plainText = [[NSString alloc] initWithBytes:pbszPlainText length:nPlainTextLen encoding:NSUTF8StringEncoding];
    
    memset(pbszCipherText, 0, nPlainTextLen);
    [SEED printHexaLog:pbszPlainText lenght:nPlainTextLen];
    return plainText;
}


+ (void)printHexaLog:(BYTE*)pbBytes lenght:(NSInteger)lenght
{
    printf("\nLenght (%ld) : ",(long)lenght);
    for (int i=0; i<lenght; i++)
    {
        printf("%02X ",pbBytes[i]);
    }
}

+ (NSData *)getSHA256:(NSString*)msg
{
    return [CocoaSecurity sha256:msg].data;
}


+ (NSString*)hash:(NSString*)secret payload:(NSString*)payload
{
    return [CocoaSecurity hmacSha256:payload hmacKey:secret].base64;
}
@end


