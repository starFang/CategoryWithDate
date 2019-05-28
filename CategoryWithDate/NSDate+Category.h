//
//  NSDate+Category.h
//  Magicland
//
//  Created by Star童话 on 2018/8/22.
//  Copyright © 2018年 STAR. All rights reserved.
//

#import <Foundation/Foundation.h>

#define D_MINUTE    60
#define D_HOUR        3600
#define D_DAY        86400
#define D_WEEK        604800
#define D_YEAR        31556926
#define DEFAULT_DATE_FORMATTER @"yyyy-MM-dd HH:mm:ss"

@interface NSDate (Category)

- (NSString *)formattedDateWithMMDD;
+ (NSString *)getDateDesWithDate:(NSDate *)date dateFormatterStr:(NSString *)dateFormatterStr;
+ (NSDate *)getDateWithDateDes:(NSString *)dateDes dateFormatterStr:(NSString *)dateFormatterStr;
+ (NSDate *)dateConversionTimeZeroWithDate:(NSDate *)date dateFormatterStr:(NSString *)dateFormatterStr;
// 根据时间字符串获取日期(时区使用东8区)
+ (NSDate *)getCNDateWithDateDes:(NSString *)dateDes dateFormatterStr:(NSString *)dateFormatterStr;

// 显示格式(1月前、半月前、3天前、前天、昨天、今天、明天、后天、两天后、半月后、1月后)
- (NSString *)formattedTimeEx;
// 显示格式(今天、昨天、星期几(一周内)、几月几号(今年)、xx/xx/xx(今年之前))
- (NSString *)dailyFormattedTimeEx;
// 显示星期
- (NSString *)weekDayName;
// 显示星期(时区使用东8区)
- (NSString *)weekDayNameCN;

- (NSString *)timeIntervalDescription;//距离当前的时间间隔描述
- (NSString *)minuteDescription;/*精确到分钟的日期描述*/
- (NSString *)formattedTime;// 根据系统时间是否为24小时制来执行下面两个方法之一
- (NSString *)formattedTimeFor24Hour;
- (NSString *)formattedDateDescription;//格式化日期描述
- (NSString *)mytimeDescription;//自定义时间描述
- (NSString *)secretTimeDescrip;//小秘书数据时间描述
- (NSString *)timeKeyDescription;//时间字符串作为key的描述
+ (NSString *)currentformatDate:(NSString *)format;

- (double)timeIntervalSince1970InMilliSecond;
+ (NSDate *)dateWithTimeIntervalInMilliSecondSince1970:(double)timeIntervalInMilliSecond;
+ (NSString *)formattedTimeFromTimeInterval:(long long)time;
+ (NSString *)formattedTimeIntervalSince1970:(double)timeInterval formatter:(NSString *)formatter;
// Relative dates from the current date
+ (NSDate *)dateTomorrow;
+ (NSDate *)dateYesterday;
+ (NSDate *)dateWithDaysFromNow:(NSInteger)days;
+ (NSDate *)dateWithDaysBeforeNow:(NSInteger)days;
+ (NSDate *)dateWithHoursFromNow:(NSInteger)dHours;
+ (NSDate *)dateWithHoursBeforeNow:(NSInteger)dHours;
+ (NSDate *)dateWithMinutesFromNow:(NSInteger)dMinutes;
+ (NSDate *)dateWithMinutesBeforeNow:(NSInteger)dMinutes;

// Comparing dates
- (BOOL)isEqualToDateIgnoringTime:(NSDate *)aDate;
- (BOOL)isToday;
- (BOOL)isTomorrow;
- (BOOL)isYesterday;
- (BOOL)isSameWeekAsDate:(NSDate *)aDate;
- (BOOL)isThisWeek;
- (BOOL)isNextWeek;
- (BOOL)isLastWeek;
- (BOOL)isSameMonthAsDate:(NSDate *)aDate;
- (BOOL)isThisMonth;
- (BOOL)isSameYearAsDate:(NSDate *)aDate;
- (BOOL)isThisYear;
- (BOOL)isNextYear;
- (BOOL)isLastYear;
- (BOOL)isEarlierThanDate:(NSDate *)aDate;
- (BOOL)isLaterThanDate:(NSDate *)aDate;
- (BOOL)isInFuture;
- (BOOL)isInPast;

- (BOOL)isEarlierThanDateIgnoringTime:(NSDate *)aDate;
- (BOOL)isLaterThanDateIgnoringTime:(NSDate *)aDate;
// 判断是否是明天及以后的
- (BOOL)isInFutureDay;
// 判断是否是昨天及以前的
- (BOOL)isInPastDay;

// Date roles
- (BOOL)isTypicallyWorkday;
- (BOOL)isTypicallyWeekend;

// Adjusting dates
- (NSDate *)dateByAddingOrSubtractingMonths:(NSInteger)months;
//等同于dateByAddingOrSubtractingMonths:months
- (NSDate *)dateByAddingMonths:(NSInteger)months;
//等同于dateByAddingOrSubtractingMonths:(months * -1)
- (NSDate *)dateBySubtractingMonths:(NSInteger)months;

- (NSDate *)dateByAddingOrSubtractingDays:(NSInteger)days;
//等同于dateByAddingOrSubtractingDays:dDays
- (NSDate *)dateByAddingDays:(NSInteger)dDays;
//等同于dateByAddingOrSubtractingDays:(dDays * -1)
- (NSDate *)dateBySubtractingDays:(NSInteger)dDays;

- (NSDate *)dateByAddingHours:(NSInteger)dHours;
- (NSDate *)dateBySubtractingHours:(NSInteger)dHours;
- (NSDate *)dateByAddingMinutes:(NSInteger)dMinutes;
- (NSDate *)dateBySubtractingMinutes:(NSInteger)dMinutes;
- (NSDate *)dateAtStartOfDay;
- (NSDate *)dateAtEndOfDay;
// 年初日期
- (NSDate *)dateOfYearStart;
// 年末日期(以最后一天的23:59:59为准)
- (NSDate *)dateOfYearEnd;
// 月初日期
- (NSDate *)dateOfMonthStart;
// 月末日期(以最后一天的23:59:59为准)
- (NSDate *)dateOfMonthEnd;
//month个月前的月初
- (NSDate *)dateOfBeforeMonthStart:(NSInteger)months;
//month个月后的月初
- (NSDate *)dateOfAfterMonthStart:(NSInteger)months;
//month个月后的月末
- (NSDate *)dateOfAfterMonthEnd:(NSInteger)months;

// 当前一周的开始日期(一周的开始以周日的00:00:00为准)
- (NSDate *)dateOfWeekStart;
// 当前一周的结束日期(一周的结束以周六的23:59:59为准)
- (NSDate *)dateOfWeekEnd;
// 当前一周的开始日期(一周的开始以周一的00:00:00为准)
- (NSDate *)dateOfWeekStartCN;
// 当前一周的结束日期(一周的结束以周日的23:59:59为准)
- (NSDate *)dateOfWeekEndCN;

// 当前所在季度的开始日期(一个季度的开始以第一天的00:00:00为准)
- (NSDate *)dateOfQuarterStart;
// 当前所在季度的结束日期(一个季度的结束以最后一天的23:59:59为准)
- (NSDate *)dateOfQuarterEnd;

// 取当前时间整点日期(如果是13:00:00, 整点为13:00:00; 如果是13:01:00,则整点为14:00:00)
- (NSDate *)dateForWholeHour;

// Retrieving intervals
- (NSInteger)minutesAfterDate:(NSDate *)aDate;
- (NSInteger)minutesBeforeDate:(NSDate *)aDate;
- (NSInteger)hoursAfterDate:(NSDate *)aDate;
- (NSInteger)hoursBeforeDate:(NSDate *)aDate;
- (NSInteger)daysAfterDate:(NSDate *)aDate;
- (NSInteger)daysBeforeDate:(NSDate *)aDate;
- (NSInteger)distanceInDaysToDate:(NSDate *)anotherDate;
// 根据年月日计算星期几
+ (int)calculateWeekWithYear:(int)year month:(int)month day:(int)day;
// 判断两个时间戳是否在同一天(时间戳为毫秒数)
+ (BOOL)isSameDayWithFirstTime:(long long)firstTime secondTime:(long long)secondTime;

// 返回年月日时分秒
- (NSDateComponents *)dateComponents;

// Decomposing dates
@property (readonly) NSInteger nearestHour;
@property (readonly) NSInteger hour;
@property (readonly) NSInteger minute;
@property (readonly) NSInteger seconds;
@property (readonly) NSInteger day;
@property (readonly) NSInteger month;
@property (readonly) NSInteger weekOfMonth;
@property (readonly) NSInteger weekOfYear;
@property (readonly) NSInteger weekday;
@property (readonly) NSInteger nthWeekday; // e.g. 2nd Tuesday of the month == 2
@property (readonly) NSInteger year;

// 以下使用东8区计算
@property (readonly) NSInteger secondsCN;
@property (readonly) NSInteger minuteCN;
@property (readonly) NSInteger hourCN;
@property (readonly) NSInteger dayCN;
@property (readonly) NSInteger monthCN;
@property (readonly) NSInteger yearCN;

@end
