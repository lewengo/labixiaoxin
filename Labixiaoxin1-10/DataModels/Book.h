//
//  Book.h
//  Labixiaoxin1-5
//
//  Created by 晋辉 卫 on 5/5/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Book : NSObject <NSCoding>
@property (strong, nonatomic) NSString *bookId;
@property (strong, nonatomic) NSString *bookName;
@property (strong, nonatomic) NSString *bookUrl;
@property (strong, nonatomic) NSString *bookIcon;
@property (strong, nonatomic) NSString *bookPrice;
@property (strong, nonatomic) NSString *publishTime;
@property (assign, nonatomic) BOOL isNew;
@end
