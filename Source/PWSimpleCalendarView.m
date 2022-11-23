//
//  PWSimpleCalendarView.m
//  PDTSimpleCalendar
//
//  Created by Jerome Miglino on 10/7/13.
//  Copyright (c) 2013 Producteev. All rights reserved.
//

#import "PWSimpleCalendarView.h"

#import "PWSimpleCalendarViewFlowLayout.h"
#import "PWSimpleCalendarViewCell.h"
#import "PWSimpleCalendarViewHeader.h"


const CGFloat PDTSimpleCalendarOverlaySize = 14.0f;

NSString * const PWSimpleCalendarViewCellIdentifier = @"com.producteev.collection.cell.identifier";
static NSString *const PWSimpleCalendarViewHeaderIdentifier = @"com.producteev.collection.header.identifier";
static const NSCalendarUnit kCalendarUnitYMD = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;

@interface PWSimpleCalendarView () <UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *overlayView;
@property (nonatomic, strong) NSDateFormatter *headerDateFormatter; //Will be used to format date in header view and on scroll.

@property (nonatomic, strong) PWSimpleCalendarViewWeekdayHeader *weekdayHeader;

// First and last date of the months based on the public properties first & lastDate
@property (nonatomic) NSDate *firstDateMonth;
@property (nonatomic) NSDate *lastDateMonth;

//Number of days per week
@property (nonatomic, assign) NSUInteger daysPerWeek;

@end


@implementation PWSimpleCalendarView

//Explicitly @synthesize the var (it will create the iVar for us automatically as we redefine both getter and setter)
@synthesize firstDate = _firstDate;
@synthesize lastDate = _lastDate;
@synthesize calendar = _calendar;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        PWSimpleCalendarViewFlowLayout *layout = [[PWSimpleCalendarViewFlowLayout alloc] init];
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        self.collectionView.showsVerticalScrollIndicator = NO;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.overlayView = [[UILabel alloc] init];
        self.overlayTextColor = [UIColor blackColor];
        self.daysPerWeek = 7;
        [self setBackgroundColor:UIColor.whiteColor];
        
        //Configure the Weekday Header
        self.weekdayHeader = [[PWSimpleCalendarViewWeekdayHeader alloc] initWithCalendar:self.calendar];
        
        [self addSubview:self.weekdayHeader];
        [self.weekdayHeader setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.weekdayHeader.leftAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.leftAnchor constant:0].active = YES;
        [self.weekdayHeader.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:0].active = YES;
        [self.weekdayHeader.rightAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.rightAnchor constant:0].active = YES;
        [self.weekdayHeader.heightAnchor constraintEqualToConstant:PDTSimpleCalendarWeekdayHeaderHeight].active = YES;
                
        //Configure the Collection View
        [self.collectionView registerClass:[PWSimpleCalendarViewCell class] forCellWithReuseIdentifier:PWSimpleCalendarViewCellIdentifier];
        [self.collectionView registerClass:[PWSimpleCalendarViewHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:PWSimpleCalendarViewHeaderIdentifier];

        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.collectionView];
        [self.collectionView.topAnchor constraintEqualToAnchor:self.weekdayHeader.bottomAnchor constant:0].active = YES;
        [self.collectionView.leftAnchor constraintEqualToAnchor:self.weekdayHeader.leftAnchor constant:0].active = YES;
        [self.collectionView.rightAnchor constraintEqualToAnchor:self.weekdayHeader.rightAnchor constant:0].active = YES;
        [self.collectionView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:0].active = YES;

        //Configure the Overlay View
        [self.overlayView setBackgroundColor:[self.backgroundColor colorWithAlphaComponent:0.90]];
        [self.overlayView setFont:[UIFont boldSystemFontOfSize:PDTSimpleCalendarOverlaySize]];
        [self.overlayView setTextColor:self.overlayTextColor];
        [self.overlayView setAlpha:0.0];
        [self.overlayView setTextAlignment:NSTextAlignmentCenter];

        [self addSubview:self.overlayView];
        [self.overlayView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.overlayView.topAnchor constraintEqualToAnchor:self.weekdayHeader.bottomAnchor constant:0].active = YES;
        [self.overlayView.centerXAnchor constraintEqualToAnchor:self.weekdayHeader.centerXAnchor constant:0].active = YES;
        [self.overlayView.heightAnchor constraintEqualToConstant:PDTSimpleCalendarFlowLayoutHeaderHeight].active = YES;
    }
    return self;
}

- (void)relayoutCalendar {
    [self.collectionView.collectionViewLayout invalidateLayout];
}


#pragma mark - Accessors

- (NSDateFormatter *)headerDateFormatter;
{
    if (!_headerDateFormatter) {
        _headerDateFormatter = [[NSDateFormatter alloc] init];
        _headerDateFormatter.calendar = self.calendar;
        _headerDateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"yyyy LLLL" options:0 locale:self.calendar.locale];
    }
    return _headerDateFormatter;
}

- (NSCalendar *)calendar
{
    if (!_calendar) {
        [self setCalendar:[NSCalendar currentCalendar]];
    }
    return _calendar;
}

-(void)setCalendar:(NSCalendar*)calendar
{
    _calendar = calendar;
    self.headerDateFormatter.calendar = calendar;
    self.daysPerWeek = [_calendar maximumRangeOfUnit:NSCalendarUnitWeekday].length;
}

- (NSDate *)firstDate
{
    if (!_firstDate) {
        NSDateComponents *components = [self.calendar components:kCalendarUnitYMD
                                                        fromDate:[NSDate date]];
        components.day = 1;
        _firstDate = [self.calendar dateFromComponents:components];
    }

    return _firstDate;
}

- (void)setFirstDate:(NSDate *)firstDate
{
    _firstDate = [self clampDate:firstDate toComponents:kCalendarUnitYMD];
}

- (NSDate *)firstDateMonth
{
    if (_firstDateMonth) { return _firstDateMonth; }

    NSDateComponents *components = [self.calendar components:kCalendarUnitYMD
                                                    fromDate:self.firstDate];
    components.day = 1;

    _firstDateMonth = [self.calendar dateFromComponents:components];

    return _firstDateMonth;
}

- (NSDate *)lastDate
{
    if (!_lastDate) {
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        offsetComponents.year = 1;
        offsetComponents.day = -1;
        [self setLastDate:[self.calendar dateByAddingComponents:offsetComponents toDate:self.firstDateMonth options:0]];
    }

    return _lastDate;
}

- (void)setLastDate:(NSDate *)lastDate
{
    _lastDate = [self clampDate:lastDate toComponents:kCalendarUnitYMD];
}

- (NSDate *)lastDateMonth
{
    if (_lastDateMonth) { return _lastDateMonth; }

    NSDateComponents *components = [self.calendar components:kCalendarUnitYMD
                                                    fromDate:self.lastDate];
    components.month++;
    components.day = 0;

    _lastDateMonth = [self.calendar dateFromComponents:components];

    return _lastDateMonth;
}

- (void)setTheSelectedDate:(NSDate *)theSelectedDate {
    self.selectedDate = theSelectedDate;
    //Notify the delegate
    if ([self.delegate respondsToSelector:@selector(PWSimpleCalendarView:didSelectDate:)]) {
        [self.delegate PWSimpleCalendarView:self didSelectDate:self.selectedDate];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    self.collectionView.backgroundColor = backgroundColor;
}


#pragma mark - Scroll to a specific date

- (void)scrollToSelectedDate:(BOOL)animated
{
    if (_selectedDate) {
        [self scrollToDate:_selectedDate animated:animated];
    }
}

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated
{
    @try {
        NSIndexPath *selectedDateIndexPath = [self indexPathForCellAtDate:date];

        if (![[self.collectionView indexPathsForVisibleItems] containsObject:selectedDateIndexPath]) {
            //First, tried to use [self.collectionView layoutAttributesForSupplementaryElementOfKind:UICollectionElementKindSectionHeader atIndexPath:selectedDateIndexPath]; but it causes the header to be redraw multiple times (X each time you use scrollToDate:)
            //TODO: Investigate & eventually file a radar.

            NSIndexPath *sectionIndexPath = [NSIndexPath indexPathForItem:0 inSection:selectedDateIndexPath.section];
            UICollectionViewLayoutAttributes *sectionLayoutAttributes = [self.collectionView layoutAttributesForItemAtIndexPath:sectionIndexPath];
            CGPoint origin = sectionLayoutAttributes.frame.origin;
            origin.x = 0;
            origin.y -= (PDTSimpleCalendarFlowLayoutHeaderHeight + PDTSimpleCalendarFlowLayoutInsetTop + self.collectionView.contentInset.top);
            [self.collectionView setContentOffset:origin animated:animated];
        }
    }
    @catch (NSException *exception) {
        //Exception occured (it should not according to the documentation, but in reality...) let's scroll to the IndexPath then
        NSInteger section = [self sectionForDate:date];
        NSIndexPath *sectionIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        [self.collectionView scrollToItemAtIndexPath:sectionIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:animated];
    }
}

- (void)setOverlayTextColor:(UIColor *)overlayTextColor
{
    _overlayTextColor = overlayTextColor;
    if (self.overlayView) {
        [self.overlayView setTextColor:self.overlayTextColor];
    }
}

- (void)setOverlayBackgroundColor:(UIColor *)overlayBackgroundColor {
    _overlayBackgroundColor = overlayBackgroundColor;
    self.overlayView.backgroundColor = overlayBackgroundColor;
}


#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //Each Section is a Month
    return [self.calendar components:NSCalendarUnitMonth fromDate:self.firstDateMonth toDate:self.lastDateMonth options:0].month + 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSDate *firstOfMonth = [self firstOfMonthForSection:section];
    NSCalendarUnit weekCalendarUnit = [self weekCalendarUnitDependingOniOSVersion];
    NSRange rangeOfWeeks = [self.calendar rangeOfUnit:weekCalendarUnit inUnit:NSCalendarUnitMonth forDate:firstOfMonth];

    //We need the number of calendar weeks for the full months (it will maybe include previous month and next months cells)
    return (rangeOfWeeks.length * self.daysPerWeek);
}

/**
 * https://github.com/jivesoftware/PDTSimpleCalendar/issues/69
 * On iOS7, using NSCalendarUnitWeekOfMonth (or WeekOfYear) in rangeOfUnit:inUnit is returning NSNotFound, NSNotFound
 * Fun stuff, definition of NSNotFound is enum {NSNotFound = NSIntegerMax};
 * So on iOS7, we're trying to allocate NSIntegerMax * 7 cells per Section
 *
 * //TODO: Remove when removing iOS7 Support
 *
 *  @return the proper NSCalendarUnit to use in rangeOfUnit:inUnit
 */
- (NSCalendarUnit)weekCalendarUnitDependingOniOSVersion {
    //isDateInToday is a new (awesome) method available on iOS8 only.
    if ([self.calendar respondsToSelector:@selector(isDateInToday:)]) {
        return NSCalendarUnitWeekOfMonth;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        return NSWeekCalendarUnit;
#pragma clang diagnostic pop
    }
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PWSimpleCalendarViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:PWSimpleCalendarViewCellIdentifier
                                                                                     forIndexPath:indexPath];    
    NSDate *firstOfMonth = [self firstOfMonthForSection:indexPath.section];
    NSDate *cellDate = [self dateForCellAtIndexPath:indexPath];

    NSDateComponents *cellDateComponents = [self.calendar components:kCalendarUnitYMD fromDate:cellDate];
    NSDateComponents *firstOfMonthsComponents = [self.calendar components:kCalendarUnitYMD fromDate:firstOfMonth];

    BOOL isToday = NO;
    BOOL isSelected = NO;
    BOOL isDateEnable = [self isEnabledDate:cellDate];
    if (cellDateComponents.month == firstOfMonthsComponents.month) {
        isSelected = ([self isSelectedDate:cellDate] && (indexPath.section == [self sectionForDate:cellDate]));
        isToday = [self isTodayDate:cellDate];
        [cell setDate:cellDate calendar:self.calendar];

        //Ask the delegate if this date should have specific UI.
        if ([self.delegate respondsToSelector:@selector(PWSimpleCalendarView:calendarViewCell:date:)] && isDateEnable) {
            [self.delegate PWSimpleCalendarView:self calendarViewCell:cell date:cellDate];
        }
    } else {
        [cell setDate:nil calendar:nil];
    }
    
    if (isToday) {
        [cell setIsToday:isToday];
    }

    if (isSelected) {
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
    
    //If the current Date is not enabled
    if (!isDateEnable) {
        [cell setIsEnable:NO];
    }

    //We rasterize the cell for performances purposes.
    //The circle background is made using roundedCorner which is a super expensive operation, specially with a lot of items on the screen to display (like we do)
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *firstOfMonth = [self firstOfMonthForSection:indexPath.section];
    NSDate *cellDate = [self dateForCellAtIndexPath:indexPath];

    //We don't want to select Dates that are "disabled"
    if (![self isEnabledDate:cellDate]) {
        return NO;
    }

    NSDateComponents *cellDateComponents = [self.calendar components:NSCalendarUnitDay|NSCalendarUnitMonth fromDate:cellDate];
    NSDateComponents *firstOfMonthsComponents = [self.calendar components:NSCalendarUnitMonth fromDate:firstOfMonth];

    return (cellDateComponents.month == firstOfMonthsComponents.month);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self setTheSelectedDate:[self dateForCellAtIndexPath:indexPath]];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        PWSimpleCalendarViewHeader *headerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:PWSimpleCalendarViewHeaderIdentifier forIndexPath:indexPath];

        headerView.titleLabel.text = [self.headerDateFormatter stringFromDate:[self firstOfMonthForSection:indexPath.section]].capitalizedString;

        headerView.layer.shouldRasterize = YES;
        headerView.layer.rasterizationScale = [UIScreen mainScreen].scale;

        return headerView;
    }

    return nil;
}

#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat itemWidth = floorf(CGRectGetWidth(self.collectionView.bounds) / self.daysPerWeek);

    return CGSizeMake(itemWidth, itemWidth);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    //We only display the overlay view if there is a vertical velocity
    if (fabs(velocity.y) > 0.0f) {
        if (self.overlayView.alpha < 1.0) {
            [UIView animateWithDuration:0.25 animations:^{
                [self.overlayView setAlpha:1.0];
            }];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSTimeInterval delay = (decelerate) ? 1.5 : 0.0;
    [self performSelector:@selector(hideOverlayView) withObject:nil afterDelay:delay];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //Update Content of the Overlay View
    NSArray *indexPaths = [self.collectionView indexPathsForVisibleItems];
    //indexPaths is not sorted
    NSArray *sortedIndexPaths = [indexPaths sortedArrayUsingSelector:@selector(compare:)];
    NSIndexPath *firstIndexPath = [sortedIndexPaths firstObject];

    self.overlayView.text = [self.headerDateFormatter stringFromDate:[self firstOfMonthForSection:firstIndexPath.section]];
}

- (void)hideOverlayView
{
    [UIView animateWithDuration:0.25 animations:^{
        [self.overlayView setAlpha:0.0];
    }];
}

#pragma mark -
#pragma mark - Calendar calculations

- (NSDate *)clampDate:(NSDate *)date toComponents:(NSUInteger)unitFlags
{
    NSDateComponents *components = [self.calendar components:unitFlags fromDate:date];
    return [self.calendar dateFromComponents:components];
}

- (BOOL)isTodayDate:(NSDate *)date
{
    return [self clampAndCompareDate:date withReferenceDate:[NSDate date]];
}

- (BOOL)isSelectedDate:(NSDate *)date
{
    if (!self.selectedDate) {
        return NO;
    }
    return [self clampAndCompareDate:date withReferenceDate:self.selectedDate];
}

- (BOOL)isEnabledDate:(NSDate *)date
{
    NSDate *clampedDate = [self clampDate:date toComponents:kCalendarUnitYMD];
    if (([clampedDate compare:self.firstDate] == NSOrderedAscending) || ([clampedDate compare:self.lastDate] == NSOrderedDescending)) {
        return NO;
    }

    if ([self.delegate respondsToSelector:@selector(PWSimpleCalendarView:isEnabledDate:)]) {
        return [self.delegate PWSimpleCalendarView:self isEnabledDate:date];
    }

    return YES;
}

- (BOOL)clampAndCompareDate:(NSDate *)date withReferenceDate:(NSDate *)referenceDate
{
    NSDate *refDate = [self clampDate:referenceDate toComponents:kCalendarUnitYMD];
    NSDate *clampedDate = [self clampDate:date toComponents:kCalendarUnitYMD];

    return [refDate isEqualToDate:clampedDate];
}

#pragma mark - Collection View / Calendar Methods

- (NSDate *)firstOfMonthForSection:(NSInteger)section
{
    NSDateComponents *offset = [NSDateComponents new];
    offset.month = section;

    return [self.calendar dateByAddingComponents:offset toDate:self.firstDateMonth options:0];
}

- (NSInteger)sectionForDate:(NSDate *)date
{
    return [self.calendar components:NSCalendarUnitMonth fromDate:self.firstDateMonth toDate:date options:0].month;
}


- (NSDate *)dateForCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *firstOfMonth = [self firstOfMonthForSection:indexPath.section];

    NSUInteger weekday = [[self.calendar components: NSCalendarUnitWeekday fromDate: firstOfMonth] weekday];
    NSInteger startOffset = weekday - self.calendar.firstWeekday;
    startOffset += startOffset >= 0 ? 0 : self.daysPerWeek;

    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.day = indexPath.item - startOffset;

    return [self.calendar dateByAddingComponents:dateComponents toDate:firstOfMonth options:0];
}


static const NSInteger kFirstDay = 1;
- (NSIndexPath *)indexPathForCellAtDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    NSInteger section = [self sectionForDate:date];
    NSDate *firstOfMonth = [self firstOfMonthForSection:section];

    NSInteger weekday = [[self.calendar components: NSCalendarUnitWeekday fromDate: firstOfMonth] weekday];
    NSInteger startOffset = weekday - self.calendar.firstWeekday;
    startOffset += startOffset >= 0 ? 0 : self.daysPerWeek;

    NSInteger day = [[self.calendar components:kCalendarUnitYMD fromDate:date] day];

    NSInteger item = (day - kFirstDay + startOffset);

    return [NSIndexPath indexPathForItem:item inSection:section];
}

- (PWSimpleCalendarViewCell *)cellForItemAtDate:(NSDate *)date
{
    return (PWSimpleCalendarViewCell *)[self.collectionView cellForItemAtIndexPath:[self indexPathForCellAtDate:date]];
}



@end
