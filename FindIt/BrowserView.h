//
//  BrowserView.h
//  FindIt
//
//  Created by Roger Molas on 8/4/16.
//  Copyright © 2016 Roger Molas. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface BrowserView : WebView
- (instancetype)initWithFrame:(NSRect)frame
                      isquery:(BOOL)isQuery
                  queryString:(NSString *)queryString;

- (void)searchString:(NSString *)strings;
@end
