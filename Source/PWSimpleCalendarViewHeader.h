//
//  PWSimpleCalendarViewHeader.h
//  PDTSimpleCalendar
//
//  Created by Jerome Miglino on 10/8/13.
//  Copyright (c) 2013 Producteev. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  The `PWSimpleCalendarViewHeader` class displays the month name and year.
 */
@interface PWSimpleCalendarViewHeader : UICollectionReusableView

/**
 *  Label that display the month and year
 */
@property (nonatomic, strong) UILabel *titleLabel;

/** @name Customizing Appearance */

/**
 *  Customize the Month text color display.
 */
@property (nonatomic, strong) UIColor *textColor UI_APPEARANCE_SELECTOR;

/**
 *  Customize the Month text font.
 */
@property (nonatomic, strong) UIFont *textFont UI_APPEARANCE_SELECTOR;

/**
 *  Customize the separator color between the month name and the dates.
 */
@property (nonatomic, strong) UIColor *separatorColor UI_APPEARANCE_SELECTOR;

@end
