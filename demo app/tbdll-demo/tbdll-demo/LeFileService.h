

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class LeFileService;

/**
 *  File service protocol
 */
@protocol LeFileServiceProtocol<NSObject>

/**
 *  Delegate method invoked when a successful connection happened
 *
 *  @param service the currently connected peripheral device
 */
-(void) fileServiceDidConnected:(LeFileService*)service;

/**
 *  Delegate method invoked when disconnection occurs
 *
 *  @param service the currently active peripheral
 */
-(void) fileServiceDisConnected:(LeFileService*)service;

/**
 *  Delegate method invoked when sending of data is complete
 *
 *  @param service currently connected peripheral
 *  @param success return YES/NO
 */
-(void) fileService:(LeFileService*)service didSendFileSuccess:(BOOL)success;

/**
 *  Error
 *
 *  @param service   currently connected peripheral
 *  @param errorCode error description
 */
-(void) fileService:(LeFileService*)service refuseWithErrorCode:(uint16_t)errorCode;


/**
 *  Delegate method invoked everytime a stream is sent over to the device
 *
 *  @param service   currently connected peripheral device
 *  @param sentBytes byte size being seing
 */
-(void) fileService:(LeFileService*)service progressUpdate:(NSInteger)sentBytes;

/**
 *  reset
 */
-(void) fileServiceDidReset;

/**
 *  unknown
 *
 *  @param mfd    unknown
 *  @param extend unknown
 */
-(void) armFileToIos:(NSMutableData*) mfd withExtend:(uint16_t)extend;

/**
 *  Delegate method invoked when there is a button event from the inkCase
 */
-(void) fileServiceDidPush;
@end


/**
 *  Custom object for file service
 */
@interface LeFileService : NSObject

/**
 *  Send file over to inkCase
 *
 *  @param filePath path of the file to be sent
 *  @param extend 0xc064
 *  @param folder 0x01
 *  @return NSInteger file size
 */
//-(NSInteger) sendFileWithPath:(NSString*)filePath withExtend:(uint16_t)extend;
-(NSInteger) sendFileWithPath:(NSString*)filePath withExtend:(uint16_t) extend withFolder:(uint16_t) folder;

/**
 *  The peripheral
 */
@property (nonatomic,strong) CBPeripheral *peripheral;

/**
 *  File size
 */
@property (nonatomic,assign) NSInteger currentFileSize;

/**
 *  current byte size being sent
 */
@property (nonatomic,assign) NSInteger sentBytes;

@end
