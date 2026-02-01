#import <UIKit/UIKit.h>
#import "ModMenuController.h"
#import "IL2CPPResolver.h"
#import "GameHelper.h"

static UIWindow *modWindow;
static ModMenuController *menuController;

// --- INITIALIZATION LOGIC ---
void initializeModMenu() {
    // 1. Initialize the Resolver to map out GameAssembly.dylib
    [[IL2CPPResolver sharedResolver] initialize];
    
    // 2. Setup the Window with our custom passthrough class (if defined in your Controller)
    modWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    modWindow.backgroundColor = [UIColor clearColor];
    modWindow.windowLevel = UIWindowLevelStatusBar + 100.0;
    
    // 3. Initialize the Controller
    menuController = [[ModMenuController alloc] init];
    modWindow.rootViewController = menuController;
    
    // 4. Make it visible
    [modWindow makeKeyAndVisible];
    
    NSLog(@"[Astraeus] Mod Menu fully initialized for com.woosterGames.animalcompany");
}

%ctor {
    // Wait 5 seconds to ensure the game engine and GameAssembly.dylib are fully loaded
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        initializeModMenu();
    });
}
