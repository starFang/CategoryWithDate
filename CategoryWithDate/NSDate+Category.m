//
//  NSDate+Category.m
//  Magicland
//
//  Created by Star童话 on 2018/8/22.
//  Copyright © 2018年 STAR. All rights reserved.
//

#import "NSDate+Category.h"
#import "NSDateFormatter+Category.h"

#define DATE_COMPONENTS (NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfMonth |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

//#define NSDateFormatterInternational(dataFormatter) if(![[FGLanguageTool sharedFGLanguageTool].languageName isEqualToString:@"简体中文"]) {dateFormatter.locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];}

@implementation NSDate (Category)

/*距离当前的时间间隔描述*/
- (NSString *)timeIntervalDescription
{
    NSTimeInterval timeInterval = -[self timeIntervalSinceNow];
    if (timeInterval < 60) {
        return RCString(@"1分钟内");
    }
    
    if (timeInterval < 3600) {
        return [NSString stringWithFormat:RCString(@"%ld分钟前"), (NSInteger)timeInterval / 60 + 1];
    }
    
    if ([self isToday] && timeInterval < 86400) {
        return [NSString stringWithFormat:RCString(@"%ld小时前"), (NSInteger)timeInterval / 3600 + 1];
    }
    
    if ([self isYesterday]) {
        return RCString(@"1天前");
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd 00:00:00";
    NSDate *newDate = [NSDate date];
    NSDate *today = [dateFormatter dateFromString:[dateFormatter stringFromDate:newDate]];
    NSTimeInterval todayInterval = [newDate timeIntervalSinceDate:today];
    NSTimeInterval dateInterval = [newDate timeIntervalSinceDate:self];
    dateInterval -= todayInterval;
    NSInteger days = (NSInteger)dateInterval / 86400 + 1;
    if (days < 60) {
        return [NSString stringWithFormat:RCString(@"%ld天前"), days];
    }
    
    return RCString(@"60天前");
    
}

/*精确到分钟的日期描述*/
- (NSString *)minuteDescription
{
    NSDateFormatter *dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"yyyy-MM-dd"];
//    if(![language isEqualToString:@"简体中文"]) {
        dateFormatter.locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
//    }
    NSString *theDay = [dateFormatter stringFromDate:self];//日期的年月日
    NSString *currentDay = [dateFormatter stringFromDate:[NSDate date]];//当前年月日
    if ([theDay isEqualToString:currentDay]) {//当天
        [dateFormatter setDateFormat:@"ah:mm"];
        return [dateFormatter stringFromDate:self];
    } else if ([[dateFormatter dateFromString:currentDay] timeIntervalSinceDate:[dateFormatter dateFromString:theDay]] == 86400) {//昨天
        [dateFormatter setDateFormat:@"ah:mm"];
        return [NSString stringWithFormat:RCString(@"昨天 %@"), [dateFormatter stringFromDate:self]];
    } else if ([[dateFormatter dateFromString:currentDay] timeIntervalSinceDate:[dateFormatter dateFromString:theDay]] < 86400 * 7) {//间隔一周内
        [dateFormatter setDateFormat:@"EEEE ah:mm"];
        return [dateFormatter stringFromDate:self];
    } else {//以前
        [dateFormatter setDateFormat:@"yyyy-MM-dd ah:mm"];
        return [dateFormatter stringFromDate:self];
    }
}



/*标准时间日期描述*/
- (NSString *)formattedTime {
    NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange containsA = [formatStringForHours rangeOfString:@"a"];
    BOOL hasAMPM = containsA.location != NSNotFound;
    if (hasAMPM) {// 12小时制
        return [self formattedTimeFor12Hour];
    }
    //24小时制
    return [self formattedTimeFor24Hour];
}

- (NSString *)formattedTimeFor12Hour {
    NSDate *startOfDay = [[NSDate date] dateAtStartOfDay];
    NSDateFormatter *dateFormatter = nil;
    NSInteger minute = [self minutesAfterDate:startOfDay];
    if (minute >= 0 && minute < 1440) {// 今天
        if (minute >= 0 && minute < 360) {// 0-5 凌晨
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"凌晨HH:mm"];
        } else if (minute >= 360 && minute < 720) {// 6-11 上午
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"上午HH:mm"];
        } else if (minute >= 720 && minute < 780) {// 12 中午
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"中午HH:mm"];
        } else if (minute >= 780 && minute < 1200) {// 13-19 下午
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"下午hh:mm"];
        } else {// 20-23 晚上
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"晚上hh:mm"];
        }
    } else if (minute < 0 && minute >= -1440) {// 昨天
        dateFormatter = [NSDateFormatter dateFormatterWithFormat:RCString(@"昨天HH:mm")];
    } else {
        dateFormatter = [NSDateFormatter dateFormatterWithFormat:RCString(@"MM月dd日 HH:mm")];
    }
    return [dateFormatter stringFromDate:self];
}

- (NSString *)formattedTimeFor24Hour {
    NSDateFormatter *dateFormatter = nil;
    NSDate *startOfDay = [[NSDate date] dateAtStartOfDay];
    NSInteger minute = [self minutesAfterDate:startOfDay];
    if (minute >= 0 && minute < 1440) {// 今天
        dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"HH:mm"];
    } else if (minute < 0 && minute >= -1440) { // 昨天
        dateFormatter = [NSDateFormatter dateFormatterWithFormat:RCString(@"昨天HH:mm")];
    } else {
        dateFormatter = [NSDateFormatter dateFormatterWithFormat:RCString(@"MM月dd日 HH:mm")];
    }
    return [dateFormatter stringFromDate:self];
}

- (NSString *)formattedDateWithMMDD
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:RCString(@"M月d日")];
    NSString *theDay = [dateFormatter stringFromDate:self];//日期的年月日
    return theDay;
    
}

+ (NSString *)getDateDesWithDate:(NSDate *)date dateFormatterStr:(NSString *)dateFormatterStr
{
    if (date && dateFormatterStr.length > 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:dateFormatterStr];
        return [dateFormatter stringFromDate:date];
    }
    return nil;
}

+ (NSDate *)getDateWithDateDes:(NSString *)dateDes dateFormatterStr:(NSString *)dateFormatterStr
{
    if (dateDes && dateFormatterStr.length > 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:dateFormatterStr];
        return [dateFormatter dateFromString:dateDes];
    }
    return nil;
}

+ (NSDate *)dateConversionTimeZeroWithDate:(NSDate *)date dateFormatterStr:(NSString *)dateFormatterStr
{
    return [self getDateWithDateDes:[self getDateDesWithDate:date dateFormatterStr:dateFormatterStr]
                   dateFormatterStr:dateFormatterStr];
}

+ (NSDate *)getCNDateWithDateDes:(NSString *)dateDes dateFormatterStr:(NSString *)dateFormatterStr
{
    if (dateDes && dateFormatterStr.length > 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:dateFormatterStr];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
        return [dateFormatter dateFromString:dateDes];
    }
    return nil;
}

- (NSString *)formattedTimeEx {
    NSString *dateString = @"";
    
    if ([self isToday]) {
        dateString = RCString(@"今天");
    }
    else if ([self isYesterday]) {
        dateString = RCString(@"昨天");
    }
    else if ([self isTomorrow]) {
        dateString = RCString(@"明天");
    }
    else if ([self isInPastDay]) {
        int days = abs((int)[self distanceInDaysToDate:[[NSDate date] dateAtStartOfDay]]);
        if (days >= 30) {
            // 30天前显示为一月前
            dateString = RCString(@"一月前");
        }
        else if (days >= 15) {
            // 15天前显示为半月前
            dateString = RCString(@"半月前");
        }
        else {
            dateString = [NSString stringWithFormat:RCString(@"%d天前"), days];
        }
    }
    else if ([self isInFutureDay]) {
        int days = abs((int)[self distanceInDaysToDate:[[NSDate date] dateAtStartOfDay]]);
        
        if (days >= 30) {
            // 30天后显示为一月后
            dateString = RCString(@"一月后");
        }
        else if (days >= 15) {
            // 15天后显示为半月后
            dateString = RCString(@"半月后");
        }
        else {
            dateString = [NSString stringWithFormat:RCString(@"%d天后"), days];
        }
    }
    
    return dateString;
}

- (NSString *)dailyFormattedTimeEx {
    NSDateFormatter *dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"yyyy-MM-dd"];
    NSString *theDay = [dateFormatter stringFromDate:self];//日期的年月日
    NSString *currentDay = [dateFormatter stringFromDate:[NSDate date]];//当前年月日
    NSString *dateString = @"";
    if ([self isToday]) {
        dateString = RCString(@"今天");
    }
    else if ([self isYesterday]) {
        dateString = RCString(@"昨天");
    }
    else if ([[dateFormatter dateFromString:currentDay] timeIntervalSinceDate:[dateFormatter dateFromString:theDay]] < 86400 * 7) {
        dateString = [self weekDayName];
    }else {
        [dateFormatter setDateFormat:@"yyyy"];
        currentDay = [dateFormatter stringFromDate:[NSDate date]];
        theDay = [dateFormatter stringFromDate:self];
        if ([currentDay isEqualToString:theDay]) {
            [dateFormatter setDateFormat:RCString(@"MM月dd日")];
            dateString = [dateFormatter stringFromDate:self];
        }else {
            [dateFormatter setDateFormat:@"yy/MM/dd"];
            dateString = [dateFormatter stringFromDate:self];
        }
    }
    return dateString;
    
}

- (NSString *)weekDayName {
    NSArray *arrWeekDays = @[RCString(@"星期天"), RCString(@"星期一"), RCString(@"星期二"), RCString(@"星期三"), RCString(@"星期四"), RCString(@"星期五"), RCString(@"星期六")];
    NSDateComponents *dateComponents = [self dateComponents];
    NSString *dayNameString = arrWeekDays[dateComponents.weekday - 1];
    
    return dayNameString;
}

- (NSString *)weekDayNameCN {
    NSArray *arrWeekDays = @[RCString(@"星期天"), RCString(@"星期一"), RCString(@"星期二"), RCString(@"星期三"), RCString(@"星期四"), RCString(@"星期五"), RCString(@"星期六")];
    NSDateComponents *dateComponents = [self dateComponentsCN];
    NSString *dayNameString = arrWeekDays[dateComponents.weekday - 1];
    
    return dayNameString;
}

#pragma mark- 自定义时间描述

- (NSString *)mytimeDescription
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:RCString(@"M月d日 HH:mm")];
    return [dateFormatter stringFromDate:self];
}

- (NSString *)timeKeyDescription
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    return [dateFormatter stringFromDate:self];
}

- (NSString *)secretTimeDescrip
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:RCString(@"M月d日")];
    return [dateFormatter stringFromDate:self];
}

/*格式化日期描述*/
- (NSString *)formattedDateDescription
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *theDay = [dateFormatter stringFromDate:self];//日期的年月日
    NSString *currentDay = [dateFormatter stringFromDate:[NSDate date]];//当前年月日
    
    NSInteger timeInterval = -[self timeIntervalSinceNow];
    if (timeInterval < 60) {
        //        return @"1分钟内";
        return RCString(@"刚刚");
    } else if (timeInterval < 3600) {//1小时内
        return [NSString stringWithFormat:RCString(@"%ld分钟前"), timeInterval / 60];
    }
    //    else if (timeInterval < 7200) {//2小时内
    //        return [NSString stringWithFormat:@"%d小时前", timeInterval / 3600];
    //    }
    else if ([theDay isEqualToString:currentDay]) {//当天
        [dateFormatter setDateFormat:@"HH:mm"];
        return [NSString stringWithFormat:RCString(@"今天 %@"), [dateFormatter stringFromDate:self]];
    } else if ([[dateFormatter dateFromString:currentDay] timeIntervalSinceDate:[dateFormatter dateFromString:theDay]] == 86400) {//昨天
        [dateFormatter setDateFormat:@"HH:mm"];
        return [NSString stringWithFormat:RCString(@"昨天 %@"), [dateFormatter stringFromDate:self]];
    } else {//以前
        //        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        [dateFormatter setDateFormat:RCString(@"M月d日 HH:mm")];
        return [dateFormatter stringFromDate:self];
    }
}

- (double)timeIntervalSince1970InMilliSecond {
    double ret;
    ret = [self timeIntervalSince1970] * 1000;
    
    return ret;
}

+ (NSString *)currentformatDate:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:format];
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    return currentTimeString;
}

+ (NSDate *)dateWithTimeIntervalInMilliSecondSince1970:(double)timeIntervalInMilliSecond {
    NSDate *ret = nil;
    double timeInterval = timeIntervalInMilliSecond;
    // judge if the argument is in secconds(for former data structure).
    if(timeIntervalInMilliSecond > 140000000000 || timeInterval < -28800000) {
        timeInterval = timeIntervalInMilliSecond / 1000;
    }
    ret = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    return ret;
}

+ (NSString *)formattedTimeFromTimeInterval:(long long)time{
    if(time==0){
        return @"";
    }
    double timeInterval = time;
    if(time > 140000000000 || timeInterval < -28800000) {
        timeInterval = time / 1000;
    }
    return [[NSDate dateWithTimeIntervalSince1970:timeInterval] formattedTime];
}

+ (NSString *)formattedTimeIntervalSince1970:(double)timeInterval formatter:(NSString *)formatter{
    double interval = timeInterval;
    if(timeInterval > 140000000000 || timeInterval < -28800000) {
        interval = timeInterval / 1000;
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *df = nil;
    if (formatter == nil) {
        df = [NSDateFormatter dateFormatterWithFormat:@"yyyy-MM-dd"];
    } else {
        df = [NSDateFormatter dateFormatterWithFormat:formatter];
    }
    return [df stringFromDate:date];
}

#pragma mark Relative Dates

+ (NSDate *)dateWithDaysFromNow:(NSInteger)days
{
    // Thanks, Jim Morrison
    return [[NSDate date] dateByAddingDays:days];
}

+ (NSDate *)dateWithDaysBeforeNow:(NSInteger)days
{
    // Thanks, Jim Morrison
    return [[NSDate date] dateBySubtractingDays:days];
}

+ (NSDate *)dateTomorrow
{
    return [NSDate dateWithDaysFromNow:1];
}

+ (NSDate *)dateYesterday
{
    return [NSDate dateWithDaysBeforeNow:1];
}

+ (NSDate *)dateWithHoursFromNow:(NSInteger)dHours
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *)dateWithHoursBeforeNow:(NSInteger)dHours
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *)dateWithMinutesFromNow:(NSInteger)dMinutes
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *)dateWithMinutesBeforeNow:(NSInteger)dMinutes
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

#pragma mark Comparing Dates

- (BOOL)isEqualToDateIgnoringTime:(NSDate *)aDate
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
    return ((components1.year == components2.year) &&
            (components1.month == components2.month) &&
            (components1.day == components2.day));
}

- (BOOL)isToday
{
    return [self isEqualToDateIgnoringTime:[NSDate date]];
}

- (BOOL)isTomorrow
{
    return [self isEqualToDateIgnoringTime:[NSDate dateTomorrow]];
}

- (BOOL)isYesterday
{
    return [self isEqualToDateIgnoringTime:[NSDate dateYesterday]];
}

// This hard codes the assumption that a week is 7 days
- (BOOL)isSameWeekAsDate:(NSDate *)aDate
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
    
    // Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
    if (components1.weekOfYear != components2.weekOfYear) return NO;
    
    // Must have a time interval under 1 week. Thanks @aclark
    return (fabs([self timeIntervalSinceDate:aDate]) < D_WEEK);
}

- (BOOL)isThisWeek
{
    return [self isSameWeekAsDate:[NSDate date]];
}

- (BOOL)isNextWeek
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_WEEK;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return [self isSameWeekAsDate:newDate];
}

- (BOOL)isLastWeek
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_WEEK;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return [self isSameWeekAsDate:newDate];
}

// Thanks, mspasov
- (BOOL)isSameMonthAsDate:(NSDate *)aDate
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:aDate];
    return ((components1.month == components2.month) &&
            (components1.year == components2.year));
}

- (BOOL)isThisMonth
{
    return [self isSameMonthAsDate:[NSDate date]];
}

- (BOOL)isSameYearAsDate:(NSDate *)aDate
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:aDate];
    return (components1.year == components2.year);
}

- (BOOL)isThisYear
{
    // Thanks, baspellis
    return [self isSameYearAsDate:[NSDate date]];
}

- (BOOL)isNextYear
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:[NSDate date]];
    
    return (components1.year == (components2.year + 1));
}

- (BOOL)isLastYear
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:[NSDate date]];
    
    return (components1.year == (components2.year - 1));
}

- (BOOL)isEarlierThanDate:(NSDate *)aDate
{
    return ([self compare:aDate] == NSOrderedAscending);
}

- (BOOL)isLaterThanDate:(NSDate *)aDate
{
    return ([self compare:aDate] == NSOrderedDescending);
}

// Thanks, markrickert
- (BOOL)isInFuture
{
    return ([self isLaterThanDate:[NSDate date]]);
}

// Thanks, markrickert
- (BOOL)isInPast
{
    return ([self isEarlierThanDate:[NSDate date]]);
}

- (BOOL)isEarlierThanDateIgnoringTime:(NSDate *)aDate {
    NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
    
    NSDate *date1 = [NSDate getDateWithDateDes:[NSString stringWithFormat:@"%04d-%02d-%02d 00:00", (int)components1.year, (int)components1.month, (int)components1.day] dateFormatterStr:@"yyyy-MM-dd HH:mm"];
    NSDate *date2 = [NSDate getDateWithDateDes:[NSString stringWithFormat:@"%04d-%02d-%02d 00:00", (int)components2.year, (int)components2.month, (int)components2.day] dateFormatterStr:@"yyyy-MM-dd HH:mm"];
    
    return [date1 isEarlierThanDate:date2];
}

- (BOOL)isLaterThanDateIgnoringTime:(NSDate *)aDate {
    NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
    
    NSDate *date1 = [NSDate getDateWithDateDes:[NSString stringWithFormat:@"%04d-%02d-%02d 00:00", (int)components1.year, (int)components1.month, (int)components1.day] dateFormatterStr:@"yyyy-MM-dd HH:mm"];
    NSDate *date2 = [NSDate getDateWithDateDes:[NSString stringWithFormat:@"%04d-%02d-%02d 00:00", (int)components2.year, (int)components2.month, (int)components2.day] dateFormatterStr:@"yyyy-MM-dd HH:mm"];
    
    return [date1 isLaterThanDate:date2];
}

- (BOOL)isInFutureDay {
    return [self isLaterThanDateIgnoringTime:[NSDate date]];
}

- (BOOL)isInPastDay {
    return [self isEarlierThanDateIgnoringTime:[NSDate date]];
}

#pragma mark Roles
- (BOOL)isTypicallyWeekend
{
    NSDateComponents *components = [CURRENT_CALENDAR components:NSCalendarUnitWeekday fromDate:self];
    if ((components.weekday == 1) ||
        (components.weekday == 7))
        return YES;
    return NO;
}

- (BOOL)isTypicallyWorkday
{
    return ![self isTypicallyWeekend];
}

#pragma mark Adjusting Dates
- (NSDate *)dateByAddingOrSubtractingMonths:(NSInteger)months
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dayComponent = [NSDateComponents new];
    dayComponent.month = months;
    return [calendar dateByAddingComponents:dayComponent toDate:self options:0];
}

- (NSDate *)dateByAddingMonths:(NSInteger)months
{
    return [self dateByAddingOrSubtractingMonths:months];
}

- (NSDate *)dateBySubtractingMonths:(NSInteger)months
{
    return [self dateByAddingOrSubtractingMonths:months * -1];
}

-(NSDate *)dateByAddingOrSubtractingDays:(NSInteger)days
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dayComponent = [NSDateComponents new];
    dayComponent.day = days;
    return  [calendar dateByAddingComponents:dayComponent toDate:self options:0];
}

- (NSDate *)dateByAddingDays:(NSInteger)dDays
{
    return [self dateByAddingOrSubtractingDays:dDays];
}

- (NSDate *)dateBySubtractingDays:(NSInteger)dDays
{
    return [self dateByAddingOrSubtractingDays:(dDays * -1)];
}

- (NSDate *)dateByAddingHours:(NSInteger)dHours
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)dateBySubtractingHours:(NSInteger)dHours
{
    return [self dateByAddingHours:(dHours * -1)];
}

- (NSDate *)dateByAddingMinutes:(NSInteger)dMinutes
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)dateBySubtractingMinutes:(NSInteger)dMinutes
{
    return [self dateByAddingMinutes:(dMinutes * -1)];
}

- (NSDate *)dateAtStartOfDay
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    return [CURRENT_CALENDAR dateFromComponents:components];
}

- (NSDate *)dateAtEndOfDay {
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    components.hour = 23;
    components.minute = 59;
    components.second = 59;
    return [CURRENT_CALENDAR dateFromComponents:components];
}

- (NSDate *)dateOfYearStart {
    NSDateComponents *components = [CURRENT_CALENDAR components:NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self];
    components.month = 1;
    components.day = 1;
    
    return [CURRENT_CALENDAR dateFromComponents:components];
}

- (NSDate *)dateOfYearEnd {
    NSDateComponents *components = [CURRENT_CALENDAR components:NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self];
    components.month = 12;
    components.day = 31;
    
    return [[CURRENT_CALENDAR dateFromComponents:components] dateAtEndOfDay];
}

- (NSDate *)dateOfMonthStart {
    NSDateComponents *components = [CURRENT_CALENDAR components:NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self];
    components.day = 1;
    
    return [CURRENT_CALENDAR dateFromComponents:components];
}

- (NSDate *)dateOfMonthEnd {
    NSDate *date = [self dateByAddingMonths:1];
    date = [date dateOfMonthStart];
    return  [[date dateByAddingOrSubtractingDays:-1] dateAtEndOfDay];
}

- (NSDate *)dateOfBeforeMonthStart:(NSInteger)months {
    return [[self dateBySubtractingMonths:months] dateOfMonthStart];
}

- (NSDate *)dateOfAfterMonthStart:(NSInteger)months {
    return [[self dateByAddingMonths:months] dateOfMonthStart];
}

- (NSDate *)dateOfAfterMonthEnd:(NSInteger)months {
    return [[self dateByAddingMonths:months] dateOfMonthEnd];
}

- (NSDate *)dateOfWeekStart {
    return [[self dateByAddingDays:-(self.weekday - 1)] dateAtStartOfDay];
}

- (NSDate *)dateOfWeekEnd {
    return [[self dateByAddingDays:(7 - self.weekday)] dateAtEndOfDay];
}

- (NSDate *)dateOfWeekStartCN {
    int interval = (int)(2 - self.weekday);
    
    interval = (interval > 0)?(interval - 7):interval;
    
    return [[self dateByAddingDays:interval] dateAtStartOfDay];
}

- (NSDate *)dateOfWeekEndCN {
    int interval = (int)(1 - self.weekday);
    
    interval = (interval < 0)?(interval + 7):interval;
    
    return [[self dateByAddingDays:interval] dateAtEndOfDay];
}

- (NSDate *)dateOfQuarterStart {
    NSDate *date = [self dateOfMonthStart];
    int monthInterval = -(date.month % 3 + 2) % 3;
    
    date = [[date dateByAddingMonths:monthInterval] dateOfMonthStart];
    
    return date;
}

- (NSDate *)dateOfQuarterEnd {
    NSDate *date = [self dateOfMonthStart];
    int monthInterval = 3 - (date.month % 3);
    
    date = [[[date dateByAddingMonths:monthInterval] dateOfMonthEnd] dateAtEndOfDay];
    
    return date;
}

- (NSDate *)dateForWholeHour {
    NSDate *startDate = [self dateAtStartOfDay];
    int hourInterval = (int)self.hour;
    
    if (self.minute > 0) {
        hourInterval = hourInterval + 1;
    }
    
    return [startDate dateByAddingHours:hourInterval];
}

- (NSDateComponents *)componentsWithOffsetFromDate:(NSDate *)aDate
{
    NSDateComponents *dTime = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate toDate:self options:0];
    return dTime;
}

#pragma mark Retrieving Intervals

- (NSInteger)minutesAfterDate:(NSDate *)aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger)minutesBeforeDate:(NSDate *)aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger)hoursAfterDate:(NSDate *)aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return ceil(ti / D_HOUR);
}

- (NSInteger)hoursBeforeDate:(NSDate *)aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_HOUR);
}

- (NSInteger)daysAfterDate:(NSDate *)aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_DAY);
}

- (NSInteger)daysBeforeDate:(NSDate *)aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_DAY);
}

// Thanks, dmitrydims
// I have not yet thoroughly tested this
- (NSInteger)distanceInDaysToDate:(NSDate *)anotherDate
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay fromDate:self toDate:anotherDate options:0];
    return components.day;
}


- (NSDateComponents *)dateComponents {
    return [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
}

- (NSDateComponents *)dateComponentsCN {
    NSCalendar *calendar = CURRENT_CALENDAR;
    calendar.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    return [calendar components:DATE_COMPONENTS fromDate:self];
}

+ (int)calculateWeekWithYear:(int)year month:(int)month day:(int)day {
    int week = 0;
    unsigned int y = 0, c = 0, m = 0, d = 0;
    
    if (month == 1 || month == 2) {
        c = (year - 1) / 100;
        y = (year - 1) % 100;
        m = month + 12;
        d = day;
    } else {
        c = year / 100;
        y = year % 100;
        m = month;
        d = day;
    }
    week = y + y / 4 + c / 4 - 2 * c + 26 * (m + 1) / 10 + d - 1; // 蔡勒公式
    week = week >= 0?(week % 7):(week % 7 + 7); // 为负时取模
    if (week == 0) {
        week = 7;
    }
    
    return week;
}

+ (BOOL)isSameDayWithFirstTime:(long long)firstTime secondTime:(long long)secondTime {
    firstTime = firstTime / (24 * 3600 * 1000);
    secondTime = secondTime / (24 * 3600 * 1000);
    
    return (firstTime == secondTime)?YES:NO;
}

#pragma mark Decomposing Dates

- (NSInteger)nearestHour
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * 30;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    NSDateComponents *components = [CURRENT_CALENDAR components:NSCalendarUnitHour fromDate:newDate];
    return components.hour;
}

- (NSInteger)hour
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.hour;
}

- (NSInteger)minute
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.minute;
}

- (NSInteger)seconds
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.second;
}

- (NSInteger)day
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.day;
}

- (NSInteger)month
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:NSCalendarUnitMonth fromDate:self];
    return  comps.month;
}

- (NSInteger)weekOfMonth
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.weekOfMonth;
}

- (NSInteger)weekOfYear
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.weekOfYear;
}

- (NSInteger)weekday
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:NSCalendarUnitWeekday fromDate:self];
    return  comps.weekday;
}

- (NSInteger)nthWeekday // e.g. 2nd Tuesday of the month is 2
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.weekdayOrdinal;
}

- (NSInteger)year
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    return components.year;
}

- (NSInteger)secondsCN
{
    NSCalendar *calendar = CURRENT_CALENDAR;
    calendar.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    NSDateComponents *components = [calendar components:DATE_COMPONENTS fromDate:self];
    return components.second;
}

- (NSInteger)minuteCN
{
    NSCalendar *calendar = CURRENT_CALENDAR;
    calendar.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    NSDateComponents *components = [calendar components:DATE_COMPONENTS fromDate:self];
    return components.minute;
}

- (NSInteger)hourCN
{
    NSCalendar *calendar = CURRENT_CALENDAR;
    calendar.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    NSDateComponents *components = [calendar components:DATE_COMPONENTS fromDate:self];
    return components.hour;
}

- (NSInteger)dayCN
{
    NSCalendar *calendar = CURRENT_CALENDAR;
    calendar.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    NSDateComponents *components = [calendar components:DATE_COMPONENTS fromDate:self];
    return components.day;
}

- (NSInteger)monthCN
{
    NSCalendar *calendar = CURRENT_CALENDAR;
    calendar.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    NSDateComponents *components = [calendar components:DATE_COMPONENTS fromDate:self];
    return components.month;
}

- (NSInteger)yearCN
{
    NSCalendar *calendar = CURRENT_CALENDAR;
    calendar.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    NSDateComponents *components = [calendar components:DATE_COMPONENTS fromDate:self];
    return components.year;
}

@end

