#import "KeyboardView.h"


@implementation KeyboardView

static int keyboardWidth = 780;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
    }
    
    return self;
}


- (void)drawRect:(NSRect)frameRect
{
    CGFloat height = CGRectGetHeight (frameRect);
    CGFloat width = keyboardWidth / 52;

    [[NSColor whiteColor] set];
    NSRectFill (NSMakeRect (0, 0, keyboardWidth, height));

    [[NSColor blackColor] set];

    for (int i=0; i<53; i++) {
        int j = i % 7;
        if (i == 0 || i == 52)
            continue;

        // White keys
        CGFloat x = i * width;
        CGRect rectWhite = NSMakeRect (x, 0, width, height);
        CGRect rectBlackL = NSMakeRect (x - width * 2 / 6, height / 2, width * 2 / 3, height);
        CGRect rectBlackR = NSMakeRect (x - width * 2 / 6 + width, height / 2, width * 2 / 3, height);

        if (!CGPointEqualToPoint (curPoint, NSZeroPoint)
            && CGRectContainsPoint (rectWhite, curPoint)
            && !CGRectContainsPoint (rectBlackL, curPoint)
            && !CGRectContainsPoint (rectBlackR, curPoint)) {
            // Key is on draw it in highlighted color
            [[NSColor blueColor] set];
            NSRectFill (rectWhite);
            [[NSColor blackColor] set];
        }

        [NSBezierPath strokeLineFromPoint:NSMakePoint (x, 0) toPoint:NSMakePoint (x, height)];

        if (j == 2 || j == 5)
            continue;

        // Black keys
        if (!CGPointEqualToPoint (curPoint, NSZeroPoint)
            && CGRectContainsPoint (rectBlackL, curPoint)) {
            // Key is on draw it in highlighted color
            [[NSColor blueColor] set];
            NSRectFill (rectBlackL);
            [[NSColor blackColor] set];
        }
        else {
            NSRectFill (rectBlackL);
        }
    }
}


- (void)setFrame:(NSRect)frame
{
    [super setFrame:NSMakeRect (0, 0, keyboardWidth, CGRectGetHeight(frame))];
}


- (void)mouseDown:(NSEvent *)theEvent
{
    curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    [self setNeedsDisplay:YES];
}


- (void)mouseDragged:(NSEvent *)theEvent
{
    curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    [self setNeedsDisplay:YES];
}


- (void)mouseUp:(NSEvent *)theEvent
{
    curPoint = NSZeroPoint;
    [self setNeedsDisplay:YES];
}

@end
