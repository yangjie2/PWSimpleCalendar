//
//  PWSimpleCalendarViewCell.m
//  PWSimpleCalendar
//
//  Created by Jerome Miglino on 10/7/13.
//  Copyright (c) 2013 Producteev. All rights reserved.
//

#import "PWSimpleCalendarViewCell.h"

const CGFloat PWSimpleCalendarCircleSize = 34.0f;
const CGFloat PWSimpleCalendarEventPointWidth = 4.0f;

@interface PWSimpleCalendarViewCell ()

@property (nonatomic, strong) UILabel *dayLabel;
@property (nonatomic, strong) UIView *eventPointView;
@property (nonatomic, strong) NSDate *date;

@end

@implementation PWSimpleCalendarViewCell

#pragma mark - Class Methods

+ (NSString *)formatDate:(NSDate *)date withCalendar:(NSCalendar *)calendar
{
    NSDateFormatter *dateFormatter = [self dateFormatter];
    return [PWSimpleCalendarViewCell stringFromDate:date withDateFormatter:dateFormatter withCalendar:calendar];
}

+ (NSString *)formatAccessibilityDate:(NSDate *)date withCalendar:(NSCalendar *)calendar
{
    NSDateFormatter *dateFormatter = [self accessibilityDateFormatter];
    return [PWSimpleCalendarViewCell stringFromDate:date withDateFormatter:dateFormatter withCalendar:calendar];
}


+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"d";
    });
    return dateFormatter;
}

+ (NSDateFormatter *)accessibilityDateFormatter {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        
    });
    return dateFormatter;
}

+ (NSString *)stringFromDate:(NSDate *)date withDateFormatter:(NSDateFormatter *)dateFormatter withCalendar:(NSCalendar *)calendar {
    //Test if the calendar is different than the current dateFormatter calendar property
    if (![dateFormatter.calendar isEqual:calendar]) {
        dateFormatter.calendar = calendar;
    }
    return [dateFormatter stringFromDate:date];
}

#pragma mark - Instance Methods

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _date = nil;
        _isToday = NO;
        _isEnable = YES;
        _hasEvent = NO;
        _dayLabel = [[UILabel alloc] init];
        [self.dayLabel setFont:[self textDefaultFont]];
        [self.dayLabel setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:self.dayLabel];

        //Add the Constraints
        [self.dayLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.dayLabel setBackgroundColor:[UIColor clearColor]];
        self.dayLabel.layer.cornerRadius = PWSimpleCalendarCircleSize/2;
        self.dayLabel.layer.masksToBounds = YES;

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dayLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dayLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dayLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:PWSimpleCalendarCircleSize]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dayLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:PWSimpleCalendarCircleSize]];
        
        _eventPointView = [[UIView alloc] init];
        [self.contentView addSubview:self.eventPointView];
        
        //Add the Constraints
        self.eventPointView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.eventPointView setBackgroundColor:UIColor.clearColor];
        self.eventPointView.layer.cornerRadius = PWSimpleCalendarEventPointWidth/2;
        self.eventPointView.layer.masksToBounds = YES;
        [self.eventPointView.widthAnchor constraintEqualToConstant:PWSimpleCalendarEventPointWidth].active = YES;
        [self.eventPointView.heightAnchor constraintEqualToConstant:PWSimpleCalendarEventPointWidth].active = YES;
        [self.eventPointView.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
        [self.eventPointView.topAnchor constraintEqualToAnchor:self.dayLabel.bottomAnchor constant:4].active = YES;
        
        [self setCircleColor:NO selected:NO];
    }

    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self setCircleColor:self.isToday selected:selected];
}


#pragma mark - public

- (void)setDate:(NSDate *)date calendar:(NSCalendar *)calendar
{
    NSString* day = @"";
    NSString* accessibilityDay = @"";
    if (date && calendar) {
        _date = date;
        day = [PWSimpleCalendarViewCell formatDate:date withCalendar:calendar];
        accessibilityDay = [PWSimpleCalendarViewCell formatAccessibilityDate:date withCalendar:calendar];
    }else {
        _date = nil;
        _eventPointView.hidden = YES;
    }
    self.dayLabel.text = day;
    self.dayLabel.accessibilityLabel = accessibilityDay;
}

- (void)setIsToday:(BOOL)isToday
{
    _isToday = isToday;
    [self setCircleColor:isToday selected:self.selected];
}

- (void)setIsEnable:(BOOL)isEnable {
    _isEnable = isEnable;
    [self refreshCellColors];
}

- (void)setHasEvent:(BOOL)hasEvent {
    _hasEvent = hasEvent;
    [self refreshCellColors];
}


- (void)setCircleColor:(BOOL)today selected:(BOOL)selected
{
    UIColor *circleColor = (today) ? [self circleTodayColor] : [self circleDefaultColor];
    UIColor *textColor = (today) ? [self textTodayColor] : [self textDefaultColor];
    
    if (self.isEnable) {
        if (selected) {
            circleColor = [self circleSelectedColor];
            textColor = [self textSelectedColor];
        }
    }else {
        circleColor = self.circleDefaultColor;
        textColor = self.textDisabledColor;
    }
    if (today) {
        if (selected) {
            [self.dayLabel setBackgroundColor:circleColor];
            self.dayLabel.layer.borderWidth = 0;
            self.dayLabel.layer.borderColor = nil;
        }else {
            [self.dayLabel setBackgroundColor:[self circleDefaultColor]];
            self.dayLabel.layer.borderWidth = 2;
            self.dayLabel.layer.borderColor = circleColor.CGColor;
        }
    }else {
        [self.dayLabel setBackgroundColor:circleColor];
    }
    if (self.hasEvent) {
        self.eventPointView.hidden = NO;
        self.eventPointView.backgroundColor = self.eventPointColor;
    }else {
        self.eventPointView.hidden = YES;
    }
    [self.dayLabel setTextColor:textColor];
}


- (void)refreshCellColors
{
    if (!_date) return;
    [self setCircleColor:self.isToday selected:self.isSelected];
}

- (BOOL)isTheSameDateTo:(NSDate *)date {
    return [self.date compare:date] == NSOrderedSame;
}


#pragma mark - Prepare for Reuse

- (void)prepareForReuse
{
    [super prepareForReuse];
    _date = nil;
    _isToday = NO;
    _isEnable = YES;
    _hasEvent = NO;
    _eventPointView.hidden = YES;
    self.dayLabel.layer.borderWidth = 0;
    self.dayLabel.layer.borderColor = nil;
    [self.dayLabel setText:@""];
    [self.dayLabel setBackgroundColor:[self circleDefaultColor]];
    [self.dayLabel setTextColor:[self textDefaultColor]];
}

#pragma mark - Circle Color Customization Methods

- (UIColor *)circleDefaultColor
{
    if(_circleDefaultColor == nil) {
        _circleDefaultColor = [[[self class] appearance] circleDefaultColor];
    }

    if(_circleDefaultColor != nil) {
        return _circleDefaultColor;
    }

    return [UIColor whiteColor];
}

- (UIColor *)circleTodayColor
{
    if(_circleTodayColor == nil) {
        _circleTodayColor = [[[self class] appearance] circleTodayColor];
    }

    if(_circleTodayColor != nil) {
        return _circleTodayColor;
    }

    return [UIColor grayColor];
}

- (UIColor *)circleSelectedColor
{
    if(_circleSelectedColor == nil) {
        _circleSelectedColor = [[[self class] appearance] circleSelectedColor];
    }

    if(_circleSelectedColor != nil) {
        return _circleSelectedColor;
    }

    return [UIColor redColor];
}

#pragma mark - Text Label Customizations Color

- (UIColor *)textDefaultColor
{
    if(_textDefaultColor == nil) {
        _textDefaultColor = [[[self class] appearance] textDefaultColor];
    }

    if(_textDefaultColor != nil) {
        return _textDefaultColor;
    }

    return [UIColor blackColor];
}

- (UIColor *)textTodayColor
{
    if(_textTodayColor == nil) {
        _textTodayColor = [[[self class] appearance] textTodayColor];
    }

    if(_textTodayColor != nil) {
        return _textTodayColor;
    }

    return [UIColor whiteColor];
}

- (UIColor *)textSelectedColor
{
    if(_textSelectedColor == nil) {
        _textSelectedColor = [[[self class] appearance] textSelectedColor];
    }

    if(_textSelectedColor != nil) {
        return _textSelectedColor;
    }

    return [UIColor whiteColor];
}

- (UIColor *)textDisabledColor
{
    if(_textDisabledColor == nil) {
        _textDisabledColor = [[[self class] appearance] textDisabledColor];
    }

    if(_textDisabledColor != nil) {
        return _textDisabledColor;
    }

    return [UIColor lightGrayColor];
}

- (UIColor *)eventPointColor {
    if (_eventPointColor == nil) {
        _eventPointColor = [[[self class] appearance] eventPointColor];
    }
    if (_eventPointColor != nil) {
        return _eventPointColor;
    }
    return [UIColor systemYellowColor];
}

#pragma mark - Text Label Customizations Font

- (UIFont *)textDefaultFont
{
    if(_textDefaultFont == nil) {
        _textDefaultFont = [[[self class] appearance] textDefaultFont];
    }

    if (_textDefaultFont != nil) {
        return _textDefaultFont;
    }

    // default system font
    return [UIFont systemFontOfSize:17.0];
}

@end
