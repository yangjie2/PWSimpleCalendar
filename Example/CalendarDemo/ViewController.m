//
//  ViewController.m
//  CalendarDemo
//
//  Created by yangjie on 2022/11/18.
//

#import "ViewController.h"
#import "PWSimpleCalendarView.h"
#import "PWSimpleCalendarViewCell.h"
#import "PWSimpleCalendarViewHeader.h"

@interface ViewController ()<PWSimpleCalendarViewDelegate>
- (IBAction)popCalendar:(id)sender;
@property (nonatomic, weak) PWSimpleCalendarView *calendarView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //Example of how you can now customize the calendar colors
    
    [[PWSimpleCalendarViewWeekdayHeader appearance] setTextColor:UIColor.darkTextColor];
    [[PWSimpleCalendarViewWeekdayHeader appearance] setTextFont:[UIFont systemFontOfSize:14]];

    
    [[PWSimpleCalendarViewCell appearance] setCircleDefaultColor:[UIColor whiteColor]];
    [[PWSimpleCalendarViewCell appearance] setTextDefaultColor:[UIColor blackColor]];
    [[PWSimpleCalendarViewCell appearance] setCircleSelectedColor:[UIColor systemYellowColor]];
    [[PWSimpleCalendarViewCell appearance] setTextSelectedColor:[UIColor whiteColor]];
    [[PWSimpleCalendarViewCell appearance] setCircleTodayColor:[UIColor systemYellowColor]];
    [[PWSimpleCalendarViewCell appearance] setTextTodayColor:[UIColor blackColor]];
    [[PWSimpleCalendarViewCell appearance] setTextDefaultFont:[UIFont systemFontOfSize:16]];
    
    [[PWSimpleCalendarViewHeader appearance] setBackgroundColor:[UIColor whiteColor]];
    [[PWSimpleCalendarViewHeader appearance] setTextColor:[UIColor systemGreenColor]];
    [[PWSimpleCalendarViewHeader appearance] setSeparatorColor:[UIColor lightGrayColor]];
    [[PWSimpleCalendarViewHeader appearance] setTextFont:[UIFont systemFontOfSize:14]];
    
}


#pragma mark - PWSimpleCalendarViewDelegate

- (void)PWSimpleCalendarView:(PWSimpleCalendarView *)controller didSelectDate:(NSDate *)date
{
    NSLog(@"Date Selected with Locale %@", [date descriptionWithLocale:[NSLocale systemLocale]]);
}

- (void)PWSimpleCalendarView:(PWSimpleCalendarView *)controller calendarViewCell:(PWSimpleCalendarViewCell *)cell date:(NSDate *)date {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([date compare:cell.date] == NSOrderedSame) {
            if ([date compare:controller.firstDate] == NSOrderedSame) {
                [cell setHasEvent:YES];
            }
        }
    });
}



#pragma mark - action

- (IBAction)popCalendar:(id)sender {
    //自定义显示日期的范围
    PWSimpleCalendarView *calendarView = [[PWSimpleCalendarView alloc] init];
    calendarView.delegate = self;
    //For this calendar we're gonna allow only a selection between today and today + 3months.
    calendarView.overlayTextColor = UIColor.systemGreenColor;
    
    NSDate *firstDate = [calendarView.calendar dateByAddingUnit:NSCalendarUnitDay value:-30 toDate:[NSDate date] options:0];
    calendarView.lastDate = [NSDate date];
    calendarView.firstDate = firstDate;
    NSDate *selectedDate = [calendarView.calendar dateByAddingUnit:NSCalendarUnitDay value:2 toDate:firstDate options:0];
    calendarView.selectedDate = selectedDate;
    [self.view addSubview:calendarView];
    calendarView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [calendarView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:0].active = YES;
    [calendarView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:0].active = YES;
    [calendarView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:0].active = YES;
    [calendarView.topAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-100].active = YES;
    
    self.calendarView = calendarView;
}


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self.calendarView relayoutCalendar];
    } completion:nil];
}


@end
