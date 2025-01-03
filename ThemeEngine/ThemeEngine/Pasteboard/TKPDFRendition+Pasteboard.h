//
//  TKPDFRendition+Pasteboard.h
//  ThemeEngine
//
//  Created by Jeremy on 10/26/23.
//  Copyright © 2023 Alex Zielenski. All rights reserved.
//

#import <ThemeKit/ThemeKit.h>
#import "TERenditionPasteboardItem.h"
#import "TKRendition+Pasteboard.h"

extern NSString *const TEPDFPasteboardType;

@interface TKPDFRendition (Pasteboard) <TERenditionPasteboardItem>

@end
