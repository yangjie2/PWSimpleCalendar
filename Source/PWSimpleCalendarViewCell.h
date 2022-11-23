//
//  PWSimpleCalendarViewCell.h
//  PDTSimpleCalendar
//
//  Created by Jerome Miglino on 10/7/13.
//  Copyright (c) 2013 Producteev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  The `PWSimpleCalendarViewCell` class displays a day in the calendar.
 */
@interface PWSimpleCalendarViewCell : UICollectionViewCell

/**
 *  Define if the cell is today in the calendar.
 */
@property (nonatomic, assign) BOOL isToday;

/**
 *  Define if the cell is enable in the calendar.
 */
@property (nonatomic, assign) BOOL isEnable;

/**
 *  Define did the cell  have event in the calendar.
 */
@property (nonatomic, assign) BOOL hasEvent;

/**
 *  Customize the circle behind the day's number color using UIAppearance.
 */
@property (nonatomic, strong) UIColor *circleDefaultColor UI_APPEARANCE_SELECTOR;

/**
 *  Customize the color of the circle for today's cell using UIAppearance.
 */
@property (nonatomic, strong) UIColor *circleTodayColor UI_APPEARANCE_SELECTOR;

/**
 *  Customize the color of the circle when cell is selected using UIAppearance.
 */
@property (nonatomic, strong) UIColor *circleSelectedColor UI_APPEARANCE_SELECTOR;

/**
 *  Customize the day's number using UIAppearance.
 */
@property (nonatomic, strong) UIColor *textDefaultColor UI_APPEARANCE_SELECTOR;

/**
 *  Customize today's number color using UIAppearance.
 */
@property (nonatomic, strong) UIColor *textTodayColor UI_APPEARANCE_SELECTOR;

/**
 *  Customize the day's number color when cell is selected using UIAppearance.
 */
@property (nonatomic, strong) UIColor *textSelectedColor UI_APPEARANCE_SELECTOR;

/**
 *  Customize the day's number color when cell is disabled using UIAppearance.
 */
@property (nonatomic, strong) UIColor *textDisabledColor UI_APPEARANCE_SELECTOR;

/**
 *  Customize the day's number font using UIAppearance.
 */
@property (nonatomic, strong) UIFont *textDefaultFont UI_APPEARANCE_SELECTOR;

/**
 *  Customize the day's event point color using UIAppearance.
 */
@property (nonatomic, strong) UIColor *eventPointColor UI_APPEARANCE_SELECTOR;


/**
 * Set the date for this cell
 *
 * @param date the date (Midnight GMT).
 *
 * @param calendar the calendar.
 */
- (void)setDate:(NSDate*)date calendar:(NSCalendar*)calendar;

/**
 *  Force the refresh of the colors for the circle and the text
 */
- (void)refreshCellColors;

/**
 *  Check the cell‘s date is equal to input param date
 * @param date the date.
 */
- (BOOL)isTheSameDateTo:(NSDate *)date;

@end
