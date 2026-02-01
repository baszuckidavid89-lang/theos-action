#import <UIKit/UIKit.h>
#import "ModMenuController.h"
#import "IL2CPPResolver.h"

static UIWindow *modWindow;

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Initialize Unity link
        [[IL2CPPResolver sharedResolver] initialize];
        
        // Setup Window
        modWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        modWindow.rootViewController = [[ModMenuController alloc] init];
        modWindow.windowLevel = UIWindowLevelStatusBar + 100.0;
        modWindow.backgroundColor = [UIColor clearColor];
        [modWindow makeKeyAndVisible];
    });
}
