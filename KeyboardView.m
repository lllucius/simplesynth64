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
static const int unknownNote = INT_MIN;

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
    int i, j, key;
    CGFloat x, width, height;
    CGRect rectWhite, rectBlack, textFrame;

    NSString *text;
    NSSize textSize;
    NSAttributedString *attributedString;
    NSDictionary *attributesNormal, *attributesHighlihted;
    NSFont *font;
    NSMutableParagraphStyle *paragraphStyle;
    CGContextRef context;

    // Get the white key dimensions
    height = CGRectGetHeight (frameRect);
    width = keyboardWidth / 52;

    // Draw background
    [[NSColor whiteColor] set];
    NSRectFill (NSMakeRect (0, 0, keyboardWidth, height));
    [[NSColor blackColor] set];

    // Set attributes for text
    paragraphStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
    [paragraphStyle setAlignment:NSCenterTextAlignment];

    font = [NSFont fontWithName:@"Helvetica" size:8];

    attributesNormal = [NSDictionary dictionaryWithObjectsAndKeys:
                        font, NSFontAttributeName,
                        [NSColor blackColor], NSForegroundColorAttributeName,
                        paragraphStyle, NSParagraphStyleAttributeName, nil];

    attributesHighlihted = [NSDictionary dictionaryWithObjectsAndKeys:
                            font, NSFontAttributeName,
                            [NSColor whiteColor], NSForegroundColorAttributeName,
                            paragraphStyle, NSParagraphStyleAttributeName, nil];

    // Traverse all the keys
    for (i=0; i<53; i++) {
        j = i % 7;
        key = 21 + i / 7 * 12;

        x = i * width;
        rectWhite = NSMakeRect (x, 0, width, height);
        rectBlack = NSMakeRect (x - width * 2 / 6, height * 2 / 5, width * 2 / 3, height);

        // Draw the white keys

        if (key + whiteKeysMapping[j] == curNote) {
            // Key is on draw it in highlighted color
            [[NSColor blueColor] set];
            NSRectFill (rectWhite);
            [[NSColor blackColor] set];
        }

        // Draw the text indicating the C key
        if ((key + whiteKeysMapping[j]) % 12 == 0) {
            context = [[NSGraphicsContext currentContext] graphicsPort];
            CGContextSaveGState (context);

            text = [NSString stringWithFormat:@"C%i", key / 12];
            if (key + whiteKeysMapping[j] == curNote) {
                attributedString = [[[NSAttributedString alloc] initWithString:text attributes:attributesHighlihted] autorelease];
            }
            else {
                attributedString = [[[NSAttributedString alloc] initWithString:text attributes:attributesNormal] autorelease];
            }

            textSize = [attributedString size];
            textFrame = NSMakeRect (x, 0 , width, textSize.height);
            [attributedString drawInRect:textFrame];

            CGContextRestoreGState (context);
        }

        // Skip drawing the lines at the left and right edges
        if (i == 0 || i == 52)
            continue;

        // Drawing the lines separating the white keys
        [NSBezierPath strokeLineFromPoint:NSMakePoint (x, 0) toPoint:NSMakePoint (x, height)];

        // Skip drawing the the black keys after E and B
        if (blackKeysMapping[j] == unknownNote)
            continue;

        // Draw the black keys
        if (key + blackKeysMapping[j] == curNote) {
            // Key is on draw it in highlighted color
            [[NSColor blueColor] set];
            NSRectFill (rectBlack);
            [[NSColor blackColor] set];
        }
        else {
            NSRectFill (rectBlack);
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
    int note  = [self keyForPoint:CGPointZero];
    if (curNote != unknownNote) {
        if ([delegate respondsToSelector:@selector(MIDINoteOff:)]) {
            [delegate MIDINoteOff:curNote];
        }
        [self setNeedsDisplay:YES];
    }
    curNote = note;
    //printf("%d\n", [self keyForPoint:curPoint]);
}


- (int)keyForPoint:(CGPoint)point
{
    int i, j, key;
    CGFloat x, width, height;
    CGRect rectWhite, rectBlackL, rectBlackR;

    height = CGRectGetHeight (self.frame);
    width = keyboardWidth / 52;
    i = point.x / width;
    j = i % 7;
    key = 21 + i / 7 * 12;
    x = i * width;
    rectWhite = NSMakeRect (x, 0, width, height);
    rectBlackL = NSMakeRect (x - width * 2 / 6, height * 2 / 5, width * 2 / 3, height);
    rectBlackR = NSMakeRect (x - width * 2 / 6 + width, height * 2 / 5, width * 2 / 3, height);

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
