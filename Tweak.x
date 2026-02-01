#import <UIKit/UIKit.h>

@interface AstraeusMenu : UIView
@property (nonatomic, strong) UIView *container;
@end

@implementation AstraeusMenu
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 450)];
        self.container.center = self.center;
        self.container.backgroundColor = [UIColor colorWithRed:0.1 green:0.0 blue:0.2 alpha:0.9];
        self.container.layer.cornerRadius = 20;
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 300, 40)];
        title.text = @"Astraeus";
        title.textColor = [UIColor whiteColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont boldSystemFontOfSize:22];
        [self.container addSubview:title];

        NSArray *tabs = @[@"Lackson", @"Astraeus", @"Robxify", @"Ratters", @"Skidders"];
        for (int i = 0; i < tabs.count; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
            btn.frame = CGRectMake(20, 60 + (i * 60), 260, 45);
            [btn setTitle:tabs[i] forState:UIControlStateNormal];
            btn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
            btn.layer.cornerRadius = 10;
            [self.container addSubview:btn];
        }
        [self addSubview:self.container];
    }
    return self;
}
@end

static AstraeusMenu *menu;

__attribute__((constructor)) static void init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        menu = [[AstraeusMenu alloc] initWithFrame:win.bounds];
        menu.hidden = YES;
        [win addSubview:menu];

        UIButton *tog = [UIButton buttonWithType:UIButtonTypeCustom];
        tog.frame = CGRectMake(40, 50, 160, 40);
        [tog setTitle:@"Open Astraeus Menu" forState:UIControlStateNormal];
        tog.backgroundColor = [UIColor purpleColor];
        tog.layer.cornerRadius = 15;
        [tog addTarget:menu action:@selector(setHidden:) forControlEvents:UIControlEventTouchUpInside];
        [win addSubview:tog];
    });
}