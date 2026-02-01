#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <substrate.h>

typedef struct Vector3 {
    float x; float y; float z;
} Vector3;

@interface GameHelper : NSObject
+ (instancetype)shared;
- (Vector3)getCameraPosition;
- (void)spawnItem:(NSString *)name at:(Vector3)pos;
@end

@implementation GameHelper
+ (instancetype)shared {
    static GameHelper *inst;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ inst = [[GameHelper alloc] init]; });
    return inst;
}
- (Vector3)getCameraPosition { return (Vector3){0, 0, 0}; }
- (void)spawnItem:(NSString *)name at:(Vector3)pos {
    // Spawning logic via MSFindSymbol
}
@end

@interface ModMenuController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIButton *circleToggleButton;
@property (nonatomic, strong) UITextField *xIn, *yIn, *zIn;
@property (nonatomic, strong) UISlider *qtySlider;
@property (nonatomic, strong) UILabel *qtyLabel;
@property (nonatomic, strong) UIPickerView *itemPicker;
@property (nonatomic, strong) NSArray *availableItems;
@end

@implementation ModMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.availableItems = @[@"stellarsword_blue", @"flamethrower_skull", @"rpg_smshr", @"item_backpack"];
    [self setupCircleButton];
    [self setupMainSection];
}

- (void)setupCircleButton {
    // Large Purple Circle (70x70)
    self.circleToggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.circleToggleButton.frame = CGRectMake(30, 70, 70, 70); 
    self.circleToggleButton.backgroundColor = [UIColor purpleColor];
    self.circleToggleButton.layer.cornerRadius = 35; // Perfect Circle
    self.circleToggleButton.clipsToBounds = YES;
    self.circleToggleButton.layer.borderWidth = 3;
    self.circleToggleButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.circleToggleButton setTitle:@"M" forState:UIControlStateNormal];
    self.circleToggleButton.titleLabel.font = [UIFont boldSystemFontOfSize:26];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
    [self.circleToggleButton addGestureRecognizer:pan];
    [self.circleToggleButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.circleToggleButton];
}

- (void)handleDrag:(UIPanGestureRecognizer *)p {
    CGPoint translation = [p translationInView:self.view];
    self.circleToggleButton.center = CGPointMake(self.circleToggleButton.center.x + translation.x, 
                                                self.circleToggleButton.center.y + translation.y);
    [p setTranslation:CGPointZero inView:self.view];
}

- (void)setupMainSection {
    self.container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 350, 550)];
    self.container.backgroundColor = [UIColor colorWithWhite:0.05 alpha:0.98];
    self.container.layer.cornerRadius = 30;
    self.container.layer.borderWidth = 2.5;
    self.container.layer.borderColor = [UIColor purpleColor].CGColor;
    self.container.center = self.view.center;
    self.container.hidden = YES;
    [self.view addSubview:self.container];

    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(310, 15, 30, 30)];
    [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.container addSubview:closeBtn];

    self.xIn = [self addField:@"X Offset" at:60];
    self.yIn = [self addField:@"Y Offset" at:100];
    self.zIn = [self addField:@"Z Offset" at:140];

    self.qtyLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 190, 310, 20)];
    self.qtyLabel.text = @"Quantity: 1";
    self.qtyLabel.textColor = [UIColor whiteColor];
    self.qtyLabel.textAlignment = NSTextAlignmentCenter;
    [self.container addSubview:self.qtyLabel];

    self.qtySlider = [[UISlider alloc] initWithFrame:CGRectMake(40, 215, 270, 30)];
    self.qtySlider.minimumValue = 1;
    self.qtySlider.maximumValue = 100;
    [self.qtySlider addTarget:self action:@selector(sliderMoved:) forControlEvents:UIControlEventValueChanged];
    [self.container addSubview:self.qtySlider];

    self.itemPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(10, 260, 330, 150)];
    self.itemPicker.delegate = self;
    self.itemPicker.dataSource = self;
    [self.container addSubview:self.itemPicker];

    UIButton *genBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    genBtn.frame = CGRectMake(75, 430, 200, 60);
    [genBtn setTitle:@"SPAWN ITEMS" forState:UIControlStateNormal];
    genBtn.backgroundColor = [UIColor greenColor];
    [genBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    genBtn.layer.cornerRadius = 20;
    [genBtn addTarget:self action:@selector(onSpawn) forControlEvents:UIControlEventTouchUpInside];
    [self.container addSubview:genBtn];
}

- (UITextField*)addField:(NSString*)ph at:(CGFloat)y {
    UITextField *t = [[UITextField alloc] initWithFrame:CGRectMake(75, y, 200, 35)];
    t.placeholder = ph;
    t.backgroundColor = [UIColor whiteColor];
    t.borderStyle = UITextBorderStyleRoundedRect;
    [self.container addSubview:t];
    return t;
}

- (void)sliderMoved:(UISlider *)sender {
    self.qtyLabel.text = [NSString stringWithFormat:@"Quantity: %d", (int)sender.value];
}

- (void)toggleMenu {
    self.container.hidden = !self.container.hidden;
    self.circleToggleButton.hidden = !self.container.hidden;
    [self.view endEditing:YES];
}

- (void)onSpawn {
    Vector3 finalPos;
    if (self.xIn.text.length > 0) {
        finalPos.x = [self.xIn.text floatValue];
        finalPos.y = [self.yIn.text floatValue];
        finalPos.z = [self.zIn.text floatValue];
    } else {
        finalPos = [[GameHelper shared] getCameraPosition];
    }
    int qty = (int)self.qtySlider.value;
    NSString *itemID = self.availableItems[[self.itemPicker selectedRowInComponent:0]];
    for (int i = 0; i < qty; i++) {
        Vector3 jitter = finalPos;
        jitter.x += (i * 0.15f);
        [[GameHelper shared] spawnItem:itemID at:jitter];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)p { return 1; }
- (NSInteger)pickerView:(UIPickerView *)p numberOfRowsInComponent:(NSInteger)c { return self.availableItems.count; }
- (NSString *)pickerView:(UIPickerView *)p titleForRow:(NSInteger)r forComponent:(NSInteger)c { return self.availableItems[r]; }

@end

%hook UnityFramework
- (void)onUnityUpdate {
    %orig;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        ModMenuController *menu = [[ModMenuController alloc] init];
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        win.windowLevel = UIWindowLevelStatusBar + 100;
        [win.rootViewController addChildViewController:menu];
        [win addSubview:menu.view];
    });
}
%end
