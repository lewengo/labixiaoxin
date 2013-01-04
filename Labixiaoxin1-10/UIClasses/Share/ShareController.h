//
//  ShareController.h
//  ComicLover
//
//  Created by Levin on 11/9/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    ComicShareTypeComic = 0,
    ComicShareTypeVolum = 1
} ComicShareType;

@interface ShareController : UIViewController <UITextViewDelegate,
                                                UITableViewDelegate,
                                                UITableViewDataSource>
{
    UIView *_thePromptView;
    NSString *_controllerId;
    
    UITextView *detailField;
    UILabel *charCountLabel;
    
    BOOL _edited;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) ComicShareType shareType;
@property (nonatomic, strong) NSString *comicName;
@property (nonatomic,  strong) NSString *volumName;

@property (nonatomic, assign) id backTarget;
@property (nonatomic, assign) SEL backSelector;
@end
