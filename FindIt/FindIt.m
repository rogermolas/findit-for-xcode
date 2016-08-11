//
//  FindIt.m
//  FindIt
//
//  Created by Roger Molas on 8/1/16.
//  Copyright © 2016 Roger Molas. All rights reserved.
//

/** Methods and functions which cannot be used when compiling in automatic reference counting mode. */
#if !__has_feature(objc_arc)
#warning "available in automatic reference counting mode"
#endif

/** Object runtime */
#import <objc/runtime.h>
/** WebKit */
#import <WebKit/WebKit.h>
#import "Aspects.h"

#import "FindIt.h"
#import "BrowserView.h"

/** XCode Objects and Types */
#define __WORKSPACE_WINDOW__    "IDEWorkspaceWindowController"
#define __LAYOUT_MANAGER__      @"DVTLayoutManager"
#define __CODE_EDITOR___        @"IDESourceCodeEditor"
#define __CODE_COMPARISON__     @"IDESourceCodeComparisonEditor"
#define __CODE_SOURCE_VIEW___   @"DVTSourceTextView"
#define __KVO_SELECTED_TOKEN__  @"selectedText"
#define __KVO_HIGHLIGHT_TOKEN__ @"autoHighlightTokenRanges"
#define __KVO_TAB_TITLE__       @"title"

#define kIsBrowserEnabled       @"isBrowserEnabled"
#define kOpenBrowser            @"Open StackOverFlow"
#define kCloseBrowser           @"Close StackOverFlow"
#define kBrowseQuery            @"Search on StackOverFlow"
#define kBrowserTitle           @"StackOverFlow"

#if __has_feature(objc_arc)
#pragma mark - Interface
/** ================================================================================== */
/**                     Extracted XCode hearders by class dumping                      */
/** ================================================================================== */
@interface NSObject (WorkspaceWindow)
// Editor
@property(retain)   id textView;
@property(readonly) id editorArea;
@property(readonly) id keyTextView;
@property(nonatomic, retain) id editor;
@property(nonatomic, retain) id lastActiveEditorContext;
// Tab
@property(nonatomic, retain) id tabView;
@property(nonatomic) id tabButton;
// Navigator
@property(readonly) id navigatorArea;
@property(readonly) id activeWorkspaceTabController;
// Tab
@property(readonly, copy) id closeButton;

- (BOOL)isNavigatorVisible;
- (BOOL)isUtilitiesAreaVisible;
- (BOOL)showDebuggerArea;
- (void)toggleNavigatorsVisibility:(id)arg1;
- (void)toggleUtilitiesVisibility:(id)arg1;
- (void)toggleDebuggerVisibility:(id)arg;
- (id)workspaceWindowControllers;
- (id)splitViewItems;

- (id)_closeButtonClicked:(id)arg1;
@end

@interface NSObject (CompletingTextView)
- (id)menuForEvent:(id)arg1;
@end

@interface NSObject (LayoutManager)
@property(readonly, copy) NSArray *autoHighlightTokenRanges;
- (void)_displayAutoHighlightTokens;
- (id)layoutManager;
@end
#endif

@interface NSObject (MethodSwap)
+ (void)swizzleWithOriginalSelector:(SEL)originalSelector
                   swizzledSelector:(SEL)swizzledSelector
                      isClassMethod:(BOOL)isClassMethod;
@end

@interface FindIt()
@property(nonatomic, strong) NSMutableArray *ranges;
@property(nonatomic, strong) id currentTab;

@property(nonatomic, strong) NSBundle      *bundle;
@property(nonatomic, strong) BrowserView   *webView;
@property(nonatomic, strong) NSView        *currentView;
@property(nonatomic, strong) NSMenuItem    *actionMenuItem;
@property(nonatomic, strong) NSMenu        *contextMenu;
@property(nonatomic, strong) NSString      *queryString;
@property(nonatomic, strong) NSString      *selectedString;
@property(nonatomic, strong) NSString      *currentFileName;

@property(assign) BOOL isNavigatorOpen;
@property(assign) BOOL isUtilitiesOpen;
@property(assign) BOOL isDebuggerOpen;

@property(assign) BOOL isBrowserOpen;
@property(assign) BOOL isQuery;

- (void)selectedText;
@end

#pragma mark - Implementations
/** ================================================================================== */
/**                       Replace original method on runtime                           */
/** ================================================================================== */
@implementation NSObject (MethodSwap)
+ (void)swizzleWithOriginalSelector:(SEL)originalSelector
                   swizzledSelector:(SEL)swizzledSelector
                      isClassMethod:(BOOL)isClassMethod {
    NSCParameterAssert(originalSelector);
    NSCParameterAssert(swizzledSelector);
    
    Class cls = [self class];
    Method originalMethod;
    Method swizzledMethod;
    
    if (isClassMethod) {
        originalMethod = class_getClassMethod(cls, originalSelector);
        swizzledMethod = class_getClassMethod(cls, swizzledSelector);
    
    } else {
        originalMethod = class_getInstanceMethod(cls, originalSelector);
        swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
    }
    if (!originalMethod) {
        NSLog(@"Error: originalMethod is nil WTF! %@", originalMethod);
        return;
    }
    method_exchangeImplementations(originalMethod, swizzledMethod);
}
@end

/** ================================================================================== */
/**                         Base on original XCode IDE layout                          */
/** ================================================================================== */
@implementation NSObject (SelectedText)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSClassFromString(__LAYOUT_MANAGER__)
         swizzleWithOriginalSelector:@selector(_displayAutoHighlightTokens)
         swizzledSelector:@selector(my_displayAutoHighlightTokens) isClassMethod:NO];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIsBrowserEnabled];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
}
#pragma mark - Method Swizzling
- (void)my_displayAutoHighlightTokens {
    [[FindIt sharedPlugin] selectedText];
}
@end

/** ================================================================================== */
/**                     Views, Browser and Application state                           */
/** ================================================================================== */
@implementation FindIt
+ (instancetype)sharedPlugin {return sharedPlugin;}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _ranges = nil;
    _webView = nil;
    _currentView = nil;
    _actionMenuItem = nil;
    _contextMenu = nil;
    _queryString = nil;
    _currentTab = nil;
    _selectedString = nil;
    _currentFileName = nil;
}

#if __has_feature(objc_arc)
- (id)initWithBundle:(NSBundle *)plugin {
    if (self = [super init]) {
        self.bundle = plugin;  // reference to plugin's bundle, for resource access
        sharedPlugin = self;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification object:nil];
        Class c = NSClassFromString(__CODE_SOURCE_VIEW___);
        [c aspect_hookSelector:@selector(menuForEvent:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info, NSEvent *event) {
            if (event.type == NSRightMouseDown) {
                NSInvocation *invocation = info.originalInvocation;;
                NSMenu *contextMenu;
                [invocation invoke];
                [invocation getReturnValue:&contextMenu];
                CFRetain((__bridge CFTypeRef)(contextMenu));
                NSMenuItem* newItem = [[NSMenuItem alloc] initWithTitle:kBrowseQuery
                                                                 action:@selector(querySearch:) keyEquivalent:@""];
                [newItem setTarget:self];
                [contextMenu insertItem:newItem atIndex:3];
                [invocation setReturnValue:&contextMenu];
            }
        } error:NULL];
    }
    return self;
}
#endif

- (void)setQueryString:(NSString *)queryString {
    if (_queryString != queryString)
        _queryString = queryString;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSApplicationDidFinishLaunchingNotification
                                                  object:nil];
    NSMenuItem *menuItem = [[NSApp mainMenu]itemWithTitle:@"View"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        _actionMenuItem = [[NSMenuItem alloc] initWithTitle:kOpenBrowser action:@selector(toggleBrowser) keyEquivalent:@""];
        [_actionMenuItem setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
        [_actionMenuItem setTarget:self];
        [[menuItem submenu] addItem:_actionMenuItem];
    }
}

- (BOOL)isOpen {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kIsBrowserEnabled];
}

- (void)querySearch:(NSString *)query {
    _isQuery = YES;
   
    if (_webView != nil && _isBrowserOpen) {
        if ([self currentTab_] != _currentTab) {
            [(NSTabView *)[self tabView_]selectTabViewItem:_currentTab];
            [_webView searchString:_queryString];
            return;
        }
    }
    [self toggleBrowserSearch];
}

- (void)toggleBrowserSearch {
    BOOL status = [self isOpen];
    if (status && _isBrowserOpen)
        [self resetWorkspace];
    if (!status && !_isBrowserOpen)
        [self setworkSpaceBrowser];
    
    [[NSUserDefaults standardUserDefaults] setBool:!status forKey:kIsBrowserEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)toggleBrowser {
    _isQuery = NO;
    _queryString = @"";
    BOOL status = [self isOpen];
    if (status && _isBrowserOpen) {
        if (_webView != nil && _isBrowserOpen) {
            if ([self currentTab_] != _currentTab) {
                [(NSTabView *)[self tabView_]selectTabViewItem:_currentTab];
            }
        }
        [self resetWorkspace];
    } else if (!status && !_isBrowserOpen) {
        [self setworkSpaceBrowser];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:!status forKey:kIsBrowserEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setworkSpaceBrowser {
    /** Navigator Area */
    id navigatorArea = [self _navigatorArea];
    if ([navigatorArea isNavigatorVisible]) {
        [navigatorArea toggleNavigatorsVisibility:nil];
        _isNavigatorOpen = YES;
    }
    /** Utilities Area */
    id tabController = [self _navigatorArea];
    if ([tabController isUtilitiesAreaVisible]) {
        [tabController toggleUtilitiesVisibility:nil];
        _isUtilitiesOpen = YES;
    }
    /** Debugger Area */
    id editorArea = [self _editorArea];
    if ([editorArea showDebuggerArea]) {
        [editorArea toggleDebuggerVisibility:nil];
        _isDebuggerOpen = YES;
    }
    
    NSRect frame = [[[self _editorArea] view] bounds];
    NSView *currentView = [[[[self _editorArea] view] subviews] objectAtIndex:0];
    _currentView = currentView;  // reference the current view
    
    WebView *WV = [self loadWebView:frame];
    [[[self _editorArea] view] replaceSubview:currentView with:WV];
    _isBrowserOpen = YES;
    _queryString = @"";
    [_actionMenuItem setTitle:kCloseBrowser];
    
    // Get the current selected Tab
    _currentTab = [self currentTab_];
    _currentFileName = [[_currentTab tabButton] title];
    [[_currentTab tabButton] setTitle:kBrowserTitle];
    [(NSButton *)[[_currentTab tabButton]closeButton] setTarget:self];
    [(NSButton *)[[_currentTab tabButton]closeButton]setAction:@selector(beforeCloseSelector)];
   
    // Observe changes for title property
    [[_currentTab tabButton] addObserver:self forKeyPath:__KVO_TAB_TITLE__ options:NSKeyValueObservingOptionNew context:nil];
}

- (void)resetWorkspace {
    NSView *currentView = [[[[self _editorArea] view] subviews] objectAtIndex:0];
    [[[self _editorArea]view] replaceSubview:currentView with:_currentView];
    if (_webView != nil) {
        _webView = nil;
        _isBrowserOpen = NO;
    }
    /** Navigator Area */
    id navigatorArea = [self _navigatorArea];
    if (![navigatorArea isNavigatorVisible] && _isNavigatorOpen) {
        [navigatorArea toggleNavigatorsVisibility:self];
        _isNavigatorOpen = NO;
    }
    /** Utilities Area */
    id tabController = [self _navigatorArea];
    if (![tabController isUtilitiesAreaVisible] && _isUtilitiesOpen) {
        [tabController toggleUtilitiesVisibility:self];
        _isUtilitiesOpen = NO;
    }
    /** Debugger Area */
    id editorArea = [self _editorArea];
    if (![editorArea showDebuggerArea] && _isDebuggerOpen) {
        [editorArea toggleDebuggerVisibility:self];
        _isDebuggerOpen = NO;
    }
    
    [[_currentTab tabButton] setTitle:_currentFileName];
    [[_currentTab tabButton] removeObserver:self forKeyPath:__KVO_TAB_TITLE__];
    [_actionMenuItem setTitle:kOpenBrowser];
}

#pragma mark - Key Value Observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqual: __KVO_TAB_TITLE__]) {
        if (_webView != nil && _isBrowserOpen) {
            if (![[[_currentTab tabButton] title] isEqualToString:kBrowserTitle]) {
                [[_currentTab tabButton] setTitle:kBrowserTitle];
            }
        } else {
            if (![[[_currentTab tabButton] title] isEqualToString:_currentFileName]) {
                [[_currentTab tabButton] setTitle:_currentFileName];
            }
        }
    }
}

- (void)beforeCloseSelector {
    [[_currentTab tabButton]_closeButtonClicked:nil];
    if (_webView != nil) {
        _webView = nil;
    }
    _isBrowserOpen = NO;
    _isNavigatorOpen = NO;
    _isUtilitiesOpen = NO;
    _isDebuggerOpen = NO;
    
    [[_currentTab tabButton] removeObserver:self forKeyPath:__KVO_TAB_TITLE__];
    [_actionMenuItem setTitle:kOpenBrowser];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIsBrowserEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Web View
- (WebView *)loadWebView:(NSRect)frame {
    if (_webView != nil) _webView = nil;
    _webView = [[BrowserView alloc] initWithFrame:frame isquery:_isQuery queryString:_queryString];
    return _webView;
}

/** ================================================================================== */
/**                           IDE Windows and Views                                    */
/** ================================================================================== */
#pragma mark - IDE WorkSpace
- (NSArray *)_workSpaceControllers {
    return [objc_getClass(__WORKSPACE_WINDOW__)workspaceWindowControllers];
}

- (id)_navigatorArea {
    for (NSWindowController *workspaceWindowController in [self _workSpaceControllers]) {
        if ([workspaceWindowController activeWorkspaceTabController]!= nil)
            return [workspaceWindowController activeWorkspaceTabController];
    }
    return nil;
}

- (id)_editorArea {
    for (NSWindowController *workspaceWindowController in [self _workSpaceControllers]) {
        if ([workspaceWindowController editorArea]!= nil)
            return [workspaceWindowController editorArea];
    }
    return nil;
}

- (id)tabView_ {
    for (NSWindowController *workspaceWindowController in [self _workSpaceControllers]) {
        if ([workspaceWindowController activeWorkspaceTabController] != nil)
            return [workspaceWindowController tabView];
    }
    return nil;
}

- (id)currentTab_ {
   return [[self tabView_] selectedTabViewItem];
}

- (id)currentSourceTextView {
    id currentEditor = [self currentTextEditor];
    if ([currentEditor isKindOfClass:NSClassFromString(__CODE_EDITOR___)])
        return [(id)currentEditor textView];
    
    if ([currentEditor isKindOfClass:NSClassFromString(__CODE_COMPARISON__)])
        return [(id)currentEditor performSelector:@selector(keyTextView)];
    
    NSCAssert(currentEditor != nil, @"Must have correct type.");
    return nil;
}

- (id)currentTextEditor {
    id editorArea = [self _editorArea];
    id editorContext = [editorArea lastActiveEditorContext];
    return [editorContext editor];
}

#pragma mark - Code Editor
- (void)selectedText {
    id currentEditor = [self currentTextEditor];
    id textView = [self currentSourceTextView];
    id layoutManager = [textView layoutManager];
    
    NSString *charString = [[textView textStorage] string];
    NSString *selectedString = [currentEditor valueForKey:__KVO_SELECTED_TOKEN__];
    if ([selectedString length] > 0 || ![selectedString isEqualToString:@""]) {
        self.queryString = selectedString;
    
    } else {
        NSArray *objects = [layoutManager valueForKey:__KVO_HIGHLIGHT_TOKEN__];
        [objects enumerateObjectsUsingBlock:^(NSValue *range, NSUInteger idx, BOOL *stop) {
            NSString *cursorString = [[charString substringWithRange:[range rangeValue]]
                                      stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([cursorString length] > 0 && [selectedString length] <= 0)
                self.queryString = cursorString;
        }];
        
        [self.ranges addObjectsFromArray:[layoutManager autoHighlightTokenRanges]];
        [textView setNeedsDisplay:YES];
    }
}
@end
