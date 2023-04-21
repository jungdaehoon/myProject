//
//  XKTextFieldCollection.h
//  XecureKeypad
//
//  Created by Myungji on 2013. 11. 11..
//  Copyright (c) 2013년 softforum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XKTextField.h"
#import "XKInputAccessaryView.h"

@interface XKTextFieldCollection : NSObject <UITextFieldDelegate,
                                             XKTextFieldDelegate,
                                             XKInputAccessaryViewDelegate>

- (NSInteger) addTextField:(id)aTextField;

- (id) getTextFieldAtIndex:(NSInteger) aIndex;

@end
