//
//  NSString+Users.h
//  lifestyle
//
//  Created by wd on 15/8/20.
//  Copyright (c) 2015年 Wei Chuang Le ,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CharType) {
    CharType_UppercaseString = 0,
    CharType_LowercaseString = 1,
    CharType_CapitalizedFirstChar = 2
};

@interface NSString (Users)

/** 拼音 */ 
@property (nonatomic, copy, readonly) NSString *phonetics;

+ (CGSize)sizeWithText:(NSString *)text andFont:(UIFont *)font andMaxsize: (CGSize)maxSize;

/**
 *  返回textSize
 *
 *  @param font    font
 *  @param maxSize 单行显示 maxSize = CGSizeMake(MAXFLOAT, MAXFLOAT)
 *
 *  @return textSize
 */
- (CGSize)sizeWithFont:(UIFont *)font andMaxsize: (CGSize)maxSize;

/**
 *  汉字转拼音 样式可选 全大写 全小写 首字母大写
 *
 *  @param sourceString 汉字
 *
 *  @return 拼音
 */
+ (NSString *)stringWith:(NSString*)sourceString Chartype:(CharType)charType;


/**
 *  判断是否 为正确网址
 *
 *  @param urlString 待测 地址
 *
 *  @return BOOL YES:    NO:
 */
+ (BOOL)checkURL:(NSString *)urlString;

/**
 *  将字典转化为json格式字符串
 *
 *  @param dic 字典
 *
 *  @return Base64Data json字符串
 */
+ (NSString*)dictionaryToBase64DataJson:(NSDictionary *)dic;

/**
 *  字符串包含指定字符
 *
 *  @param aString 指定字符
 *
 *  @return BOOL YES:    NO:
 */
- (BOOL)containsDesignatedString:(NSString *)aString;

/**
 *  判断电话号码的正则
 *
 *  @return BOOL YES:    NO:
 */
- (BOOL)isMobileNumber;
/**
 *  @return 根据字符串得到Font
 */
+ (UIFont *)getFontWithString:(NSString *)fontStr;
/**
 *  @return 根据16进制字符串返回颜色
 */
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;

- (NSString *)appendURLStringAndIDFA;

/**
 *  更改小图的Url为大图的URL，在extension前面拼接@b
 */
- (NSString *)convertSmallImageUrlToBigImageUrl;


/**
 *  时间戳转时间 仅时间
 */
+ (NSString *)getTimestamp:(NSString*)mStr;

/**
 *  时间戳转时间  带日期
 */
+ (NSString *)getYYTimestamp:(NSString*)mStr;

@end
