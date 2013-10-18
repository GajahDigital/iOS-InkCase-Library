//
//  ConnectionInterfaceViewController.m
//  inkcase-now
//
//  Created by diffy on 12/7/13.
//  Copyright (c) 2013 Gajah Digital. All rights reserved.
//

#import "ViewController.h"

@interface ViewController()

@end

@implementation ViewController

@synthesize sensorsTable;
@synthesize progress;
@synthesize isAutoConnect;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initConnect];
}


-(void)initConnect
{
    if([servicearr count] == 0)
    {
        servicearr = [NSMutableArray array];
        [[LeDiscovery sharedInstance] setDiscoveryDelegate:self];
        [[LeDiscovery sharedInstance] setFileServiceDelegate:self];
        [[LeDiscovery sharedInstance] startScanning];
        lefs = [[LeFileService alloc] init];
        
        [self.label setText:@"Scanning..."];
    }
}


-(void)disconnectPeripheral
{
    [[LeDiscovery sharedInstance] stopScanning];
    
    if([servicearr count] > 0)
    {
        if(ap != nil && ap.isConnected)
        {
            [[LeDiscovery sharedInstance] disconnectPeripheral:ap];
        }
    }
}

//saved devices for autoconnect and autosend
-(NSString *)prepareDevicesPlist
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dataPath = [documentsPath stringByAppendingPathComponent:@"devices.plist"];
    
    
    if ([fileManager fileExistsAtPath:dataPath] == NO)
    {
        NSString *tessdataPath = [[NSBundle mainBundle] pathForResource:@"devices" ofType:@"plist"];
        [fileManager copyItemAtPath:tessdataPath toPath:dataPath error:&error];
    }
    
    return dataPath;
}


#pragma mark   协议

/*该协议将会在查询到新设备时 被执行*/
- (void) discoveryDidRefresh
{
    servicearr = [[LeDiscovery sharedInstance] foundPeripherals];
    [self.sensorsTable reloadData];
    
    [self.label setText:[NSString stringWithFormat:@"Found Devices: %d",[servicearr count]]];
    
    // disable auto connect.
    return;
    
    
    //get the saved uuid from plist
    NSDictionary *savedDevicesDict = [NSDictionary dictionaryWithContentsOfFile:[self prepareDevicesPlist]];
    NSString *savedUUIDString = [savedDevicesDict valueForKey:@"peripheral"];
    
    if(savedUUIDString == nil || [savedUUIDString isEqualToString:@"(null)"] || savedUUIDString.length != 36) //36 with 4 hyphens
    {
        //mySingleton.isAutoConnect = NO;
        sensorsTable.hidden = NO;
        self.label.hidden = YES;
        progress.hidden = YES;
        return;
    }
    
    if(!isAutoConnect) //show the table for device list
    {
        sensorsTable.hidden = NO;
        self.label.hidden = YES;
        self.progress.hidden = YES;
        return;
    }
    
    //look for a match from our saved uuid
    for (int i = 0; i < [servicearr count]; i++) {
        NSMutableDictionary *serviceDisct = [servicearr objectAtIndex:i];
        CBPeripheral* p = (CBPeripheral*)[serviceDisct objectForKey:@"peripheral"];
        
        NSString *uuidString = [NSString stringWithFormat:@"%@",p.UUID];
        uuidString = [uuidString substringFromIndex:[uuidString length] - 36];
        
        if([savedUUIDString rangeOfString:uuidString].location != NSNotFound)
        {
            NSLog(@"savedUUIDString %@ len %d",savedUUIDString,savedUUIDString.length);
            NSLog(@"foundUUID %@ len %d",uuidString,uuidString.length);
            
            NSMutableDictionary *PDic = [servicearr objectAtIndex:i];
            CBPeripheral* perip = (CBPeripheral*)[PDic objectForKey:@"peripheral"];
            ap = perip;
            
            if(perip.isConnected == NO)
            {
                [[LeDiscovery sharedInstance] connectPeripheral:perip];
            }
            else
            {
                [self sendPicture];
            }
        }
    }
}
/*该协议将会在蓝牙关闭时，被执行*/
- (void) discoveryStatePoweredOff
{
    
}

/*
 * 方法名：-(void) fileServiceDidConnected:(LeFileService*)service
 * 说明：该方法在服务成功连接后，被执行。此后，就可以调用LeFileService的传送文件方法了。
 * 参数：service 连接的LeFileService对象
 *
 **/
-(void) fileServiceDidConnected:(LeFileService*)service
{
    lefs = service;
    [self.sensorsTable reloadData];
    
    self.label.hidden = NO;
    progress.hidden = NO;
    
    [self.label setText:@"Connected to casing!"];
    
    //save this device's uuid to plist
    NSString *dictPath = [self prepareDevicesPlist];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:dictPath];
    
    NSString *uuid = [NSString stringWithFormat:@"%@",ap.UUID];
    
    if(uuid.length > 36)
    {
        uuid = [uuid substringFromIndex:uuid.length - 36];
        
        if(uuid.length == 36)
        {
            [dict setValue:uuid forKey:@"peripheral"];
            [dict writeToFile:dictPath atomically:YES];
            
            [self sendPicture];
        }
        else
        {
            [self.label setText:@"Invalid Peripheral UUID"];
        }
    }
    else
    {
        [self.label setText:@"Invalid Peripheral UUID"];
    }
}

/*
 * 方法名：-(void) fileServiceDisConnected:(LeFileService*)service
 * 说明：该方法在服务断开连接后，被执行。如果代码中存在对该LeFileService对象的引用，请释放引用。
 * 参数：service 断开连接的LeFileService。
 *
 */
-(void) fileServiceDisConnected:(LeFileService*)service
{
    [self.sensorsTable reloadData];
    NSLog(@"Disconnect!");
    
}

/*
 * 方法名：-(void) fileService:(LeFileService*)service didSendFileSuccess:(BOOL)success
 * 说明：该协议在服务发送文件成功后或失败后，被执行,参数 success为true表示发送成功，否则表示发送失败
 * 参数 service 发送成功的Service。
 * 参数 success YES表示成功，否则表示失败。
 *
 */
-(void) fileService:(LeFileService*)service didSendFileSuccess:(BOOL)success
{

    [[LeDiscovery sharedInstance] stopScanning];
    [self.label setText:@"Sent successfully!"];
    
    [self.progress setProgress:0.0];
    
    [self disconnectPeripheral];
}

/*
 * 方法名：-(void) fileService:(LeFileService*)service refuseWithErrorCode:(uint16_t)errorCode
 * 说明：该协议方法在设备拒绝接收文件时，被执行，参数errorCode为设备发送来的错误码
 * 参数：service 拒绝接收文件的service。
 * 参数：errorCode，拒绝的原因。由下位机返回的0x80A1指令中的errorCode。
 *
 */
-(void) fileService:(LeFileService*)service refuseWithErrorCode:(uint16_t)errorCode
{
    
}


-(void) fileService:(LeFileService*)service progressUpdate:(NSInteger)sentBytes
{
    float totalSize = [service currentFileSize];
    float currentBytes = sentBytes;
    
    float currentPercentRate = currentBytes / totalSize;
    
    [self performSelectorOnMainThread:@selector(setLoaderProgress:) withObject:[NSNumber numberWithFloat:currentPercentRate] waitUntilDone:NO];
}


- (void)setLoaderProgress:(NSNumber *)number
{
    if (number.floatValue > 1.0)
        number = [NSNumber numberWithInt:1.0];
    [self.label setText:@"Sending...."];
    [progress setProgress:number.floatValue animated:NO];
}

/*
 * 方法名：fileServiceDidReset
 * 说明：当服务被重置时，被调用，与服务断开不同，该方法一般是由用户执行了LeDiscovery::clearDevices 引起的
 * 参数：无
 *
 */
-(void) fileServiceDidReset
{
    
}

/*
 * 方法名：armFileToIos
 * 说明：下位机上传文件到上位机
 * 参数：文件数据,文件类型
 *
 */
-(void) armFileToIos:(NSMutableData*) mfd withExtend:(uint16_t)extend
{
    
}

/*
 * 方法名：-(void) fileService:(LeFileService*)service progressUpdate:(NSInteger)sentBytes
 * 说明：下位机按键命令
 *
 */

-(void) fileServiceDidPush
{
    NSLog(@"did push");
}

#pragma mark   列表
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [servicearr count] == 0 ? 0 : [servicearr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSMutableDictionary *PDic = [servicearr objectAtIndex:indexPath.row];
    CBPeripheral* p = (CBPeripheral*)[PDic objectForKey:@"peripheral"];
    NSString* pname = [PDic objectForKey:@"kCBAdvDataLocalName"];
    if(p.isConnected)
    {
        cell.imageView.image = [UIImage imageNamed:@"check.png"];
    }
    else
    {
        cell.imageView.image = [UIImage imageNamed:@"cross.png"];
    }
    cell.textLabel.text = pname;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *PDic = [servicearr objectAtIndex:indexPath.row];
    
    ap =  (CBPeripheral*)[PDic objectForKey:@"peripheral"];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"BT" message:@"Action"
                                                       delegate:self cancelButtonTitle:nil
                                              otherButtonTitles:@"Connect & Send", @"Cancel", nil];
    
    [alertView show];
}

-(void)connectRightAway:(CBPeripheral	*) peripheral
{
    
    if(![peripheral isConnected])
    {
        NSLog(@"=== connect ===");
        [[LeDiscovery sharedInstance] connectPeripheral:peripheral];
        
        [self.sensorsTable reloadData];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (buttonIndex == 0){
        [self connectRightAway:ap];
        //[self sendPicture];
            
    }
    else{
        [self disconnectPeripheral];
    }
}


-(void)sendPicture
{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"spidey" ofType:@"jpg"];

    //send file!
    if(imagePath.length > 10)
    {
        if(ap.isConnected)
        {
            NSInteger fileSize = [lefs sendFileWithPath:imagePath withExtend:0xc064 withFolder:0x01];
            NSLog(@"%@ size:%d",imagePath,fileSize);
            [self.label setText:@"Sending..."];
        }
    }
    else
    {
        [self.label setText:@"picture not found."];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
