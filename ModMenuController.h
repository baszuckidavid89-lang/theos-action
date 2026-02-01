#import <UIKit/UIKit.h>

@interface ModMenuController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

// --- UI Elements ---
@property (nonatomic, strong) UIVisualEffectView *blurContainer;
@property (nonatomic, strong) UISegmentedControl *tabControl;
@property (nonatomic, strong) UIView *itemsView, *settingsView, *moneyView;
@property (nonatomic, strong) UIButton *circleButton;
@property (nonatomic, strong) UIPickerView *itemPicker;

// --- Data & Search ---
@property (nonatomic, strong) NSArray *availableItems;
@property (nonatomic, strong) NSMutableArray *filteredItems;
@property (nonatomic, strong) UITextField *searchBar, *xField, *yField, *zField;
@property (nonatomic, strong) UIStepper *qtyStepper;
@property (nonatomic, strong) UILabel *qtyLabel;

// --- State Management ---
@property (nonatomic, assign) NSInteger selectedItemIndex;
@property (nonatomic, assign) BOOL isUnlocked;

// --- Core Methods ---
- (void)setupUI;
- (void)toggleMenu;
- (void)spawnSelectedItem;
- (void)giveMoney;

@end
