#import <Foundation/Foundation.h>

// Standard Unity Vector3 structure
typedef struct Vector3 {
    float x;
    float y;
    float z;
} Vector3;

@interface GameHelper : NSObject

@property (nonatomic, assign) BOOL isInitialized;
@property (nonatomic, assign) void* prefabGeneratorClass;
@property (nonatomic, assign) void* netPlayerClass;

+ (instancetype)sharedHelper;
- (void)spawnItem:(NSString *)itemName position:(Vector3)pos;
- (void)giveSelfMoney;

@end
