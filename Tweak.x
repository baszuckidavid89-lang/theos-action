#import "ModMenuController.h"
#import "IL2CPPResolver.h"

static UIWindow *menuWindow;

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Initialize the Unity link
        [[IL2CPPResolver sharedResolver] initialize];
        
        // Setup the menu window
        menuWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        menuWindow.rootViewController = [[ModMenuController alloc] init];
        menuWindow.windowLevel = UIWindowLevelStatusBar + 100;
        menuWindow.backgroundColor = [UIColor clearColor];
        [menuWindow makeKeyAndVisible];
    });
}
