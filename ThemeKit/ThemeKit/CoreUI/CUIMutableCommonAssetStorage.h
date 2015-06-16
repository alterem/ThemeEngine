/*
 *     Generated by class-dump 3.3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2011 by Steve Nygard.
 */

#import <Foundation/Foundation.h>
#import <CoreUI/CUICommonAssetStorage.h>
#import "TKStructs.h"

@interface CUIMutableCommonAssetStorage : CUICommonAssetStorage
- (instancetype)initWithPath:(NSString *)path;

- (BOOL)writeToDisk;
- (BOOL)writeToDiskAndCompact:(BOOL)compact;

- (void)setRenditionKey:(const struct renditionkeytoken *)key hotSpot:(CGPoint)hotSpot forName:(const char *)name;
- (void)removeAssetForKey:(const void *)key withLength:(unsigned long long)length;
- (void)removeAssetForKey:(NSData *)key;
- (void)setExternalTags:(id)tags;

- (void)setFontSize:(float)size forFontSizeSelector:(id)selector;
- (void)setFontName:(NSString *)name baselineOffset:(float)baseline forFontSelector:(NSString *)selector;

- (void)setColor:(struct rgbquad)value forName:(const char *)name excludeFromFilter:(BOOL)exclude;
- (void)setCatalogGlobalData:(NSData *)catalogData;

- (void)setAsset:(NSData *)csiData forKey:(const void *)key withLength:(unsigned long long)keyLength;
- (void)setAsset:(NSData *)csiData forKey:(NSData *)key;

- (void)setColorSpaceID:(unsigned int)colorSpaceID;

- (void)setAssociatedChecksum:(unsigned int)checksum;
- (void)setUuid:(NSUUID *)uuid;
- (void)setRenditionCount:(unsigned int)count;
- (void)setSchemaVersion:(unsigned int)version;
- (void)setVersionString:(const char *)versionString;
- (void)setStorageVersion:(unsigned int)version;
- (void)setKeySemantics:(int)arg1;
- (void)setKeyFormatData:(NSData *)data;

// - (void)setZeroCodeBezelInformation:(CDStruct_c0454aff)arg1 forKey:(const void *)arg2 withLength:(unsigned long long)arg3;
// - (void)setZeroCodeGlyphInformation:(CDStruct_c0454aff)arg1 forKey:(const void *)arg2 withLength:(unsigned long long)arg3;
// - (void)_setZeroCodeInfo:(CDStruct_c0454aff)arg1 forKey:(const void *)arg2 withLength:(unsigned long long)arg3 inTree:(const void *)arg4;

@end
