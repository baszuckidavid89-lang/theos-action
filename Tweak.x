#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioServices.h>

@interface AstraeusMenu : UIView
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIScrollView *scroll;
@property (nonatomic, strong) CAShapeLayer *rgbLayer;
@property (nonatomic, strong) CAEmitterLayer *particleLayer;
@property (nonatomic, strong) UIView *overlay;
@property (nonatomic, strong) NSTimer *discoTimer;
@property (nonatomic, strong) UIVisualEffectView *blurView;
@end

@implementation AstraeusMenu

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        self.container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 330, 550)];
        self.container.center = self.center;
        self.container.backgroundColor = [UIColor colorWithRed:0.02 green:0.02 blue:0.08 alpha:1.0];
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
    NSArray *list = (cat == 0) ? @[@"RGB Border", @"Screen Shake", @"Confetti", @"Snowfall", @"Invert", @"Night Vision", @"Neon Mode", @"Sparkles", @"Motion Blur", @"Grayscale"] : 
                    (cat == 1) ? @[@"Fake Crash", @"Ghost Touch", @"Upside Down", @"Battery 1%", @"Glitch Effect", @"Meme Popups", @"SpeedUp UI", @"SlowMo UI", @"Infinite Vibrate", @"Reverse Text"] : 
                                 @[@"Matrix Rain", @"Disco Mode", @"Water Ripple", @"Fire Effect", @"Gravity Box", @"Magnifier", @"Flashbang", @"Bouncing Menu", @"Pixelate", @"Warp Drive"];

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
    
    switch (s.tag) {
        // --- VISUALS ---
        case 0: if(s.on) { self.rgbLayer = [CAShapeLayer layer]; self.rgbLayer.path = [UIBezierPath bezierPathWithRoundedRect:win.bounds cornerRadius:40].CGPath; self.rgbLayer.fillColor = nil; self.rgbLayer.lineWidth = 10; [win.layer addSublayer:self.rgbLayer]; CABasicAnimation *a = [CABasicAnimation animationWithKeyPath:@"strokeColor"]; a.toValue = (id)[UIColor cyanColor].CGColor; a.fromValue = (id)[UIColor purpleColor].CGColor; a.duration = 0.5; a.autoreverses = YES; a.repeatCount = HUGE_VALF; [self.rgbLayer addAnimation:a forKey:@"rgb"]; } else [self.rgbLayer removeFromSuperlayer]; break;
        case 1: if(s.on) { CABasicAnimation *sh = [CABasicAnimation animationWithKeyPath:@"position"]; sh.duration = 0.04; sh.repeatCount = HUGE_VALF; sh.autoreverses = YES; sh.fromValue = [NSValue valueWithCGPoint:CGPointMake(win.center.x-10, win.center.y)]; sh.toValue = [NSValue valueWithCGPoint:CGPointMake(win.center.x+10, win.center.y)]; [win.layer addAnimation:sh forKey:@"sh"]; } else [win.layer removeAnimationForKey:@"sh"]; break;
        case 2: case 3: if(s.on) { self.particleLayer = [CAEmitterLayer layer]; self.particleLayer.emitterPosition = CGPointMake(win.center.x, -10); self.particleLayer.emitterShape = kCAEmitterLayerLine; self.particleLayer.emitterSize = CGSizeMake(win.bounds.size.width, 1); CAEmitterCell *c = [CAEmitterCell emitterCell]; c.birthRate = 25; c.lifetime = 5.0; c.velocity = 100; c.contents = (id)[self drawParticle:(s.tag==2)].CGImage; self.particleLayer.emitterCells = @[c]; [win.layer addSublayer:self.particleLayer]; } else [self.particleLayer removeFromSuperlayer]; break;
        case 4: win.layer.rasterizationScale = s.on ? -1.0 : 1.0; win.layer.shouldRasterize = s.on; break;
        case 5: win.backgroundColor = s.on ? [UIColor greenColor] : nil; win.alpha = s.on ? 0.6 : 1.0; break;
        case 6: win.layer.shadowColor = s.on ? [UIColor purpleColor].CGColor : nil; win.layer.shadowOpacity = s.on ? 1 : 0; win.layer.shadowRadius = 20; break;
        case 8: if(s.on) { self.blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]]; self.blurView.frame = win.bounds; [win insertSubview:self.blurView atIndex:0]; } else [self.blurView removeFromSuperview]; break;
        case 9: win.layer.filters = s.on ? @[[CIFilter filterWithName:@"CIPhotoEffectNoir"]] : nil; break;

        // --- PRANKS ---
        case 10: exit(0); break;
        case 11: win.userInteractionEnabled = !s.on; break;
        case 12: win.transform = s.on ? CGAffineTransformMakeScale(1, -1) : CGAffineTransformIdentity; break;
        case 13: { UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Battery" message:@"1% remain" preferredStyle:1]; [a addAction:[UIAlertAction actionWithTitle:@"OK" style:0 handler:nil]]; [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:a animated:YES completion:nil]; s.on = NO; } break;
        case 14: if(s.on) win.alpha = 0.1; else win.alpha = 1.0; break; 
        case 18: if(s.on) { [NSTimer scheduledTimerWithTimeInterval:0.4 repeats:YES block:^(NSTimer *t){ if(!s.on)[t invalidate]; AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); }]; } break;

        // --- CHAOS ---
        case 20: if(s.on) { self.overlay = [[UIView alloc] initWithFrame:win.bounds]; self.overlay.backgroundColor = [UIColor blackColor]; self.overlay.alpha = 0.5; UILabel *l = [[UILabel alloc] initWithFrame:win.bounds]; l.text = @"1010101101\n0110110101"; l.textColor = [UIColor greenColor]; l.numberOfLines = 0; [self.overlay addSubview:l]; [win addSubview:self.overlay]; } else [self.overlay removeFromSuperview]; break;
        case 21: if(s.on) { self.discoTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer *t){ win.backgroundColor = [UIColor colorWithRed:drand48() green:drand48() blue:drand48() alpha:0.4]; if(!s.on){ win.backgroundColor = nil; [t invalidate]; } }]; } break;
        case 25: win.transform = s.on ? CGAffineTransformMakeScale(2.0, 2.0) : CGAffineTransformIdentity; break; 
        case 26: { UIView *v = [[UIView alloc] initWithFrame:win.bounds]; v.backgroundColor = [UIColor whiteColor]; [win addSubview:v]; [UIView animateWithDuration:2 animations:^{v.alpha=0;} completion:^(BOOL f){[v removeFromSuperview]; s.on=NO;}]; } break;
        case 29: [UIView animateWithDuration:1 animations:^{ win.transform = s.on ? CGAffineTransformMakeScale(0.01, 0.01) : CGAffineTransformIdentity; }]; break;
    }
    AudioServicesPlaySystemSound(1521); 
}

- (UIImage *)drawParticle:(BOOL)isConfetti {
    UIGraphicsBeginImageContext(CGSizeMake(10, 10)); CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, isConfetti ? [UIColor orangeColor].CGColor : [UIColor whiteColor].CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, 10, 10));
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext(); UIGraphicsEndImageContext(); return img;
}

- (void)changeCategory:(UIButton *)b { [self loadModsForCategory:b.tag]; }
- (void)toggle { [UIView animateWithDuration:0.3 animations:^{ self.hidden = !self.hidden; }]; }
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
