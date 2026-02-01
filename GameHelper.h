#import <Foundation/Foundation.h>

typedef struct Vector3 { float x; float y; float z; } Vector3;

@interface GameHelper : NSObject
+ (instancetype)sharedHelper;
- (void)spawnItem:(NSString *)itemName position:(Vector3)pos;
- (void)giveSelfMoney;
@end
