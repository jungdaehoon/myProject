//
//  IxSecureManager.h
//  nProtect Mobile SDK
//
//  Created by Ko Jaewan on 2014. 11. 7..
//  Copyright (c) 2014년 INCA Internet INC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IxSecureManager : NSObject
{
}

+ (IxSecureManager *)sharedManager;

- (void)initLicense:(NSString *)licenseKey;
- (BOOL)start;
- (BOOL)check;
@end
