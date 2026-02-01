#import "NetworkHelper.h"

@implementation NetworkHelper
+ (instancetype)sharedHelper {
    static NetworkHelper *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ shared = [[self alloc] init]; });
    return shared;
}
- (NSString *)getDeviceID { return @"12345"; }
@end
