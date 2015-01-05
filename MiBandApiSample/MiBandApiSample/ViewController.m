//
//  ViewController.m
//  MiBandApiSample
//
//  Created by TracyYih on 14/12/31.
//  Copyright (c) 2014年 esoftmobile.com. All rights reserved.
//

#import "ViewController.h"
#import "MiBand.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *controlPanel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) MBCentralManager *centralManager;
@property (nonatomic, strong) MBPeripheral *peripheral;
@property (weak, nonatomic) IBOutlet UILabel *realtimeStepsLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepsLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    self.controlPanel.hidden = YES;
    
    self.centralManager = [MBCentralManager sharedCentralManager];
    
    __weak typeof(self) weakSelf = self;
    [self.centralManager setPoweredOnBlock:^(MBCentralManager *manager) {
        [weakSelf.activityIndicator startAnimating];
        [manager scanForMiBandWithBlock:^(MBPeripheral *miband, NSNumber *RSSI, NSError *error) {
            [weakSelf.tableView reloadData];
        }];
    }];
    [self.centralManager setPoweredOffBlock:^(MBCentralManager *manager) {
        [weakSelf.activityIndicator stopAnimating];
        [manager stopScan];
        weakSelf.controlPanel.hidden = YES;
    }];
    [self.centralManager setDisconnectedBlock:^(MBPeripheral *peripheral, NSError *error) {
        weakSelf.peripheral = nil;
        [weakSelf.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.nextResponder touchesEnded:touches withEvent:event];
    [self.view endEditing:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == 1) { //步行目标
        [self.peripheral setGoalSteps:[textField.text integerValue] withBlock:^(NSError *error) {
            NSLog(@"设置目标成功  %@", error);
        }];
    } else {    //来电提醒时长
        NSString *text = textField.text;
        int time = [text intValue];
        [self.peripheral setCallRemindInterval:time withBlock:^(NSError *error) {
            if (!error) {
                NSLog(@"设置来电提醒成功 %d", time);
            }
        }];
    }
}

#pragma mark - 
- (void)onPeripheralConnected:(MBPeripheral *)peripheral {
    self.peripheral = peripheral;

    [self.centralManager stopScan];
    [self.activityIndicator stopAnimating];
    self.controlPanel.hidden = NO;
    [self.tableView reloadData];
    
    __weak typeof(self) this = self;
    [self.peripheral setLowLEParamsWithBlock:^(NSError *error) {
        NSLog(@"设置LE Params 成功 %@", error);
        
        MBUserInfoModel *me = [[MBUserInfoModel alloc] init];
        me.uid = 614891;
        me.alias = @"Hacker";
        me.age = 26;
        me.height = 173;
        me.weight = 55;
        me.gender = 1;
        [this.peripheral bindingWithUser:me withBlock:^(NSError *error) {
            NSLog(@"绑定用户信息成功 %@  %@", me, error);
            
            MBDateTimeModel *datetime = [[MBDateTimeModel alloc] init];
            datetime.newerDate = [NSDate date];
            [this.peripheral setDateTimeInfo:datetime withBlock:^(NSError *error) {
                NSLog(@"设置时间成功 %@",error);
                
                [this.peripheral readRealtimeStepsWithBlock:^(NSUInteger steps, NSError *error) {
                    this.realtimeStepsLabel.text = [NSString stringWithFormat:@"%tu", steps];
                }];
            }];
        }];
    }];
}

#pragma mark - Actions / APIs
- (IBAction)bindingUser:(id)sender {
    MBUserInfoModel *me =
    [[MBUserInfoModel alloc] initWithName:@"Hacker"
                                      uid:614891
                                   gender:MBGenderTypeMale
                                      age:26
                                   height:173
                                   weight:55
                                     type:MBAuthTypeNormal];
    
    MBPeripheral *peripheral = self.peripheral;
    [peripheral bindingWithUser:me withBlock:^(NSError *error) {
        NSLog(@"绑定用户信息成功 %@  %@", me, error);
    }];
}
- (IBAction)getStatistics:(id)sender {
    [self.peripheral readStatisticsWithBlock:^(MBStatisticsModel *statistics, NSError *error) {
        NSLog(@"%@ %@", statistics, error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[statistics description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }];
}


- (IBAction)getUserInfo:(id)sender {
    [self.peripheral readUserInfoWithBlock:^(MBUserInfoModel *userInfo, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[userInfo description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }];
}
    
- (IBAction)incallRemindSwitchChanged:(UISwitch *)sender {
    if (![sender isOn]) {
        [self.peripheral setCallRemindInterval:0 withBlock:^(NSError *error) {
            if (!error) {
                NSLog(@"关闭来电提醒成功");
            }
        }];
    }
}
- (IBAction)getActivityData:(id)sender {
    [self.peripheral readActivityDataWithBlock:^(NSArray *activities, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[activities description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }];
}

- (IBAction)getDateTime:(id)sender {
    [self.peripheral subscribeRealtimeStepsWithBlock:^(NSUInteger steps, NSError *error) {
        self.realtimeStepsLabel.text = [NSString stringWithFormat:@"%tu", steps];
    }];
}

- (IBAction)rebootMiBand:(id)sender {
//    [self.cbPeripheral writeValue:[NSData dataFromString:@"<09>"] forCharacteristic:self.controlCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (IBAction)findMiBand:(id)sender {
    [self.peripheral sendNotificationWithType:MBNotificationTypeNormal withBlock:^(NSError *error) {
        NSLog(@"%s\t%d %@", __FUNCTION__, __LINE__,error);
    }];

}

- (IBAction)getDeviceName:(id)sender {
    [self.peripheral readDeviceName:^(NSString *name, NSError *error) {
        NSLog(@"%@ %@", name, error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:name delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }];
}

- (IBAction)getBatteryInfo:(id)sender {
    [self.peripheral readBatteryInfoWithBlock:^(MBBatteryInfoModel *batteryInfo, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[batteryInfo description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }];
    
}

- (IBAction)handChanged:(UISegmentedControl *)segmentControl {
    [self.peripheral setWearPosition:segmentControl.selectedSegmentIndex withBlock:^(NSError *error) {
        NSLog(@"error %@", error);
    }];
}

- (IBAction)colorChanged:(UISegmentedControl *)segmentControl {
    
    NSInteger index = segmentControl.selectedSegmentIndex;
    switch (index) {
        case 0: {
            [self.peripheral setColorWithRed:6 green:0 blue:0 blink:YES withBlock:^(NSError *error) {
                if (!error) {
                    NSLog(@"set red color success");
                }
            }];
            break;
        }
        case 1: {
            [self.peripheral setColorWithRed:6 green:2 blue:0 blink:YES withBlock:^(NSError *error) {
                if (!error) {
                    NSLog(@"set orange color success");
                }
            }];
            break;
        }
        case 2: {
            [self.peripheral setColorWithRed:0 green:6 blue:0 blink:YES withBlock:^(NSError *error) {
                if (!error) {
                    NSLog(@"set green color success");
                }
            }];
            break;
        }
        case 3: {
            [self.peripheral setColorWithRed:0 green:0 blue:6 blink:YES withBlock:^(NSError *error) {
                if (!error) {
                    NSLog(@"set blue color success");
                }
            }];
            break;
        }
        default:
            break;
    }
}

- (IBAction)getDeviceInfo:(id)sender {
    [self.peripheral readDeviceInfoWithBlock:^(MBDeviceInfoModel *deviceInfo, NSError *error) {
        NSLog(@"%@ %@", deviceInfo, error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[deviceInfo description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }];
}

- (IBAction)getLEParams:(id)sender {
    
    [self.peripheral readLEParamsWithBlock:^(MBLEParamsModel *leparams, NSError *error) {
        NSLog(@"%@ %@", leparams, error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[leparams description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }];
}

- (IBAction)setAlarmClock:(id)sender {
    NSDate *date = [[NSDate date] dateByAddingTimeInterval:60];
    
    MBAlarmClockModel *model = [[MBAlarmClockModel alloc] init];
    model.days = MBDaysOnce;
    model.index = 0;
    model.enabled = YES;
    model.date = date;
    NSLog(@"date %@", date);
    NSLog(@"%@", [model date]);
    [self.peripheral setAlarmClock:model withBlock:^(NSError *error) {
        NSLog(@"设定闹钟成功 %@", error);
    }];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.centralManager.peripherals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    MBPeripheral *peripheral = self.centralManager.peripherals[indexPath.row];
    cell.accessoryType = peripheral.isConnected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    cell.textLabel.text = peripheral.name;
    cell.detailTextLabel.text = peripheral.identifier;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MBPeripheral *peripheral = self.centralManager.peripherals[indexPath.row];
    __weak typeof(self) weakSelf = self;
    [self.centralManager connectPeripheral:peripheral withResultBlock:^(MBPeripheral *peripheral, NSError *error) {
        if (error) {
            return [[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
        [weakSelf onPeripheralConnected:peripheral];
    }];
}


@end
