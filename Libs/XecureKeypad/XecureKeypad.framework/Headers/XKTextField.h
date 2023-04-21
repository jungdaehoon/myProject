//
//  XKTextField.h
//  CustomViewTest
//
//  Created by maeng on 13. 7. 25..
//  Copyright (c) 2013년 softforum. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, XKeypadViewType)
{
	XKeypadViewTypeNormalView = 0,			 // 0 : 일반 키패드 뷰 타입
	XKeypadViewTypeFullView,                 // 1 : 전체화면 타입
    XKeypadViewTypeFullViewCustom,           // 2 : 전체화면 custom 타입
    XKeypadViewTypeViewCustom                // 3 : 일반 키패드 뷰 Custom 타입
};

typedef NS_ENUM (NSInteger, XKeypadType)
{
	XKeypadTypeNumber = 0,				// 0 : 숫자 키패드
	XKeypadTypeQwerty,					// 1 : 쿼티 키패드
	XKeypadTypeLetter,					// 2 : 문자 키패드
	XKeypadTypeUpperLetter,				// 3 : 문자 키패드 (대문자)
	XKeypadTypeLowerLetter,				// 4 : 문자 키패드 (소문자)
    XKeypadTypeNumberRandom             // 5 : 랜덤 숫자 키패드
};

typedef NS_ENUM (NSInteger, XKeypadPreViewType)
{
    XKeypadPreViewOn = 0,            // 0 : 가이드뷰 켜짐
    XKeypadPreViewOff                // 1 : 가이드뷰 꺼짐
};

typedef NS_ENUM (NSInteger, XKeypadLangType)
{
    XKeypadLnagNon = 0,            // 0 : None
    XKeypadLangKor,                // 1 : Korean
    XKeypadLangEng                 // 2 : English
};

// 키패드를 모듈 내부에서 직접 화면에 표시할지 여부 설정
// 설정하지 않는 경우 기본값은 XKeypadAutoLoading 이다.
typedef NS_ENUM(NSInteger, XKeypadLoadingOption)
{
    XKeypadAutoLoading = 0,         // 키패드 내부 자동 로딩하여 표시.
    XKeypadManualLoading,           // 키패드 직접 로딩. 키패드 생성 후 화면에 표시하지 않음. (설정 시 직접 view 처리)
};

@class XKTextField;

@protocol XKTextFieldDelegate
@optional
- (void) keypadInputCompleted:(NSInteger)aCount;

- (void) keypadInputCompleted:(XKTextField *) textField
						count:(NSInteger) count;

- (void) keypadE2EInputCompleted:(NSString *)aSessionID
                           token:(NSString *)aToken
                      indexCount:(NSInteger)aCount;

- (void) keypadE2EInputCompleted:(XKTextField *) textField
					   sessionID:(NSString *) sessionID
						   token:(NSString *) token
					  indexCount:(NSInteger) count;

- (void) keypadCanceled;

- (BOOL) getXKPreViewCancleButtonHidden;

- (void) keypadCreateFailed:(NSInteger) errorCode;
//youngmoon.nah 20180828 add
- (void) keypadCreateStart;
- (void) keypadCreateCompleted;
- (void) keypadCreateStartWithTag:(NSInteger) tag;
- (void) keypadCreateCompletedWithTag:(NSInteger) tag;
- (void) keypadDestroyStartWithTag:(NSInteger) tag;
- (void) keypadDestroyCompletedWithTag:(NSInteger) tag;

- (BOOL)textField:(XKTextField *)textField shouldChangeLength:(NSUInteger)length;
- (BOOL)textFieldShouldDeleteCharacter:(XKTextField *)textField;
- (void)textFieldSessionTimeOut:(XKTextField *)textField;

//normal view dim turch event
- (void) touchSingleTap:(UITapGestureRecognizer *)recognizer;
@end

@interface XKTextField : UITextField <UITextFieldDelegate, XKTextFieldDelegate>

@property (nonatomic, retain) id                    returnDelegate;
@property (nonatomic, assign) XKeypadViewType	    xkeypadViewType;
@property (nonatomic, assign) XKeypadType           xkeypadType;
@property (nonatomic, assign) XKeypadLangType       xkeypadLangType;
@property (nonatomic, assign) XKeypadPreViewType    xkeypadPreViewType;
@property (nonatomic, assign) XKeypadLoadingOption  xkeypadLoadingOption;
@property (nonatomic, retain) NSString *            e2eURL;
@property (nonatomic, retain) NSNumber *            keypadID;
@property (nonatomic, retain) NSString *            subTitle;
@property (nonatomic, retain) NSString *            editTextHint;
@property (nonatomic, retain) NSString *            maskString;
@property (nonatomic, retain) NSString *            isKeypadAnimation;
@property (nonatomic, assign) BOOL                  isFromFullView;
@property (nonatomic, assign) BOOL				    returnCompletedTextField;
@property (nonatomic, assign) BOOL                  xkPreViewCancleButtonHidden;

//youngmoon.nah Normal view set
@property (nonatomic, assign) CGFloat               xkDimAlpha;

//youngmoon.nah 20180822 user requested
@property (nonatomic, assign) NSInteger             xkInputMaxLength;


- (void) startKeypadWithSender:(UIViewController *)sender;
- (void) cancelKeypad;
- (void) completedKeypad;

//youngmoon.nah 20180822 user requested
- (void) setCustomNaviBar:(UIBarButtonItem *)barBttonItem
                 barTitle:(NSString *)barTitle;

- (void) setBackgroundImage:(UIImage *)backgroundImage
                      alpha:(CGFloat)alpha;

- (void) setXKBackgroundColor:(UIColor *)xkBackgroundColor;

- (void) setBlankLogoImage:(UIImage *)blankLogoImage;

- (void) setUseInputButton:(BOOL)flag;

- (void) setCustomFullView:(UIViewController *)customFullView;

- (const char *) getData;
- (Byte *) getDataByte;
- (NSString *) getDataE2E;
//youngmoon.nah
- (NSString *) getSessionIDE2E;
- (NSString *) getTokenE2E;
- (NSUInteger) getSessionTimeE2E;

- (NSString *) getEncryptedDataWithKey:(NSData *) key;

- (NSString *) getExternalEncryptedDataWithKeypadVendor:(NSString *) keypadVendor
                                                    Key:(NSData *) key;

- (UIView *) getKeypadView;

- (CGRect) calulateKeypadRect:(UIInterfaceOrientation) orientation;

- (void)drawKeypadWithRect:(CGRect) rect;
@end
