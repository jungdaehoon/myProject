//
//  XKConfigure.h
//  XecureKeypad
//
//  Created by Seo SY on 2018. 7. 12..
//  Copyright © 2018년 Hancom Secure. All rights reserved.
//

#import <Foundation/Foundation.h>


#define TLS_MODULE_INTERNAL_0 0
#define TLS_MODULE_EXTERNAL_0 100

#define TLS_VERSION_1_0 0x10
#define TLS_VERSION_1_1 0x20
#define TLS_VERSION_1_2 0x40

#define TLS_MODULE_INTERNAL_0_SUPPORT_MASK      TLS_VERSION_1_0
#define TLS_MODULE_EXTERNAL_0_SUPPORT_MASK      TLS_VERSION_1_0 | TLS_VERSION_1_1 | TLS_VERSION_1_2



@interface XKConfigure : NSObject {

}

+ (id) SharedInstance;

- (void) setTlsCoinfgWithModule:(int) module Version:(int) version;
@end
