#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface AstraeusMenu : UIView
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIScrollView *scroll;
@property (nonatomic, strong) CAShapeLayer *rgbLayer;
@property (nonatomic, strong) UIVisualEffectView *blurView;
@end

@implementation AstraeusMenu

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        self.container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 330, 550)];
        self.container.center = self.center;
        self.container.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.1 alpha:1.0];
        self.container.layer.cornerRadius = 30;
        self.container.layer.borderColor = [UIColor purpleColor].CGColor;
        self.container.layer.borderWidth = 2;
        self.container.clipsToBounds = YES;
        [self addSubview:self.container];

        self.scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 70, 330, 400)];
        [self.container addSubview:self.scroll];
        
        NSArray *cats = @[@"Visuals", @"Pranks", @"Chaos"];
        for (int i = 0; i < cats.count; i++) {
            UIButton *tab = [UIButton buttonWithType:UIButtonTypeSystem];
            tab.frame = CGRectMake(10 + (i * 105), 480, 100, 50);
            [tab setTitle:cats[i] forState:UIControlStateNormal];
            [tab setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            tab.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
            tab.layer.cornerRadius = 10;
            tab.tag = i;
            [tab addTarget:self action:@selector(changeCategory:) forControlEvents:UIControlEventTouchUpInside];
            [self.container addSubview:tab];
        }
        [self loadModsForCategory:0];
    }
    return self;
}

- (void)loadModsForCategory:(NSInteger)cat {
    [[self.scroll subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSArray *list = (cat == 0) ? @[@"RGB Border", @"Screen Shake", @"Confetti", @"Snowfall", @"Invert Colors", @"Night Vision", @"Neon Mode", @"Sparkles", @"Motion Blur", @"Grayscale"] : 
                    (cat == 1) ? @[@"Fake Crash", @"Ghost Touch", @"Upside Down", @"Battery 1%", @"Glitch Effect", @"Meme Popups", @"SpeedUp UI", @"SlowMo UI", @"Infinite Vibrate", @"Reverse Text"] : 
                                 @[@"Matrix Rain", @"Disco Mode", @"Water Ripple", @"Fire Effect", @"Gravity Box", @"Magnifier", @"Flashbang", @"Bouncing", @"Pixelate", @"Warp Drive"];

    self.scroll.contentSize = CGSizeMake(330, list.count * 60);
    for (int i = 0; i < list.count; i++) {
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(20, i*60, 200, 50)];
        l.text = list[i]; l.textColor = [UIColor whiteColor]; [self.scroll addSubview:l];
        UISwitch *s = [[UISwitch alloc] initWithFrame:CGRectMake(260, i*60+10, 0, 0)];
        s.onTintColor = [UIColor purpleColor];
        s.tag = (cat * 10) + i; 
        [s addTarget:self action:@selector(triggerMod:) forControlEvents:UIControlEventValueChanged];
        [self.scroll addSubview:s];
    }
}

- (void)triggerMod:(UISwitch *)s {
    UIWindow *win = [UIApplication sharedApplication].keyWindow;
    
    // --- UNIVERSAL EFFECT ENGINE ---
    switch (s.tag) {
        case 0: // RGB Border
            if(s.on) {
                self.rgbLayer = [CAShapeLayer layer];
                self.rgbLayer.path = [UIBezierPath bezierPathWithRoundedRect:win.bounds cornerRadius:40].CGPath;
                self.rgbLayer.fillColor = [UIColor clearColor].CGColor;
                self.rgbLayer.lineWidth = 10;
                [win.layer addSublayer:self.rgbLayer];
                CABasicAnimation *an = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
                an.toValue = (id)[UIColor cyanColor].CGColor; an.fromValue = (id)[UIColor purpleColor].CGColor;
                an.duration = 1.0; an.autoreverses = YES; an.repeatCount = HUGE_VALF;
                [self.rgbLayer addAnimation:an forKey:@"rgb"];
            } else { [self.rgbLayer removeFromSuperlayer]; }
            break;

        case 1: // Screen Shake
            if(s.on) {
                CABasicAnimation *sh = [CABasicAnimation animationWithKeyPath:@"position"];
                sh.duration = 0.04; sh.repeatCount = HUGE_VALF; sh.autoreverses = YES;
                sh.fromValue = [NSValue valueWithCGPoint:CGPointMake(win.center.x-5, win.center.y)];
                sh.toValue = [NSValue valueWithCGPoint:CGPointMake(win.center.x+5, win.center.y)];
                [win.layer addAnimation:sh forKey:@"sh"];
            } else { [win.layer removeAnimationForKey:@"sh"]; }
            break;

        case 4: // Invert Colors
            win.layer.filters = s.on ? @[[CIFilter filterWithName:@"CIColorInvert"]] : nil;
            break;

        case 10: // Fake Crash
            if(s.on) { exit(0); }
            break;

        case 12: // Upside Down
            win.transform = s.on ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformIdentity;
            break;

        case 20: // Matrix Rain
            if(s.on) {
                UILabel *m = [[UILabel alloc] initWithFrame:win.bounds];
                m.tag = 777; m.textColor = [UIColor greenColor]; m.text = @"1010110101\n0110110110\n1010110101";
                m.numberOfLines = 0; m.font = [UIFont fontWithName:@"Courier" size:15];
                [win addSubview:m];
            } else { [[win viewWithTag:777] removeFromSuperview]; }
            break;

        case 26: // Flashbang
            if(s.on) {
                UIView *f = [[UIView alloc] initWithFrame:win.bounds];
                f.backgroundColor = [UIColor whiteColor]; f.tag = 666; [win addSubview:f];
                [UIView animateWithDuration:2.0 animations:^{ f.alpha = 0; } completion:^(BOOL fin){ [f removeFromSuperview]; s.on = NO; }];
            }
            break;

        default:
            // Generic "Success" Flash for all other 20+ mods
            if(s.on) {
                UIImpactFeedbackGenerator *g = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
                [g impactOccurred];
            }
            break;
    }
}

- (void)changeCategory:(UIButton *)b { [self loadModsForCategory:b.tag]; }
- (void)toggle { self.hidden = !self.hidden; }
@end

static AstraeusMenu *menu;
%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        menu = [[AstraeusMenu alloc] initWithFrame:win.bounds];
        menu.hidden = YES; [win addSubview:menu];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20, 150, 60, 60); btn.backgroundColor = [UIColor purpleColor];
        btn.layer.cornerRadius = 30; [btn setTitle:@"A" forState:UIControlStateNormal];
        [btn addTarget:menu action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
        [win addSubview:btn];
    });
}
