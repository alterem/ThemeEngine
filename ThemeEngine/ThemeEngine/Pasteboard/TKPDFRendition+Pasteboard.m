//
//  TKPDFRendition+Pasteboard.m
//  ThemeEngine
//
//  Created by Jeremy on 10/26/23.
//  Copyright © 2023 Alex Zielenski. All rights reserved.
//

#import "TKPDFRendition+Pasteboard.h"
NSString *const TEPDFPasteboardType = @"com.alexzielenski.themekit.rendition.pdf";

@implementation TKPDFRendition (Pasteboard)
- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    
    return [[super writableTypesForPasteboard:pasteboard] arrayByAddingObjectsFromArray:
            @[
              self.mainDataType
              ]];
}

- (NSArray *)readableTypes {
    return [[super readableTypes] arrayByAddingObjectsFromArray:@[
                                                                  self.mainDataType,
                                                                  (__bridge NSString *)kUTTypeFileURL,
                                                                  (__bridge NSString *)kUTTypeURL
                                                                  ]];
}

- (NSString *)mainDataType {
    return self.utiType;
}

- (id)pasteboardPropertyListForType:(nonnull NSString *)type {
    if ([type isEqualToString:self.mainDataType] || [type isEqualToString:TEPDFPasteboardType]) {
        return self.rawData;
    }
    
    return [super pasteboardPropertyListForType:type];
}

- (BOOL)readFromPasteboardItem:(NSPasteboardItem *)item {
    NSString *type = [item availableTypeFromArray:@[ TEPDFPasteboardType, self.mainDataType, (__bridge NSString *)kUTTypeURL, (__bridge NSString *)kUTTypeFileURL ]];
    if (!type) return NO;
    
    NSData *data = NULL;
    if (IS(kUTTypeURL) || IS(kUTTypeFileURL)) {
        NSURL *fileURL = [NSURL URLWithString:[item stringForType:type]];
        NSString *typeOfFile = [[NSWorkspace sharedWorkspace] typeOfFile:fileURL.path error:nil];
        if ([typeOfFile isEqualToString:self.mainDataType]) {
            data = [NSData dataWithContentsOfURL:fileURL];
            if (data) {
                self.rawData = data;
                return YES;
            }
        }
    }
    
    return NO;
}

+ (NSString *)pasteboardType {
    return TEPDFPasteboardType;
}

@end
