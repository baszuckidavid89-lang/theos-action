#import "ModMenuController.h"
#import "GameHelper.h"

@implementation ModMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1. Setup Data
    self.availableItems = @[
        @"item_ac_cola", @"item_alphablade", @"item_anti_gravity_grenade", @"item_axe", @"item_backpack",
        @"item_banana", @"item_baseball_bat", @"item_boombox", @"item_demon_sword", @"item_flamethrower_skull",
        @"item_grenade_gold", @"item_jetpack", @"item_moneygun", @"item_pickaxe_cube", @"item_rpg_ammo",
        @"item_shotgun_ammo", @"item_flaregun", @"item_flashbang", @"item_hookshot", @"item_landmine"
    ];
    self.filteredItems = [self.availableItems mutableCopy];
    self.isUnlocked = YES; // Skip login/key requirement
    
    // 2. Setup UI Components
    [self setupFloatingButton];
    [self setupMainUI];
}

- (void)setupFloatingButton {
    self.circleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.circleButton.frame = CGRectMake(50, 150, 60, 60);
    self.circleButton.backgroundColor = [UIColor purpleColor];
    self.circleButton.layer.cornerRadius = 30;
    self.circleButton.layer.borderWidth = 2;
    self.circleButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.circleButton setTitle:@"A" forState:UIControlStateNormal];
    self.circleButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
    [self.circleButton addGestureRecognizer:pan];
    [self.circleButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.circleButton];
}

- (void)handleDrag:(UIPanGestureRecognizer *)p {
    CGPoint translation = [p translationInView:self.view.superview];
    self.circleButton.center = CGPointMake(self.circleButton.center.x + translation.x, self.circleButton.center.y + translation.y);
    [p setTranslation:CGPointZero inView:self.view.superview];
}

- (void)setupMainUI {
    // Background Blur Container
    self.blurContainer = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    self.blurContainer.frame = CGRectMake(0, 0, 320, 450);
    self.blurContainer.center = self.view.center;
    self.blurContainer.layer.cornerRadius = 20;
    self.blurContainer.layer.masksToBounds = YES;
    self.blurContainer.layer.borderWidth = 1;
    self.blurContainer.layer.borderColor = [UIColor purpleColor].CGColor;
    self.blurContainer.hidden = YES;
    [self.view addSubview:self.blurContainer];

    // Title
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 320, 30)];
    title.text = @"ASTRAEUS CHEAT";
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    [self.blurContainer.contentView addSubview:title];

    // Tab Bar
    self.tabControl = [[UISegmentedControl alloc] initWithItems:@[@"Items", @"Settings", @"Money"]];
    self.tabControl.frame = CGRectMake(10, 50, 300, 30);
    self.tabControl.selectedSegmentIndex = 0;
    [self.tabControl addTarget:self action:@selector(tabChanged) forControlEvents:UIControlEventValueChanged];
    [self.blurContainer.contentView addSubview:self.tabControl];

    [self setupSubViews];
}

- (void)setupSubViews {
    // --- ITEM VIEW ---
    self.itemsView = [[UIView alloc] initWithFrame:CGRectMake(0, 90, 320, 360)];
    
    self.searchBar = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, 290, 35)];
    self.searchBar.placeholder = @"Search Items...";
    self.searchBar.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    self.searchBar.textColor = [UIColor whiteColor];
    self.searchBar.layer.cornerRadius = 8;
    self.searchBar.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 1)];
    self.searchBar.leftViewMode = UITextFieldViewModeAlways;
    [self.searchBar addTarget:self action:@selector(searchChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.itemsView addSubview:self.searchBar];

    self.itemPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 320, 120)];
    self.itemPicker.delegate = self;
    self.itemPicker.dataSource = self;
    [self.itemsView addSubview:self.itemPicker];

    UIButton *spawnBtn = [[UIButton alloc] initWithFrame:CGRectMake(60, 300, 200, 45)];
    spawnBtn.backgroundColor = [UIColor purpleColor];
    spawnBtn.layer.cornerRadius = 10;
    [spawnBtn setTitle:@"SPAWN ITEM" forState:UIControlStateNormal];
    [spawnBtn addTarget:self action:@selector(spawnSelectedItem) forControlEvents:UIControlEventTouchUpInside];
    [self.itemsView addSubview:spawnBtn];

    [self.blurContainer.contentView addSubview:self.itemsView];

    // --- SETTINGS VIEW (XYZ) ---
    self.settingsView = [[UIView alloc] initWithFrame:CGRectMake(0, 90, 320, 360)];
    self.settingsView.hidden = YES;
    
    self.xField = [self createField:@"X Offset (0.0)" at:20];
    self.yField = [self createField:@"Y Offset (2.0)" at:70];
    self.zField = [self createField:@"Z Offset (0.0)" at:120];
    
    [self.blurContainer.contentView addSubview:self.settingsView];

    // --- MONEY VIEW ---
    self.moneyView = [[UIView alloc] initWithFrame:CGRectMake(0, 90, 320, 360)];
    self.moneyView.hidden = YES;
    
    UIButton *moneyBtn = [[UIButton alloc] initWithFrame:CGRectMake(60, 50, 200, 50)];
    moneyBtn.backgroundColor = [UIColor colorWithRed:0.1 green:0.6 blue:0.1 alpha:1.0];
    moneyBtn.layer.cornerRadius = 10;
    [moneyBtn setTitle:@"ADD $9,999,999" forState:UIControlStateNormal];
    [moneyBtn addTarget:self action:@selector(giveMoney) forControlEvents:UIControlEventTouchUpInside];
    [self.moneyView addSubview:moneyBtn];
    
    [self.blurContainer.contentView addSubview:self.moneyView];
}

// --- LOGIC ---

- (void)tabChanged {
    self.itemsView.hidden = (self.tabControl.selectedSegmentIndex != 0);
    self.settingsView.hidden = (self.tabControl.selectedSegmentIndex != 1);
    self.moneyView.hidden = (self.tabControl.selectedSegmentIndex != 2);
    [self.view endEditing:YES];
}

- (void)toggleMenu {
    self.blurContainer.hidden = !self.blurContainer.hidden;
    self.circleButton.hidden = !self.blurContainer.hidden;
}

- (void)searchChanged:(UITextField *)t {
    [self.filteredItems removeAllObjects];
    if (t.text.length == 0) {
        [self.filteredItems addObjectsFromArray:self.availableItems];
    } else {
        for (NSString *item in self.availableItems) {
            if ([item.lowercaseString containsString:t.text.lowercaseString]) {
                [self.filteredItems addObject:item];
            }
        }
    }
    [self.itemPicker reloadAllComponents];
}

- (void)spawnSelectedItem {
    NSInteger row = [self.itemPicker selectedRowInComponent:0];
    if (row < self.filteredItems.count) {
        NSString *item = self.filteredItems[row];
        Vector3 pos = {
            [self.xField.text floatValue],
            [self.yField.text floatValue] ?: 2.0f, // Use 2.0 as floor safety
            [self.zField.text floatValue]
        };
        [[GameHelper sharedHelper] spawnItem:item position:pos];
    }
}

- (void)giveMoney {
    [[GameHelper sharedHelper] giveSelfMoney];
}

// Helpers
- (UITextField *)createField:(NSString *)p at:(CGFloat)y {
    UITextField *f = [[UITextField alloc] initWithFrame:CGRectMake(40, y, 240, 35)];
    f.placeholder = p;
    f.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    f.textColor = [UIColor whiteColor];
    f.layer.cornerRadius = 5;
    f.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [self.settingsView addSubview:f];
    return f;
}

// Picker Delegates
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)p { return 1; }
- (NSInteger)pickerView:(UIPickerView *)p numberOfRowsInComponent:(NSInteger)c { return self.filteredItems.count; }
- (NSString *)pickerView:(UIPickerView *)p titleForRow:(NSInteger)r forComponent:(NSInteger)c { return self.filteredItems[r]; }

@end
