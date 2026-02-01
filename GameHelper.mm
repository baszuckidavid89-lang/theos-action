#import "GameHelper.h"
#import "IL2CPPResolver.h"

@implementation GameHelper
+ (instancetype)sharedHelper {
    static GameHelper *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ shared = [[self alloc] init]; });
    return shared;
}

- (void)spawnItem:(NSString *)itemName position:(Vector3)pos {
    IL2CPPResolver *res = [IL2CPPResolver sharedResolver];
    void* method = [res getMethodFromClass:"PrefabGenerator" methodName:"SpawnItem" args:2];
    if (method) {
        void* args[2] = { res.stringNew([itemName UTF8String]), &pos };
        res.runtimeInvoke(method, NULL, args, NULL);
    }
}

- (void)giveSelfMoney {
    IL2CPPResolver *res = [IL2CPPResolver sharedResolver];
    void* method = [res getMethodFromClass:"NetPlayer" methodName:"AddMoneyToPlayer" args:1];
    if (method) {
        int amount = 999999;
        void* args[1] = { &amount };
        res.runtimeInvoke(method, NULL, args, NULL);
    }
}
@end
