#import "KeyboardView.h"


static int keyboardWidth = 780;


@implementation KeyboardView


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

        // White keys
        CGFloat x = i * width;
        CGRect rectWhite = NSMakeRect (x, 0, width, height);
        CGRect rectBlackL = NSMakeRect (x - width * 2 / 6, height / 2, width * 2 / 3, height);
        CGRect rectBlackR = NSMakeRect (x - width * 2 / 6 + width, height / 2, width * 2 / 3, height);

        if (!CGPointEqualToPoint (curPoint, NSZeroPoint)
            && CGRectContainsPoint (rectWhite, curPoint)
            && !(CGRectContainsPoint (rectBlackL, curPoint) && i != 0 && j != 2 && j != 5)
            && !(CGRectContainsPoint (rectBlackR, curPoint) && i != 51 && j != 1 && j != 4)) {
            // Key is on draw it in highlighted color
            [[NSColor blueColor] set];
            NSRectFill (rectWhite);
            [[NSColor blackColor] set];
        }

        if (i == 0 || i == 52)
            continue;

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
    //printf("%d\n", [self keyForPoint:curPoint]);
    [self setNeedsDisplay:YES];
}


- (void)mouseDragged:(NSEvent *)theEvent
{
    curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    //printf("%d\n", [self keyForPoint:curPoint]);
    [self setNeedsDisplay:YES];
}


- (void)mouseUp:(NSEvent *)theEvent
{
    curPoint = NSZeroPoint;
    [self setNeedsDisplay:YES];
}


- (int)keyForPoint:(CGPoint)point
{
    CGFloat height = CGRectGetHeight (self.frame);
    CGFloat width = keyboardWidth / 52;
    int i = point.x / width;
    int j = i % 7;
    int key = 21 + i / 7 * 12;

    CGFloat x = i * width;
    CGRect rectWhite = NSMakeRect (x, 0, width, height);
    CGRect rectBlackL = NSMakeRect (x - width * 2 / 6, height / 2, width * 2 / 3, height);
    CGRect rectBlackR = NSMakeRect (x - width * 2 / 6 + width, height / 2, width * 2 / 3, height);

    const int unknown = -1;
    const int whiteKeysMapping[] = {0,2,3,5,7,8,10};
    const int blackKeysMapping[] = {-1,1,unknown,4,6,unknown,9,11};

    // White keys
    if (!CGPointEqualToPoint (point, NSZeroPoint)
        && CGRectContainsPoint (rectWhite, point)
        && !(CGRectContainsPoint (rectBlackL, point) && i != 0 && j != 2 && j != 5)
        && !(CGRectContainsPoint (rectBlackR, point) && i != 51 && j != 1 && j != 4)) {
        key += whiteKeysMapping[j];
        return key;
    }
    // Black keys
    else if (!CGPointEqualToPoint (point, NSZeroPoint)
        && CGRectContainsPoint (rectBlackL, point)) {
        key += blackKeysMapping[j];
        return key;
    }
    else if (!CGPointEqualToPoint (point, NSZeroPoint)
             && CGRectContainsPoint (rectBlackR, point)) {
        key += blackKeysMapping[j+1];
        return key;
    }
    // Unkown key
    return unknown;
}


@end
