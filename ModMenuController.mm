#import "ModMenuController.h"
#import "GameHelper.h"

@implementation ModMenuController

// This is called by your "SPAWN ITEM" button
- (void)spawnSelectedItem {
    NSString *itemName = self.availableItems[self.selectedItemIndex];
    
    // Check if user entered custom coordinates, else use default offset
    float x = [self.xField.text floatValue];
    float y = [self.yField.text floatValue] ?: 2.0f; // Default Y to 2.0 so it doesn't spawn in floor
    float z = [self.zField.text floatValue];
    
    Vector3 pos = {x, y, z};
    
    [[GameHelper sharedHelper] spawnItem:itemName position:pos];
}

- (void)giveMoney {
    [[GameHelper sharedHelper] giveSelfMoney];
}
@end
