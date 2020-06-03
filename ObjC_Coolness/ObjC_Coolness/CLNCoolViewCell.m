// Copyright (C) 2020 About Objects, Inc. All Rights Reserved.
// See LICENSE.txt for this project's licensing information.

#import "CLNCoolViewCell.h"

IB_DESIGNABLE
@interface CLNCoolViewCell ()
@property (strong, nonatomic) IBInspectable NSColor *backgroundColor;
@property (getter=isHighlighted, nonatomic) BOOL highlighted;
@property NSUInteger repeatCount;
@end

@implementation CLNCoolViewCell

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self == nil) return nil;
    
    [self configureLayer];
    
    return self;
}

- (void)configureLayer {
    self.wantsLayer = YES;
    self.layer.borderWidth = 3;
    self.layer.borderColor = NSColor.whiteColor.CGColor;
    self.layer.backgroundColor = self.backgroundColor.CGColor;
    self.layer.cornerRadius = 6;
}

- (void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    [self configureLayer];
}

- (void)setBackgroundColor:(NSColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    self.layer.backgroundColor = backgroundColor.CGColor;
}

- (void)setHighlighted:(BOOL)highlighted {
    _highlighted = highlighted;
    self.alphaValue = highlighted ? 0.5 : 1;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    // TODO: Draw text
}

// MARK: - Animation

- (void)animate {
    NSLog(@"In %@", NSStringFromSelector(_cmd));
    NSLog(@"In %s", __func__);
    
    // NOTE: We don't actaully need to weakify self here, but are doing
    // so for the sake of illustration.
    typeof(self) __weak weakSelf = self;
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        NSAnimationContext.currentContext.allowsImplicitAnimation = YES;
        NSAnimationContext.currentContext.duration = 0.75;
        self.layer.anchorPoint = CGPointMake(0.5, 0.5);
        CATransform3D translation = CATransform3DMakeTranslation(60, -100, 0);
        weakSelf.animator.layer.transform = CATransform3DRotate(translation, -M_PI_2, 0, 0.5, 1);
    } completionHandler:^{
        [weakSelf animateReverse];
    }];
}

- (void)animateReverse {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        NSAnimationContext.currentContext.allowsImplicitAnimation = YES;
        NSAnimationContext.currentContext.duration = 1;
        self.animator.layer.transform = CATransform3DIdentity;
        self.repeatCount += 1;
    } completionHandler:^{
        if (self.repeatCount < 3) {
            [self animate];
        } else {
            self.repeatCount = 0;
        }
    }];
}

// MARK: - NSResponder methods

- (void)mouseDown:(NSEvent *)event {
    if (event.clickCount == 2) {
        [self animate];
        return;
    }
    
    self.highlighted = YES;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF != %@", self];
    NSArray *filteredSubviews = [self.superview.subviews filteredArrayUsingPredicate:predicate];
    self.superview.subviews = [filteredSubviews arrayByAddingObject:self];
}

- (void)mouseDragged:(NSEvent *)event {
    self.frame = NSOffsetRect(self.frame, event.deltaX, -event.deltaY);
}

- (void)mouseUp:(NSEvent *)event {
    self.highlighted = NO;
}

@end
