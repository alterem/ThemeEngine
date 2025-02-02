//
//  TKRawDataRendition.m
//  ThemeKit
//
//  Created by Alexander Zielenski on 6/14/15.
//  Copyright © 2015 Alex Zielenski. All rights reserved.
//

#import "TKRawDataRendition.h"
#import "TKRendition+Private.h"
#import <SymRez.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@import QuartzCore.CATransaction;

NSData *(*_CUIUncompressDataWithLZFSE)(NSData*);

extern NSData *CAEncodeLayerTree(CALayer *layer);

NSString *const TKUTITypeCoreAnimationArchive = @"com.apple.coreanimation-archive";

@interface TKRawDataRendition () {
    CALayer *_rootLayer;
    int _renditionFlags;
}
@end

@implementation TKRawDataRendition
@dynamic rootLayer;

- (instancetype)_initWithCUIRendition:(CUIThemeRendition *)rendition csiData:(NSData *)csiData key:(CUIRenditionKey *)key {
    if ((self = [super _initWithCUIRendition:rendition csiData:csiData key:key])) {
        unsigned int listOffset = offsetof(struct csiheader, infolistLength);
        unsigned int listLength = 0;
        [csiData getBytes:&listLength range:NSMakeRange(listOffset, sizeof(listLength))];
        listOffset += listLength + sizeof(unsigned int) * 4;
        
        unsigned int type = 0;
        [csiData getBytes:&type range:NSMakeRange(listOffset, sizeof(type))];
        
        listOffset += 8;
        unsigned int dataLength = 0;
        [csiData getBytes:&dataLength range:NSMakeRange(listOffset, sizeof(dataLength))];
        
        listOffset += sizeof(dataLength);
        _rawData = [csiData subdataWithRange:NSMakeRange(listOffset, dataLength)];
        
        _renditionFlags = 0;
        _renditionFlags = *(int *)TKIvarPointer(self.rendition, "_renditionFlags");
        if (_renditionFlags & 0x10) {
            _rawData = _CUIUncompressDataWithLZFSE(_rawData);
        }
        
        //release raw data off of rendition to save ram...
        if ([rendition isKindOfClass:[TKClass(_CUIRawDataRendition) class]]) {
            CFDataRef *dataBytes = (CFDataRef *)TKIvarPointer(self.rendition, "_dataBytes");

            // use __bridge_transfer to transfer ownership to ARC so it releases it at the end
            // of this scope
            CFRelease(*dataBytes);
            // set the variable to NULL
            *dataBytes = NULL;
        }
    }
    
    return self;
}

- (void)computePreviewImageIfNecessary {
    if (self._previewImage)
        return;
    
    UTType *uti = [UTType typeWithIdentifier:self.utiType];
    if ([uti conformsToType:UTTypeImage]) {
        self._previewImage = [[NSImage alloc] initWithData:_rawData];
    } else if ([self.utiType isEqualToString:TKUTITypeCoreAnimationArchive]) {
        __weak CALayer *layer = self.rootLayer;
        
        self._previewImage = [NSImage imageWithSize:layer.bounds.size
                                            flipped:layer.geometryFlipped
                                     drawingHandler:^BOOL(NSRect dstRect) {
            [CATransaction begin];
            [CATransaction setDisableActions: YES];
            [layer renderInContext:[[NSGraphicsContext currentContext] graphicsPort]];
            [CATransaction commit];
            return YES;
        }];
    } else if (self.utiType != nil) {
        self._previewImage = [[NSWorkspace sharedWorkspace] iconForFileType:self.utiType];
        
    } else {
        [super computePreviewImageIfNecessary];
    }
}

- (CALayer *)copyRootLayer {
    if ([self.utiType isEqualToString:TKUTITypeCoreAnimationArchive]) {
        NSDictionary *archive = [NSKeyedUnarchiver unarchiveObjectWithData:self.rawData];
        CALayer *rootLayer = [archive objectForKey:@"rootLayer"];
        rootLayer.geometryFlipped = [[archive objectForKey:@"geometryFlipped"] boolValue];
        return rootLayer;
    }
    return nil;
}

- (CALayer *)rootLayer {
    if (!_rootLayer) _rootLayer = self.copyRootLayer;
    
    return _rootLayer;
}

- (void)setRootLayer:(CALayer *)rootLayer {
    [self willChangeValueForKey:@"rootLayer"];
    
    self.rawData = [NSKeyedArchiver archivedDataWithRootObject:@{
                                                                 @"rootLayer": rootLayer,
                                                                 @"geometryFlipped": @(rootLayer.geometryFlipped)
                                                                 }];
    _rootLayer = rootLayer;
    self._previewImage = nil;
    [self didChangeValueForKey:@"rootLayer"];
}

- (void)setRawData:(NSData *)rawData {
    [self willChangeValueForKey:@"rawData"];
    _rawData = rawData;
    _rootLayer = nil;
    self._previewImage = nil;
    [self didChangeValueForKey:@"rawData"];
}

+ (NSDictionary *)undoProperties {
    static NSMutableDictionary *TKRawDataProperties = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TKRawDataProperties = [NSMutableDictionary dictionary];
        [TKRawDataProperties addEntriesFromDictionary:@{
                                                        TKKey(utiType): @"Change UTI",
                                                        TKKey(rawData): @"Change Data",
                                                        }];
        [TKRawDataProperties addEntriesFromDictionary:[super undoProperties]];
    });
    
    return TKRawDataProperties;
}

- (CSIGenerator *)generator {
    CSIGenerator *generator = [[CSIGenerator alloc] initWithRawData:self.rawData
                                                        pixelFormat:self.pixelFormat
                                                             layout:self.layout];
    
    if (_renditionFlags & 0x10) {
        [generator setCompressionType:2];
    }
    
    return generator;
}

- (void)setUtiType:(NSString *)utiType {
    [super setUtiType:utiType];
    self._previewImage = nil;
}

- (NSString *)utiType {
    NSString *utiType = [super utiType];
    if (utiType) return utiType;
    
    if (!self.isAssetPack) {
        NSString *ext = [self.name pathExtension];
        if (!ext.length) return nil;
        
        UTType *uti = [UTType typeWithFilenameExtension:ext];
        if (!uti) return nil;

        utiType = uti.identifier;
        [super setUtiType:utiType];
    }
    
    return utiType;
}

+ (void)load {
    symrez_t sr_coreui = symrez_new("CoreUI");
    _CUIUncompressDataWithLZFSE = sr_resolve_symbol(sr_coreui, "_CUIUncompressDataWithLZFSE");
    free(sr_coreui);
}

@end
