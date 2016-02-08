#import "KeyboardView.h"


@implementation KeyboardScrollView


- (void)awakeFromNib
{
    const CGFloat midX = NSMidX([[self documentView] bounds]);
    const CGFloat midY = NSMidY([[self documentView] bounds]);

    const CGFloat halfWidth = NSWidth([[self contentView] frame]) / 2.0;
    const CGFloat halfHeight = NSHeight([[self contentView] frame]) / 2.0;

    NSPoint newOrigin;
    if([[self documentView] isFlipped])
    {
        newOrigin = NSMakePoint(midX - halfWidth, midY + halfHeight);
    }
    else
    {
        newOrigin = NSMakePoint(midX - halfWidth, midY - halfHeight);
    }

    [[self documentView] scrollPoint:newOrigin];
}


@end


static const int keyboardWidth = 780;
static const int unknownNote = -1;

static const int whiteKeysMapping[] = {0,2,3,5,7,8,10};
static const int blackKeysMapping[] = {-1,1,unknownNote,4,6,unknownNote,9,11};


@implementation KeyboardView


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
    }
    
    return self;
}


- (void)awakeFromNib
{
    curNote = unknownNote;
}


- (void)setDelegate:(id)theDelegate
{
    delegate = theDelegate;
}


- (void)drawRect:(NSRect)frameRect
{
    CGFloat height = CGRectGetHeight (frameRect);
    CGFloat width = keyboardWidth / 52;

    // Draw the background
    [[NSColor whiteColor] set];
    NSRectFill (NSMakeRect (0, 0, keyboardWidth, height));
    [[NSColor blackColor] set];

    // Set the attributes for the text
    NSMutableParagraphStyle * paragraphStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
    [paragraphStyle setAlignment:NSCenterTextAlignment];

    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSFont fontWithName:@"Helvetica" size:8], NSFontAttributeName,
                                [NSColor blackColor], NSForegroundColorAttributeName,
                                [NSColor clearColor], NSBackgroundColorAttributeName,
                                paragraphStyle, NSParagraphStyleAttributeName, nil];

    // Traverse all the keys
    for (int i=0; i<53; i++) {
        int j = i % 7;

        // White keys
        CGFloat x = i * width;
        CGRect rectWhite = NSMakeRect (x, 0, width, height);
        CGRect rectBlackL = NSMakeRect (x - width * 2 / 6, 2 * height / 5, width * 2 / 3, height);
        CGRect rectBlackR = NSMakeRect (x - width * 2 / 6 + width, 2 * height / 5, width * 2 / 3, height);

        if (curNote != unknownNote
            && CGRectContainsPoint (rectWhite, curPoint)
            && !(CGRectContainsPoint (rectBlackL, curPoint) && i != 0 && j != 2 && j != 5)
            && !(CGRectContainsPoint (rectBlackR, curPoint) && i != 51 && j != 1 && j != 4)) {

            // Key is on draw it in highlighted color
            [[NSColor blueColor] set];
            NSRectFill (rectWhite);
            [[NSColor blackColor] set];
        }

        // Draw the text indicating the C key
        int key = 21 + i / 7 * 12 + whiteKeysMapping[j];
        if (key % 12 == 0) {
            NSString *text = [NSString stringWithFormat:@"C%i", (key / 12) - 1];
            NSAttributedString *attributedString = [[[NSAttributedString alloc] initWithString:text attributes:attributes] autorelease];
            NSSize textSize = [attributedString size];
            NSRect textFrame = { { x, 0 }, { width, textSize.height } };
            [attributedString drawInRect:textFrame];
        }

        // Skip drawing the lines at the left and right margins
        if (i == 0 || i == 52)
            continue;

        // Drawing the lines separating the white keys
        [NSBezierPath strokeLineFromPoint:NSMakePoint (x, 0) toPoint:NSMakePoint (x, height)];

        // Skip drawing the the black keys after E and B
        if (j == 2 || j == 5)
            continue;

        // Black keys
        if (curNote != unknownNote
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
    CGPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    int note  = [self keyForPoint:point];
    if (note != curNote) {
        if (curNote != unknownNote) {
            if ([delegate respondsToSelector:@selector(MIDINoteOff:)]) {
                [delegate MIDINoteOff:curNote];
            }
            [self setNeedsDisplay:YES];
        }
        curNote = note;
        curPoint = point;
        if (curNote != unknownNote) {
            if ([delegate respondsToSelector:@selector(MIDINoteOn:)]) {
                [delegate MIDINoteOn:curNote];
            }
            [self setNeedsDisplay:YES];
        }
    }
    //printf("%d\n", [self keyForPoint:curPoint]);
}


- (void)mouseDragged:(NSEvent *)theEvent
{
    [self mouseDown:theEvent];
    //printf("%d\n", [self keyForPoint:curPoint]);
}


- (void)mouseUp:(NSEvent *)theEvent
{
    CGPoint point = CGPointZero;
    int note  = [self keyForPoint:point];
    if (curNote != unknownNote) {
        if ([delegate respondsToSelector:@selector(MIDINoteOff:)]) {
            [delegate MIDINoteOff:curNote];
        }
        [self setNeedsDisplay:YES];
    }
    curNote = note;
    curPoint = point;
    //printf("%d\n", [self keyForPoint:curPoint]);
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
    return unknownNote;
}


@end
