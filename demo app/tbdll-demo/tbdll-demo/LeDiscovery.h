

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "LeFileService.h"




/****************************************************************************/
/*							UI protocols									*/
/****************************************************************************/
@protocol LeDiscoveryDelegate <NSObject>

/*该协议将会在查询到新设备时 被执行*/
- (void) discoveryDidRefresh;
/*该协议将会在蓝牙关闭时，被执行*/
- (void) discoveryStatePoweredOff;
@end



/****************************************************************************/
/*							Discovery class									*/
/****************************************************************************/
@interface LeDiscovery : NSObject{
    UInt8 filenameA;
    UInt8 filenameB;
    int waitTime;
}

+ (id) sharedInstance;


/****************************************************************************/
/*								UI controls									*/
/****************************************************************************/
@property (nonatomic, assign) id<LeDiscoveryDelegate>           discoveryDelegate;
@property (nonatomic, assign) id<LeFileServiceProtocol>         fileServiceDelegate;


/****************************************************************************/
/*								Actions										*/
/****************************************************************************/
/*开始搜索蓝牙设备*/
- (void) startScanning;
/*停止搜索蓝牙设备*/
- (void) stopScanning;
/*
 * 连接设备.
 * 参数:peripheral，需要连接的设备
 */
- (void) connectPeripheral:(CBPeripheral*)peripheral;
/*
 * 断开连接
 * 参数:peripheral，需要断开连接的设备
 */
- (void) disconnectPeripheral:(CBPeripheral*)peripheral;

/*
 * 初始化发送的文件
 * 参数:filePath，文件路径
 * 参数:extend，文件扩展名的hash值
     该方法不需要客户端调用
 */
//- (void) initData:(NSString*)filePath withExtend:(uint16_t) extend;
- (void) initData:(NSString*)filePath withExtend:(uint16_t) extend withFolder:(uint16_t) folder;


- (void) WriteDeviceName: (NSString *)NewDeviceName;
/****************************************************************************/
/*							Access to the devices							*/
/****************************************************************************/

/*
 * 搜索到的蓝牙设备，子项类型为:CBPeripheral.
 */
@property (strong, nonatomic) NSMutableArray    *foundPeripherals;

/*
 * 已经连接的服务，子项类型为:LeFileService
 */
@property (strong, nonatomic) NSMutableArray	*connectedServices;	// Array of LeTemperatureAlarmService
@end
