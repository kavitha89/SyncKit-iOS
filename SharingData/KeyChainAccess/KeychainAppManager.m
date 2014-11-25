//
//  WrappedAppManager.m
//  iPAD Apps Hub-Simulator
//
//  Created by Kavitha on 03/06/14.
//
//

#import "KeychainAppManager.h"

#define IDENTIFIER  @"SharedApplication"
#define ACCOUNT     @"SSO"
#define VALUEDATA   @"YES"
#define SERVICE     @"com.sso.wrappedApps"
#define NEWAPP      @"NewApp"
#define iKeyChainAppDetailId @"appItemID"

#define iMIMApplicationInfo     @"MIMApplicationInfo"
#define iPlist                  @"plist"
#define iTeamIdkey              @"Team_ID"

@implementation KeychainAppManager

-(void)setInstallionQueuedFlag:(NSDictionary*)values
{
    NSMutableDictionary* passwordDict = [[NSMutableDictionary alloc]init];
    NSString *password = @"";
    NSString *error;

    KeychainItemWrapper* keyChain = [[KeychainItemWrapper alloc]initWithIdentifier:IDENTIFIER accessGroup:[self getTeamId]];
    NSString* oldPasword = [keyChain objectForKey:(__bridge id)(kSecAttrAccount)];
    if(oldPasword && [oldPasword length]){
        NSData *dictionaryRep = [oldPasword dataUsingEncoding:NSUTF8StringEncoding];

        if([dictionaryRep length] > 0){
            NSDictionary*dictionary = [NSPropertyListSerialization propertyListFromData:dictionaryRep mutabilityOption:NSPropertyListImmutable format:nil errorDescription:nil];
            if(dictionary)
              [passwordDict setDictionary:dictionary];
        }
    }
    if(values){
        [passwordDict setObject:values forKey:[NSString stringWithFormat:@"%d",[[values objectForKey:iKeyChainAppDetailId] intValue]]];
    }
    NSData *dictionaryRep = [NSPropertyListSerialization dataFromPropertyList:passwordDict format:kCFPropertyListXMLFormat_v1_0 errorDescription:&error];
    password = [[NSString alloc] initWithBytes:[dictionaryRep bytes] length:[dictionaryRep length] encoding:NSUTF8StringEncoding];
    
    
    [keyChain setObject:password forKey:(__bridge id)(kSecAttrAccount)];
    [keyChain setObject:VALUEDATA forKey:(__bridge id)(kSecValueData)];
    [keyChain setObject:SERVICE forKey:(__bridge id)kSecAttrService];

}

#pragma mark - Team ID
-(NSString*) getTeamId
{
    NSString* path = [[NSBundle mainBundle] pathForResource:iMIMApplicationInfo ofType:iPlist];
    NSDictionary *applicaionInfo = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString* teamID = [applicaionInfo objectForKey:iTeamIdkey];
    if(teamID)
        return teamID;
    else
        return @"";
}
@end
