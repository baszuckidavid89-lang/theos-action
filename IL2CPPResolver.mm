#import "IL2CPPResolver.h"
#import <dlfcn.h>

@implementation IL2CPPResolver

+ (instancetype)sharedResolver {
    static IL2CPPResolver *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ shared = [[self alloc] init]; });
    return shared;
}

- (void)initialize {
    if (self.isInitialized) return;
    
    void *handle = dlopen(NULL, RTLD_NOW);
    self.domain_get = dlsym(handle, "il2cpp_domain_get");
    self.domain_get_assemblies = dlsym(handle, "il2cpp_domain_get_assemblies");
    self.assembly_get_image = dlsym(handle, "il2cpp_assembly_get_image");
    self.class_from_name = dlsym(handle, "il2cpp_class_from_name");
    self.class_get_method_from_name = dlsym(handle, "il2cpp_class_get_method_from_name");
    self.runtimeInvoke = dlsym(handle, "il2cpp_runtime_invoke");
    self.stringNew = dlsym(handle, "il2cpp_string_new");
    
    self.isInitialized = YES;
}

- (void*)getMethodFromClass:(const char*)className methodName:(const char*)methodName args:(int)args {
    size_t size;
    void** assemblies = self.domain_get_assemblies(self.domain_get(), &size);
    for(int i = 0; i < size; i++) {
        void* image = self.assembly_get_image(assemblies[i]);
        void* klass = self.class_from_name(image, "", className);
        if (klass) {
            return self.class_get_method_from_name(klass, methodName, args);
        }
    }
    return NULL;
}
@end
