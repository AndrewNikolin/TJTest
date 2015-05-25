//
//  ViewController.h
//  TJTest
//
//  Created by Andrey Nikolin on 22.05.15.
//  Copyright (c) 2015 Andrey Nikolin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *SearchTable;


@end