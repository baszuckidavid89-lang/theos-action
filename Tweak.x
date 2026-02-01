#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>

// --- STRUCTURES & GLOBALS ---
typedef struct Vector3 { float x; float y; float z; } Vector3;

static void* (*il2cpp_runtime_invoke)(void* method, void* obj, void** params, void** exc);
static void* (*il2cpp_string_new)(const char* str);
static void* _spawnItemMethod;
static void* _addMoneyMethod;

// --- CUSTOM PASSTHROUGH WINDOW ---
@interface AstraeusWindow : UIWindow @end
@implementation AstraeusWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    // If user touches empty space, pass it to AC Companion game
    if (hitView == self || hitView == self.rootViewController.view) return nil;
    return hitView;
}
@end

// --- MAIN MENU CONTROLLER ---
@interface ModMenuController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
@property (nonatomic, strong) UIVisualEffectView *blurContainer;
@property (nonatomic, strong) UISegmentedControl *tabControl;
@property (nonatomic, strong) UIView *itemsView, *settingsView, *moneyView;
@property (nonatomic, strong) UIButton *circleButton;
@property (nonatomic, strong) UIPickerView *itemPicker;
@property (nonatomic, strong) NSArray *availableItems;
@property (nonatomic, strong) NSMutableArray *filteredItems;
@property (nonatomic, strong) UITextField *searchBar, *xField, *yField, *zField;
@property (nonatomic, strong) UIStepper *qtyStepper;
@property (nonatomic, strong) UILabel *qtyLabel;
@end

@implementation ModMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    // FULL ITEM LIST FROM YOUR DUMP
    self.availableItems = @[
        @"item_ac_cola", @"item_alphablade", @"item_anti_gravity_grenade", @"item_axe", @"item_backpack",
        @"item_banana", @"item_baseball_bat", @"item_boombox", @"item_demon_sword", @"item_flamethrower_skull",
        @"item_grenade_gold", @"item_jetpack", @"item_moneygun", @"item_pickaxe_cube", @"item_rpg_ammo",
        @"item_shotgun_ammo", @"item_flaregun", @"item_flashbang", @"item_hookshot", @"item_landmine"
    ];
    self.filteredItems = [self.availableItems mutableCopy];

    [self setupFloatingButton];
    [self setupMainUI];
}

// --- FLOATING BUTTON ---
- (void)setupFloatingButton {
    self.circleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.circleButton.frame = CGRectMake(50, 100, 60, 60);
    self.circleButton.backgroundColor = [UIColor purpleColor];
    self.circleButton.layer.cornerRadius = 30;
    self.circleButton.layer.borderWidth = 2;
    self.circleButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.circleButton setTitle:@"A" forState:UIControlStateNormal];
    self.circleButton.titleLabel.font = [UIFont boldSystemFontOfSize:22];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
    [self.circleButton addGestureRecognizer:pan];
    [self.circleButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.circleButton];
}

- (void)handleDrag:(UIPanGestureRecognizer *)p {
    CGPoint translation = [p translationInView:self.view];
    self.circleButton.center = CGPointMake(self.circleButton.center.x + translation.x, self.circleButton.center.y + translation.y);
    [p setTranslation:CGPointZero inView:self.view];
}

// --- MAIN UI ---
- (void)setupMainUI {
    self.blurContainer = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    self.blurContainer.frame = CGRectMake(0, 0, 330, 500);
    self.blurContainer.center = self.view.center;
    self.blurContainer.layer.cornerRadius = 25;
    self.blurContainer.layer.masksToBounds = YES;
    self.blurContainer.layer.borderColor = [UIColor purpleColor].CGColor;
    self.blurContainer.layer.borderWidth = 1.5;
    self.blurContainer.hidden = YES;
    [self.view addSubview:self.blurContainer];

    // BRANDING
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 330, 25)];
    title.text = @"Astraeus - AC Mod Menu";
    title.textColor = [UIColor purpleColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont systemFontOfSize:17 weight:UIFontWeightHeavy];
    [self.blurContainer.contentView addSubview:title];

    // CLOSE BUTTON
    UIButton *close = [[UIButton alloc] initWithFrame:CGRectMake(285, 10, 30, 30)];
    [close setTitle:@"✕" forState:UIControlStateNormal];
    close.backgroundColor = [UIColor colorWithRed:0.8 green:0.2 blue:0.2 alpha:1.0];
    close.layer.cornerRadius = 15;
    [close addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.blurContainer.contentView addSubview:close];

    // TABS
    self.tabControl = [[UISegmentedControl alloc] initWithItems:@[@"Items", @"Settings", @"Money"]];
    self.tabControl.frame = CGRectMake(20, 50, 290, 30);
    self.tabControl.selectedSegmentIndex = 0;
    [self.tabControl addTarget:self action:@selector(tabChanged) forControlEvents:UIControlEventValueChanged];
    [self.blurContainer.contentView addSubview:self.tabControl];

    [self setupSubViews];
}

- (void)setupSubViews {
    // 1. ITEMS VIEW
    self.itemsView = [[UIView alloc] initWithFrame:CGRectMake(0, 90, 330, 400)];
    
    self.searchBar = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, 290, 35)];
    self.searchBar.placeholder = @"Search Items...";
    self.searchBar.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    self.searchBar.textColor = [UIColor whiteColor];
    self.searchBar.layer.cornerRadius = 10;
    self.searchBar.delegate = self;
    [self.searchBar addTarget:self action:@selector(searchChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.itemsView addSubview:self.searchBar];

    self.itemPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 330, 120)];
    self.itemPicker.delegate = self;
    [self.itemsView addSubview:self.itemPicker];

    self.qtyLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 170, 150, 30)];
    self.qtyLabel.text = @"Quantity: 1";
    self.qtyLabel.textColor = [UIColor whiteColor];
    [self.itemsView addSubview:self.qtyLabel];

    self.qtyStepper = [[UIStepper alloc] initWithFrame:CGRectMake(210, 170, 0, 0)];
    self.qtyStepper.minimumValue = 1;
    self.qtyStepper.maximumValue = 100;
    [self.qtyStepper addTarget:self action:@selector(stepChange) forControlEvents:UIControlEventValueChanged];
    [self.itemsView addSubview:self.qtyStepper];

    UIButton *spawn = [[UIButton alloc] initWithFrame:CGRectMake(65, 330, 200, 45)];
    spawn.backgroundColor = [UIColor purpleColor];
    spawn.layer.cornerRadius = 12;
    [spawn setTitle:@"SPAWN ITEM" forState:UIControlStateNormal];
    [spawn addTarget:self action:@selector(onSpawn) forControlEvents:UIControlEventTouchUpInside];
    [self.itemsView addSubview:spawn];

    [self.blurContainer.contentView addSubview:self.itemsView];

    // 2. SETTINGS VIEW (XYZ)
    self.settingsView = [[UIView alloc] initWithFrame:CGRectMake(0, 90, 330, 400)];
    self.settingsView.hidden = YES;
    self.xField = [self addField:@"X" at:40];
    self.yField = [self addField:@"Y" at:90];
    self.zField = [self addField:@"Z" at:140];
    [self.blurContainer.contentView addSubview:self.settingsView];

    // 3. MONEY VIEW
    self.moneyView = [[UIView alloc] initWithFrame:CGRectMake(0, 90, 330, 400)];
    self.moneyView.hidden = YES;
    UIButton *moneyBtn = [[UIButton alloc] initWithFrame:CGRectMake(65, 50, 200, 50)];
    moneyBtn.backgroundColor = [UIColor colorWithRed:0.1 green:0.6 blue:0.1 alpha:1.0];
    moneyBtn.layer.cornerRadius = 10;
    [moneyBtn setTitle:@"GIVE 9,999,999" forState:UIControlStateNormal];
    [moneyBtn addTarget:self action:@selector(onMoney) forControlEvents:UIControlEventTouchUpInside];
    [self.moneyView addSubview:moneyBtn];
    [self.blurContainer.contentView addSubview:self.moneyView];
}

// --- ACTIONS ---
- (void)tabChanged {
    self.itemsView.hidden = (self.tabControl.selectedSegmentIndex != 0);
    self.settingsView.hidden = (self.tabControl.selectedSegmentIndex != 1);
    self.moneyView.hidden = (self.tabControl.selectedSegmentIndex != 2);
    [self.view endEditing:YES];
}

- (void)searchChanged:(UITextField *)t {
    [self.filteredItems removeAllObjects];
    if (t.text.length == 0) [self.filteredItems addObjectsFromArray:self.availableItems];
    else {
        for (NSString *s in self.availableItems) {
            if ([s.lowercaseString containsString:t.text.lowercaseString]) [self.filteredItems addObject:s];
        }
    }
    [self.itemPicker reloadAllComponents];
}

- (void)onSpawn {
    NSString *item = self.filteredItems[[self.itemPicker selectedRowInComponent:0]];
    Vector3 pos = {[self.xField.text floatValue], [self.yField.text floatValue], [self.zField.text floatValue]};
    for (int i=0; i<(int)self.qtyStepper.value; i++) {
        void* args[2] = { il2cpp_string_new([item UTF8String]), &pos };
        il2cpp_runtime_invoke(_spawnItemMethod, NULL, args, NULL);
    }
}

- (void)onMoney {
    int amount = 9999999;
    void* args[1] = { &amount };
    il2cpp_runtime_invoke(_addMoneyMethod, NULL, args, NULL);
}

- (void)toggleMenu {
    self.blurContainer.hidden = !self.blurContainer.hidden;
    self.circleButton.hidden = !self.blurContainer.hidden;
    [self.view endEditing:YES];
}

- (void)stepChange { self.qtyLabel.text = [NSString stringWithFormat:@"Quantity: %d", (int)self.qtyStepper.value]; }

- (UITextField*)addField:(NSString*)p at:(CGFloat)y {
    UITextField *f = [[UITextField alloc] initWithFrame:CGRectMake(40, y, 250, 35)];
    f.placeholder = p; f.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    f.textColor = [UIColor whiteColor]; f.layer.cornerRadius = 8;
    [self.settingsView addSubview:f]; return f;
}

// PICKER PROTOCOLS
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)p { return 1; }
- (NSInteger)pickerView:(UIPickerView *)p numberOfRowsInComponent:(NSInteger)c { return self.filteredItems.count; }
- (NSString *)pickerView:(UIPickerView *)p titleForRow:(NSInteger)r forComponent:(NSInteger)c { return self.filteredItems[r]; }

@end

// --- INJECTION ---
static AstraeusWindow *modWindow;
%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        il2cpp_runtime_invoke = (void*(*)(void*,void*,void**,void**))dlsym(RTLD_DEFAULT, "il2cpp_runtime_invoke");
        il2cpp_string_new = (void*(*)(const char*))dlsym(RTLD_DEFAULT, "il2cpp_string_new");
        
        modWindow = [[AstraeusWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        modWindow.rootViewController = [[ModMenuController alloc] init];
        modWindow.windowLevel = UIWindowLevelStatusBar + 1;
        modWindow.backgroundColor = [UIColor clearColor];
        [modWindow makeKeyAndVisible];
    });
}
