//
//  PWSimpleCalendarView.h
//  PDTSimpleCalendar
//
//  Created by Jerome Miglino on 10/7/13.
//  Copyright (c) 2013 Producteev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PWSimpleCalendarViewWeekdayHeader.h"
#import "PWSimpleCalendarViewCell.h"

extern NSString *const PWSimpleCalendarViewCellIdentifier;

@protocol PWSimpleCalendarViewDelegate;

/**
 *  `PWSimpleCalendarView` is a `UICollectionViewController` subclass that displays a scrollable calendar view inspired by iOS7 Apple Cal App.
 */
@interface PWSimpleCalendarView : UIView <UICollectionViewDelegateFlowLayout>

/** @name Calendar Setup */

/**
 *  The calendar used to generate the view.
 *
 *  If not set, the default value is `[NSCalendar currentCalendar]`
 */
@property (nonatomic, strong) NSCalendar *calendar;

/**
 *  First date enabled in the calendar. If not set, the default value is the first day of the current month (based on `[NSDate date]`).
 *  You can pass every `NSDate`, if the firstDate is not the first day of its month, the previous days will be automatically disabled.
 */
@property (nonatomic, strong) NSDate *firstDate;

/**
 *  Last date enabled in the calendar. If not set, the default value is the first day of the month of `firstDate` + one year using `calendar` for calculation
 *  You can pass every `NSDate`, if the lastDate is not the last day of its month, the following days will be automatically disabled.
 */
@property (nonatomic, strong) NSDate *lastDate;

/**
 *  Selected date displayed by the calendar.
 *  Changing this value will not cause the calendar to scroll to this date.
 *  You need to manually call scrollToSelectedDate:(BOOL)animated if you want this behavior.
 *  Attention，set this property will not  trigger the delegate method  PWSimpleCalendarView:didSelectDate: 
 */
@property (nonatomic, strong) NSDate *selectedDate;

/**
 *  Text color for the overlay view (Month and Year when the user scrolls the calendar)
 */
@property (nonatomic, strong) UIColor *overlayTextColor;

/**
 *  background color for the overlay view (Month and Year when the user scrolls the calendar)
 */
@property (nonatomic, strong) UIColor *overlayBackgroundColor;


/** @name Getting Notified of changes */

/**
 *  The delegate of the calendar.
 *  Must adopt the `PWSimpleCalendarViewDelegate` protocol.
 *
 *  @see PWSimpleCalendarViewDelegate
 */
@property (nonatomic, weak) id<PWSimpleCalendarViewDelegate> delegate;


///call this method in UIViewController: - (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration to relayout.
- (void)relayoutCalendar;

/**
 *  Scroll to the current selected date in the calendar.
 *
 *  @param animated if you want to animate the scrolling
 */
- (void)scrollToSelectedDate:(BOOL)animated;

/**
 *  Scroll to a certain date in the calendar.
 *
 *  @param date     the date you wanna scroll to.
 *  @param animated if you want to animate the scrolling
 */
- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated;

@end


/**
 *  The methods in `PWSimpleCalendarViewDelegate` are all optional. It allows the delegate to be notified when the user interacts with the Calendar.
 */
@protocol PWSimpleCalendarViewDelegate <NSObject>

@optional

/**
 *  Asks the delegate if the Calendar may enable selection for the specified date
 *
 *  @param calendarView  the calendarView Controller
 *  @param date       the date (Midnight GMT)
 *
 *  @return YES if the calendar can select the specified date, NO otherwise.
 */
- (BOOL)PWSimpleCalendarView:(PWSimpleCalendarView *)calendarView isEnabledDate:(NSDate *)date;

/**
 *  Tells the delegate that a date was selected by the user.
 *
 *  @param calendarView the calendarView Controller
 *  @param date       the date being selected (Midnight GMT).
 */
- (void)PWSimpleCalendarView:(PWSimpleCalendarView *)calendarView didSelectDate:(NSDate *)date;

/**
 *  处理 cell 的UI
 *
 *  @param calendarView the calendarView Controller
 *  @param date       the date being selected (Midnight GMT).
 */
- (void)PWSimpleCalendarView:(PWSimpleCalendarView *)calendarView calendarViewCell:(PWSimpleCalendarViewCell *)cell date:(NSDate *)date;


@end;
