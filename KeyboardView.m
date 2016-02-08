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
    CGFloat height = CGRectGetHeight(frameRect);

    [[NSColor whiteColor] set];
    NSRectFill (NSMakeRect(0, 0, keyboardWidth, height));

    [[NSColor blackColor] set];

    int width = keyboardWidth / 52;

    for (int i=0; i<53; i++) {
        CGFloat x = i * width;
        if (i == 0 || i == 52)
            continue;
        [NSBezierPath strokeLineFromPoint:NSMakePoint(x, 0) toPoint:NSMakePoint(x, height)];
    }

    for (int i=0; i<53; i++) {
        int j = i % 7;
        if (i == 0 || j == 2 || j == 5 || i == 52)
            continue;
        CGFloat x = i * width;
        NSRectFill (NSMakeRect(x - width * 2 / 6, height / 2, width * 2 / 3, height));
    }
}


- (void)setFrame:(NSRect)frame
{
    [super setFrame:NSMakeRect (0, 0, keyboardWidth, CGRectGetHeight(frame))];
}


@end
