//
//  WrappedAppManager.h
//  iPAD Apps Hub-Simulator
//
//  Created by Kavitha on 03/06/14.
//
//

#import <Foundation/Foundation.h>
#import "KeychainItemWrapper.h"

@interface KeychainAppManager : NSObject

-(void)setInstallionQueuedFlag:(NSDictionary*)values;

@end
