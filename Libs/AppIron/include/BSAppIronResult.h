//
//  BSAppIronResult.h
//  BSAppIronCommon
//
//  Created by jipark on 02/12/2019.
//  Copyright © 2019 Barunsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BSAppIronResult: NSObject

- (id) initWithSessionId:(NSString *)sessionId
                   token:(NSString *)token;

- (NSString *)sessionId;
- (NSString *)token;

@end
