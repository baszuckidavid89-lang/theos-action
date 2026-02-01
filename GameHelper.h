#ifndef GAMEHELPER_H
#define GAMEHELPER_H

#import <Foundation/Foundation.h>

// Standard Unity Vector3 structure
#ifndef VECTOR3_DEFINED
#define VECTOR3_DEFINED
typedef struct Vector3 {
    float x;
    float y;
    float z;
} Vector3;
#endif

@interface GameHelper : NSObject

@property (nonatomic, assign) BOOL isInitialized;
@property (nonatomic, assign) void* prefabGeneratorClass;
@property (nonatomic, assign) void* netPlayerClass;

+ (instancetype)sharedHelper;
- (void)initializeGameClasses;
- (void)spawnItem:(NSString *)itemName position:(Vector3)pos;
- (void)giveSelfMoney;

@end

#endif /* GAMEHELPER_H */
