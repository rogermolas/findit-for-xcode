//
//  BrowserView.m
//  FindIt
//
//  Created by Roger Molas on 8/4/16.
//  Copyright © 2016 Roger Molas. All rights reserved.
//

#import "BrowserView.h"

static const CGFloat height = 44;
static const CGFloat width = 44;
static NSString * baseURL = @"http://stackoverflow.com/";

@implementation BrowserView

- (instancetype)initWithFrame:(NSRect)frame
                      isquery:(BOOL)isQuery
                  queryString:(NSString *)queryString {
    if (self = [super initWithFrame:frame frameName:@"" groupName:@""]) {
        [self autoresizesSubviews];
        [self setAcceptsTouchEvents:YES];
        [self backForwardList];
        [self drawsBackground];

        CGFloat xPos = frame.origin.x;
        CGFloat yPos = CGRectGetMaxY(frame) - 60;
        NSFont *font = [NSFont fontWithName:@"Helvetica" size:20];
        NSDictionary * attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
        
        UniChar back_ucode = 0x2190;
        NSString *backCode = [NSString stringWithCharacters:&back_ucode length:1];
        NSAttributedString *backTitle = [[NSAttributedString alloc] initWithString:backCode attributes:attributes];
        NSButton *back = [[NSButton alloc] initWithFrame:NSMakeRect(xPos,yPos,width,height)];
        [self addSubview: back];
        [back setAttributedTitle:backTitle];
        [back setAlignment:NSCenterTextAlignment];
        [back setButtonType:NSToggleButton];
        [back setBezelStyle:NSRegularSquareBezelStyle];
        [back setAction:@selector(goBack:)];
        
        UniChar forward_ucode = 0x2192;
        NSString *forwardCode = [NSString stringWithCharacters:&forward_ucode length:1];
        NSAttributedString *forwardTitle = [[NSAttributedString alloc] initWithString:forwardCode attributes:attributes];
        NSButton *forward = [[NSButton alloc] initWithFrame:NSMakeRect(xPos,back.frame.origin.y - height,width,height)];
        [self addSubview: forward];
        [forward setAttributedTitle:forwardTitle];
        [forward setAlignment:NSCenterTextAlignment];
        [forward setButtonType:NSToggleButton];
        [forward setBezelStyle:NSRegularSquareBezelStyle];
        [forward setAction:@selector(goForward:)];
        
        UniChar refresh_ucode = 0x21bb;
        NSString *refreshCode = [NSString stringWithCharacters:&refresh_ucode length:1];
        NSAttributedString *refreshTitle = [[NSAttributedString alloc] initWithString:refreshCode attributes:attributes];
        NSButton *reload = [[NSButton alloc] initWithFrame:NSMakeRect(xPos,forward.frame.origin.y - height,width,height)];
        [self addSubview: reload];
        [reload setAttributedTitle:refreshTitle];
        [reload setAlignment:NSCenterTextAlignment];
        [reload setButtonType:NSToggleButton];
        [reload setBezelStyle:NSRegularSquareBezelStyle];
        [reload setAction:@selector(reload:)];
        
        NSString *url;
        if (isQuery)
        {
            NSString *encodedString = [queryString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet
                                                                                                       URLUserAllowedCharacterSet]];
            url = [NSString stringWithFormat:@"%@search?q=%@",baseURL,encodedString];
        } else {
            url = baseURL;
        }
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [[self mainFrame] loadRequest:request];
    }
    return self;
}

- (void)searchString:(NSString *)strings {
    NSString *encodedString = [strings stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet
                                                                                               URLUserAllowedCharacterSet]];
    NSString *url = [NSString stringWithFormat:@"%@search?q=%@",baseURL,encodedString];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [[self mainFrame] loadRequest:request];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
}

@end
