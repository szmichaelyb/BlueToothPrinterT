//
//  ViewController.m
//  BlueToothPrinterT
//
//  Created by 黄董 on 16/1/14.
//  Copyright © 2016年 huangxinyu. All rights reserved.
//

#import "ViewController.h"
//#import "BluePrinterManager.h"
//#import "BluePrinterFormat.h"
#import "HHBluetoothPrinterManager.h"
#import "HHPrinterFormat.h"

@interface ViewController ()<HHBluetoothPrinterManagerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *beginScan;
@property (weak, nonatomic) IBOutlet UIButton *cancelScan;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *printButton;

@property (nonatomic, strong) HHBluetoothPrinterManager *manager;
//选中的设备
@property (nonatomic, strong) CBPeripheral *selectedPeripheral;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.manager = [HHBluetoothPrinterManager sharedManager];
    self.manager.delegate = self;
    self.dataArray = [[NSMutableArray alloc] init];
    
}

- (IBAction)startScan:(id)sender {
    [self.manager scanPeripherals];
}
- (IBAction)stopScan:(id)sender {
    [self.manager cancelScan];
}
- (IBAction)printButtonClick:(id)sender {
    //设置标题
    //1.设置字体大小
    [self.manager setupPrinterState:HHBluePrinterStateSetFontDefult];
    //2.设置居中
    [self.manager setupPrinterState:HHBluePrinterStateAlignmentLeft];
    
    NSString* title = [[HHPrinterFormat alloc] printTitle:self.textView.text];
    NSStringEncoding gbk = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
    NSData *cmdData = [title dataUsingEncoding:gbk];
    [self.manager startPrint:cmdData];
    
}

/**
 *  扫描到蓝牙设备
 *
 *  @param central    中心设备管理器
 *  @param peripheral 蓝牙设备
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral {
    [self.dataArray addObject:peripheral];
    [self.tableView reloadData];
}
/**
 *  连接设备失败
 *
 *  @param central   中心设备管理
 *  @param peripheral 蓝牙设备
 *  @param error      错误
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    
}
/**
 *  设备连接成功
 *
 *  @param central    中心设备
 *  @param peripheral 蓝牙设备
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"设备连接成功");
    //[peripheral discoverServices:nil];
    //初始化
    [self.manager setupPrinterState:HHBluePrinterStateInitialize];
    [self.manager setupPrinterState:HHBluePrinterStateSetLanage];
}

#pragma mark - tableView delegate & dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    CBPeripheral *peripheral = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = peripheral.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedPeripheral = [self.dataArray objectAtIndex:indexPath.row];
    [self.manager connectPeripheral:self.selectedPeripheral];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

@end
