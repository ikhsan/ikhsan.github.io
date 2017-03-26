//
//  ViewController.m
//  Notification
//
//  Created by Ikhsan Assaat on 26/03/2017.
//  Copyright © 2017 ikhsan. All rights reserved.
//

#import "ViewController.h"
#import "Notification-Swift.h"

typedef NS_ENUM(NSInteger, State) {
    StateResumed,
    StateStopped
};

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *counterLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (nonatomic, assign) State state;
@property (nonatomic, assign) NSInteger counterValue;
@property (nonatomic, strong) id<NSObject> token;
@property (nonatomic, readonly) Counter *counter;
@property (nonatomic, readonly) NSNotificationCenter *notifCenter;

@end

@implementation ViewController

- (Counter *)counter {
    return [Counter default];
}

- (NSNotificationCenter *)notifCenter {
    return [NSNotificationCenter defaultCenter];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.state = StateStopped;
    self.counterValue = self.counter.count;
    [self render];

    __weak __typeof(self)weakSelf = self;
    self.token = [self.notifCenter observeWithClassType:CounterDidChangeNotification.class using:^(CounterDidChangeNotification *notification) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.counterValue = notification.count;
        [strongSelf render];

        NSLog(@"%ld", (long)notification.count);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.notifCenter removeObserver:self.token];
}

- (void)render {
    if (self.state == StateResumed) {
        [self.startButton setTitle:@"Stop" forState:UIControlStateNormal];
        self.counterLabel.text = [NSString stringWithFormat:@"%@", @(self.counterValue)];
    } else if (self.state == StateStopped) {
        [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
        self.counterLabel.text = @"Press start button";
    }
}

- (IBAction)startOrStop:(id)sender {
    if (self.state == StateResumed) {
        [self stopCounting];
    } else if (self.state == StateStopped) {
        [self startCounting];
    }
}

- (void)startCounting {
    [self.counter start];
    self.state = StateResumed;
    [self render];
}

- (void)stopCounting {
    [self.counter stop];
    self.state = StateStopped;
    [self render];
}

@end
