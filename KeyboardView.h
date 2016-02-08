#import <AppKit/AppKit.h>


@interface NSObject(KeyboardView)

- (void)MIDINoteOn:(int)note;
- (void)MIDINoteOff:(int)note;

@end


/*!
    @class		KeyboardView
        A simple NSView subclass that implements the graphic interface for a virtual MIDI keyboard.
*/
@interface KeyboardView : NSView {
    CGPoint curPoint;
    int curNote;
    id delegate;
}

- (void)setDelegate:(id)theDelegate;

@end
