//
//  FindIt.h
//  FindIt
//
//  Created by Roger Molas on 8/1/16.
//  Copyright © 2016 Roger Molas. All rights reserved.
//

#import <AppKit/AppKit.h>

@class FindIt;
static FindIt *sharedPlugin;

@interface FindIt : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end