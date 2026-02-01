#import <Foundation/Foundation.h>

@interface IL2CPPResolver : NSObject

@property (nonatomic, assign) BOOL isInitialized;

// IL2CPP API Function Pointers
@property (nonatomic, assign) void* (*domain_get)();
@property (nonatomic, assign) void** (*domain_get_assemblies)(void* domain, size_t* size);
@property (nonatomic, assign) void* (*assembly_get_image)(void* assembly);
@property (nonatomic, assign) void* (*class_from_name)(void* image, const char* namespaze, const char* name);
@property (nonatomic, assign) void* (*class_get_method_from_name)(void* klass, const char* name, int argsCount);
@property (nonatomic, assign) void* (*runtimeInvoke)(void* method, void* obj, void** params, void** exc);
@property (nonatomic, assign) void* (*stringNew)(const char* str);

+ (instancetype)sharedResolver;
- (void)initialize;
- (void*)getMethodFromClass:(const char*)className methodName:(const char*)methodName args:(int)args;

@end
