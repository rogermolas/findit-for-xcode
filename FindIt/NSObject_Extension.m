//
//  NSObject_Extension.m
//  FindIt
//
//  Created by Roger Molas on 8/1/16.
//  Copyright © 2016 Roger Molas. All rights reserved.
//


#import "NSObject_Extension.h"
#import "FindIt.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[FindIt alloc] initWithBundle:plugin];
        });
    }
}
@end
