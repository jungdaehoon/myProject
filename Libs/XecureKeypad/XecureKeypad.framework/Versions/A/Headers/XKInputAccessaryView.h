//
//  XKInputAccessaryView.h
//  XecureKeypad
//
//  Created by Myungji on 2013. 11. 12..
//  Copyright (c) 2013년 softforum. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XKInputAccessaryViewDelegate
@required

- (void) movePreviousTextField:(id)sender;

- (void) moveNextTextField:(id)sender;

- (void) cancelTextField:(id)sender;

@end

@interface XKInputAccessaryView : UIView

@property (nonatomic, retain)   id  returnDelegate;
@property (nonatomic, retain)   UITextField * parentTextField;

@property (nonatomic, retain)   IBOutlet UILabel * timeOutLabel;

@property (nonatomic, retain)   IBOutlet UIButton * prevButton;
@property (nonatomic, retain)   IBOutlet UIButton * nextButton;
@property (nonatomic, retain)   IBOutlet UIButton * cancelButton;

+ (id) allocWithNib;

- (void) drawLastCharacter:(id) sender
                     image:(UIImageView *) imageView;

- (void) drawLastCharacter:(id) sender
                     image:(UIImageView *) imageView
                 magnifier:(UIImageView *) magnifierImageView;

- (void) showSessionTimeOut:(id) sender
                    timeout:(NSInteger) timeout
                 xkLanguage:(NSInteger) xkLanguage;

- (void) setCancelButtonSetHidden;

- (void)setAccessaryViewVisibility;

@end
