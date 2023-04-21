//
//  BSAppIron.h
//  BSAppIron
//
//  Created by Cho JeongHyeon on 2015. 3. 25..
//  Copyright (c) 2015년 Barunsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSAppIronResult.h"

@protocol BSAppIronServiceCallback <NSObject>

-(void)onAppIronResultReceive:(NSString *)code sid:(NSString *)sid token:(NSString *)token;

@end

@interface BSAppIron : NSObject

@property (nonatomic, retain)NSString *url;
@property (nonatomic, retain)NSString *appId;
@property (nonatomic, retain)NSString *appVer;
@property (nonatomic, retain)NSString *sessionId;
@property (nonatomic, assign)NSUInteger connTimeout;

@property (nonatomic, retain)NSString *sSessionId;
@property (nonatomic, retain)NSString *sToken;

- (NSString *)getSessionId __attribute__ ((deprecated));
- (NSString *)getToken __attribute__ ((deprecated));

- (NSString *)registDevice:(NSString *)registKey reqUrl:(NSString *)reqUrl __attribute__ ((deprecated));

/*---------------------------------------------------------------------------*
 * Describe the method here - what does it do, how does it work, etc. Very brief.
 * @deprecated This delegate method is deprecated starting in version 2.12.16,
 * please use authenticateAppWithUrl: instead.
 *---------------------------------------------------------------------------*/
- (NSString *)authApp:(NSString *)url
                appId:(NSString *)appId
               appVer:(NSString *)appVer
          connTimeout:(NSUInteger)connTimeout __attribute__ ((deprecated));
- (NSString *)authApp:(NSString *)url __attribute__ ((deprecated));
- (NSString *)authApp:(NSString *)url
          connTimeout:(NSUInteger)connTimeout __attribute__ ((deprecated));

- (NSString *)getAppIronDeviceId __attribute__ ((deprecated));

- (void)startService:(NSString *) url callback:(id<BSAppIronServiceCallback>)callback __attribute__ ((deprecated));
- (void)startService:(NSString *) url interval:(NSTimeInterval)interval callback:(id<BSAppIronServiceCallback>)callback __attribute__ ((deprecated));
- (void)startService:(NSString *) url interval:(NSTimeInterval)interval timeout:(NSTimeInterval)timeout callback:(id<BSAppIronServiceCallback>)callback __attribute__ ((deprecated));


+ (BSAppIron *)getInstance;

- (BSAppIronResult *) authenticateAppWithUrl:(NSString *)url
                                     timeout:(NSUInteger)timeout
                                       error:(NSError **)error;

@end
