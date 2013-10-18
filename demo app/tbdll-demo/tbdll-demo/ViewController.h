//
//  ConnectViewController.h
//  inkcasephoto
//
//  Created by diffy on 12/7/13.
//  Copyright (c) 2013 Gajah Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeDiscovery.h"

/**
 *  main view controller for making connection to peripheral
 */
@interface ViewController : UIViewController<LeDiscoveryDelegate,LeFileServiceProtocol,UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *servicearr;
    int connect;
    CBPeripheral* ap;
    LeFileService *lefs;
    NSMutableArray *a1data;
}

@property (retain, nonatomic) IBOutlet UITableView *sensorsTable;
@property (strong, nonatomic) IBOutlet UIProgressView *progress;
@property (retain, nonatomic) IBOutlet UILabel *label;
@property (nonatomic) BOOL isAutoConnect;




-(void)initConnect;


@end