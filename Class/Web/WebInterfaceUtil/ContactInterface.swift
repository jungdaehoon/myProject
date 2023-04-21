//
//  ContactInterface.swift
//  cereal
//
//  Created by srkang on 2018. 7. 4..
//  Copyright © 2018년 srkang. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import AddressBook
import AddressBookUI

class ContactInterface : NSObject {
    
    static let COMMAND_GET_CONTACT_INFO = "getContactInfo" // 주소록 띄워서, 선택한 사용자명,전화번호 가져오기
    
    weak var viewController : UIViewController!
    var command : Command!
    var resultCallback : ResultCallback!
    
    init(viewController: UIViewController, command: Command, result: @escaping (HybridResult) -> ()) {
        super.init()
        self.command(viewController: viewController, command: command, result: result)
    }
    
    deinit {
        //log?.debug("ContactInterface")
    }
}

extension ContactInterface :  HybridInterface {
    
    func command(viewController: UIViewController, command: Command, result: @escaping (HybridResult) -> ()) {
        
        self.viewController = viewController
        self.command = command
        self.resultCallback = result
        
        /*
        let status = CNContactStore.authorizationStatus(for: .contacts)

        switch status {
        case .authorized:
            return completion(.authorized)
        case .restricted, .denied:
            return completion(.unauthorized)
        case .notDetermined:
            return completion(.unknown)
        }
        
        if let permissionScope = ApplicationShare.shared.permissionInfo.permissionScope {
            
            permissionScope.statusContacts(completion: { (status) in
                permissionScope.onAuthChange = { (allSuccess, permissionResults ) in
                    //log?.debug("ContactInterface onAuthChange called-1")
                }
                
                if status == .unknown {
                    // 권한요청 한 적이 없으면, 주소록 접근 권한 요청한다.
                    permissionScope.requestPermission(type: .contacts, permissionResult: { (finished, permissionResult,error) in
                        
                        if error == nil && permissionResult?.status == .authorized {
                            self.showContact()
                        } else if permissionResult?.status == .unauthorized {
                            permissionScope.showDeniedAlert(viewController: viewController, permission: .contacts)
                        }
                        
                    })
                } else if status == .authorized {
                     // 권한요청이 승인 됐으면, 주소창을 띄운다.
                    self.showContact()
                } else if status == .unauthorized {
                    // 권한요청이 거절 됐으면, 사용하기 위해서 , 주소록 승인 해야 한다는 Alert 을 보여준아.
                    permissionScope.showDeniedAlert(viewController: viewController, permission: .contacts)
                }
            })
        }
         */
        
    }
    
    func showContact() {
        
        // iOS9 이상 부터는 주소록을 CNContact 프레임워크를 사용한다.
        if #available(iOS 9, *) {
            let picker = CNContactPickerViewController()
            picker.delegate = self
            do {
                picker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
                // 폰 넘버가 0 개 이상만 선택가능하도록, 0 개 이면 선택 불가
                picker.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count > 0 ")
            }


            self.viewController.present(picker, animated:true)
        } else {
            // iOS9 이하는 주소록을 AddressBook 프레임워크를 사용한다.
            let picker = ABPeoplePickerNavigationController()
            picker.peoplePickerDelegate = self
            picker.displayedProperties = [kABPersonPhoneProperty] as [NSNumber]
            // 폰 넘버가 0 개 이상만 선택가능하도록, 0 개 이면 선택 불가
            picker.predicateForEnablingPerson = NSPredicate(format: "phoneNumbers.@count > 0 ")
            self.viewController.present(picker, animated:true)
        }
        
    }

    
}


extension ContactInterface  {
    
    @available(iOS 9, *)
    // iOS9 이상.  사용자명을 CNContact 의  property 속성 조합으로
    func conactName(contact: CNContact ) -> String {
        
        var contactName : String = ""
        
        if contact.familyName.count > 0  {
            contactName += contact.familyName
        }
        
        if contact.middleName.count > 0  {
            contactName += contact.middleName
        }
        
        if contact.givenName.count > 0{
            contactName += contact.givenName
        }
        
        return contactName
    }
    // iOS8 이하  사용자명을 AddressBook.ABRecord 의  property 속성 조합으로
    func conactName(person: AddressBook.ABRecord ) -> String {
        
        var contactName : String = ""
        
        if let  lastName  = ABRecordCopyValue(person, kABPersonLastNameProperty).takeRetainedValue() as? String {
            contactName += lastName
        }
        
        if let   middleName = ABRecordCopyValue(person, kABPersonMiddleNameProperty).takeRetainedValue() as? String {
            contactName += middleName
        }
        
        if let firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty).takeRetainedValue() as? String {
            contactName += firstName
        }
        
        return contactName
    }
    
    
}

//iOS9 이상은 연락체 Picker 의 delegate 를 CNContactPickerDelegate
@available(iOS 9, *)
extension ContactInterface : CNContactPickerDelegate {
    // 취소 했을때
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        //log?.debug("contactPickerDidCancel called ")
    }
    
    // 연락처를 선택했을때
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        //log?.debug("contact : \(contact) ")
        //log?.debug("contact.phoneNumbers : \(contact.phoneNumbers) ")
        
        // 연락처의 전화번호가 1개 인 경우, 바로 Hybrid callback 리턴
        if contact.phoneNumbers.count == 1 {
            let phoneNumber = contact.phoneNumbers.first
            //log?.debug("phoneNumber:\(phoneNumber)")
            
            let contactName = conactName(contact: contact)
            let phoneString = phoneNumber?.value.stringValue
            
            resultCallback(HybridResult.success(message: [contactName, phoneString]))
            
        } else {
            // 연락처의 전화번호가 2개 이상인 경우, 전화번호를 선택하기 위해서 CNContactViewController 를 뛰운다.
            let aContact = CNMutableContact()
            
            for   phoneNumber in contact.phoneNumbers {
                let newPhone = CNLabeledValue(label: CNLabelHome, value: phoneNumber.value )
                aContact.phoneNumbers.append(newPhone)
            }
            let contactStore = CNContactStore()
            
            var contactAfter = contact

            if !contact.areKeysAvailable([CNContactViewController.descriptorForRequiredKeys()]) {
                do {
                    contactAfter = try contactStore.unifiedContact(withIdentifier: contact.identifier, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
                }
                catch { }
            }
            
            let contactVC = CNContactViewController(for: contactAfter)
            contactVC.displayedPropertyKeys = [CNContactPhoneNumbersKey]
            contactVC.delegate = self
            contactVC.allowsEditing = false
            contactVC.allowsActions = false
            contactVC.contactStore = contactStore
            self.viewController.navigationController?.pushViewController(contactVC, animated: false)
        }
    }
    
    // 연락처의 Property 를 선택한 경우.
    public func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
         //log?.debug("contact : \(contactProperty) ")
    }
}


//iOS9 이상
// 전화번호가 2개 이상일 때, CNContactPickerViewController 를 띄웠고,
// 선택한 전화 번호를 처리 하기 위한 delegate
@available(iOS 9, *)
extension ContactInterface : CNContactViewControllerDelegate {
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        //log?.debug("didCompleteWith : \(contact as Any)")
        viewController.dismiss(animated: true) // n
    }
    
    // 전화번호를 선택 했을 경우 Hybrid 에 콜백한다.
    func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
        
        let contact = property.contact
        let contactName = conactName(contact: contact)
        let phoneString = (property.value as! CNPhoneNumber).stringValue
        
        resultCallback(HybridResult.success(message: [contactName, phoneString]))
        
        viewController.navigationController?.popViewController(animated: false)
        
        return false
    }
}


// iOS8 이하
extension ContactInterface : ABPeoplePickerNavigationControllerDelegate {
    
    
    public func peoplePickerNavigationController(_ peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: AddressBook.ABRecord) {
        //log?.debug("peoplePickerNavigationController-1 called")
        
        if let phoneNumbers: ABMultiValue = ABRecordCopyValue(person, kABPersonPhoneProperty)?.takeRetainedValue() {
           
            // 전화번호가 1개 인 경우, 바로 Hybrid callback 리턴
            if ABMultiValueGetCount(phoneNumbers)  == 1 {
                
                let contactName = conactName(person: person)
                let phoneString = ABMultiValueCopyValueAtIndex(phoneNumbers, 0)?.takeRetainedValue() as? String
                
                resultCallback(HybridResult.success(message: [contactName, phoneString]))
                
            }  else {
                 // 연락처의 전화번호가 2개 이상인 경우, 전화번호를 선택하기 위해서 ABPersonViewController 를 뛰운다.
                var error: Unmanaged<CFError>?
                guard let addressBook: ABAddressBook? = ABAddressBookCreateWithOptions(nil, &error)?.takeRetainedValue() else {
                    //log?.debug(String(describing: error?.takeRetainedValue()))
                    return
                }
                
                let persionViewController = ABPersonViewController()
                persionViewController.addressBook = addressBook
                persionViewController.displayedPerson = person
                persionViewController.personViewDelegate = self;
                persionViewController.allowsEditing = false
                persionViewController.allowsActions = false
                persionViewController.displayedProperties = [kABPersonPhoneProperty] as [NSNumber]
                self.viewController.navigationController?.pushViewController(persionViewController, animated: false)
            }
           
        }
    }
    
    
    //  연락처의 속성을 선택한 경우
     public func peoplePickerNavigationController(_ peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: AddressBook.ABRecord, property: ABPropertyID, identifier: ABMultiValueIdentifier) {
        //log?.debug("peoplePickerNavigationController-2 called")
    }
    
    
    // 연락처 선택 없이 닫을 경우
    public func peoplePickerNavigationControllerDidCancel(_ peoplePicker: ABPeoplePickerNavigationController) {
        //log?.debug("peoplePickerNavigationController-3 called")
    }
    
}

//iOS8 이하
// 전화번호가 2개 이상일 때, ABPersonViewController 를 띄웠고,
// 선택한 전화 번호를 처리 하기 위한 delegate
extension ContactInterface : ABPersonViewControllerDelegate {
    
    func personViewController(_ personViewController: ABPersonViewController, shouldPerformDefaultActionForPerson person: AddressBook.ABRecord, property: ABPropertyID, identifier: ABMultiValueIdentifier) -> Bool {
        
        let contactName = conactName(person: person)
        
        // 앞에서 이미 displayedProperties 를 전화번호로 했기 때문에 property 는 kABPersonPhoneProperty 일 수 밖에 없다.
//        if property != kABPersonPhoneProperty {
//            return
//        }
        
        
        let phones:ABMultiValue = ABRecordCopyValue(person, property).takeRetainedValue()
        let index = ABMultiValueGetIndexForIdentifier(phones, identifier)
        let phoneString = ABMultiValueCopyValueAtIndex(phones, index).takeRetainedValue() as! String
        
        
        resultCallback(HybridResult.success(message: [contactName, phoneString]))
        
        
        viewController.navigationController?.popViewController(animated: false)
        
        return false
    }
}

