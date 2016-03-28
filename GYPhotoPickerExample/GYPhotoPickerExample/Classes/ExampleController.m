//
//  ExampleController.m
//  GYPhotoPickerExample
//
//  Created by 高言 on 16/3/28.
//  Copyright © 2016年 高言. All rights reserved.
//

#import "ExampleController.h"
#import "SingleSelectDemo.h"
#import "MultiSelectDemo.h"
#import "CustomCameraDemo.h"

@implementation ExampleController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"单选";
            break;
        case 1:
            cell.textLabel.text = @"多选";
            break;
        case 2:
            cell.textLabel.text = @"自定义相机";
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            [self.navigationController pushViewController:[[SingleSelectDemo alloc] init] animated:YES];
            break;
            
        case 1:
            [self.navigationController pushViewController:[[MultiSelectDemo alloc] init] animated:YES];
            break;
            
        case 2:
            [self.navigationController pushViewController:[[CustomCameraDemo alloc] init] animated:YES];
            break;
            
        default:
            break;
    }
}

@end
