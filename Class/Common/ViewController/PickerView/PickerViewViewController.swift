import UIKit
import AudioToolbox

extension UIAlertController {
    
    /// Add a picker view
    ///
    /// - Parameters:
    ///   - values: values for picker view
    ///   - initialSelection: initial selection of picker view
    ///   - action: action for selected value of picker view
    func addPickerView(values: PickerViewViewController.Values,  initialSelection: PickerViewViewController.Index? = nil, action: PickerViewViewController.Action?) {
        let pickerView = PickerViewViewController(values: values, initialSelection: initialSelection, action: action)
        set(vc: pickerView, height: 216)
    }
    
    /// Create new alert view controller.
    ///
    /// - Parameters:
    ///   - style: alert controller's style.
    ///   - title: alert controller's title.
    ///   - message: alert controller's message (default is nil).
    ///   - defaultActionButtonTitle: default action button title (default is "OK")
    ///   - tintColor: alert controller's tint color (default is nil)
    convenience init(style: UIAlertController.Style, source: UIView? = nil, title: String? = nil, message: String? = nil, tintColor: UIColor? = nil) {
        self.init(title: title, message: message, preferredStyle: style)
        
        // TODO: for iPad or other views
        let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
        let root = UIApplication.shared.keyWindow?.rootViewController?.view
        
        //self.responds(to: #selector(getter: popoverPresentationController))
        if let source = source {
            
            popoverPresentationController?.sourceView = source
            popoverPresentationController?.sourceRect = source.bounds
        } else if isPad, let source = root, style == .actionSheet {
            
            popoverPresentationController?.sourceView = source
            popoverPresentationController?.sourceRect = CGRect(x: source.bounds.midX, y: source.bounds.midY, width: 0, height: 0)
            //popoverPresentationController?.permittedArrowDirections = .down
            popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)
        }
        
        if let color = tintColor {
            self.view.tintColor = color
        }
    }
}


// MARK: - Methods
extension UIAlertController {
    
    /// Present alert view controller in the current view controller.
    ///
    /// - Parameters:
    ///   - animated: set true to animate presentation of alert controller (default is true).
    ///   - vibrate: set true to vibrate the device while presenting the alert (default is false).
    ///   - completion: an optional completion handler to be called after presenting alert controller (default is nil).
    public func show(animated: Bool = true, vibrate: Bool = false, style: UIBlurEffect.Style? = nil, completion: (() -> Void)? = nil) {
        
        /// TODO: change UIBlurEffectStyle
        if let style = style {
            for subview in view.allSubViewsOf(type: UIVisualEffectView.self) {
                subview.effect = UIBlurEffect(style: style)
            }
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: animated, completion: completion)
            if vibrate {
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            }
        }
    }
    
    /// Add an action to Alert
    ///
    /// - Parameters:
    ///   - title: action title
    ///   - style: action style (default is UIAlertActionStyle.default)
    ///   - isEnabled: isEnabled status for action (default is true)
    ///   - handler: optional action handler to be called when button is tapped (default is nil)
    func addAction(image: UIImage? = nil, title: String, color: UIColor? = nil, style: UIAlertAction.Style = .default, isEnabled: Bool = true, handler: ((UIAlertAction) -> Void)? = nil) {
        //let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
        //let action = UIAlertAction(title: title, style: isPad && style == .cancel ? .default : style, handler: handler)
        let action = UIAlertAction(title: title, style: style, handler: handler)
        action.isEnabled = isEnabled
        
        // button image
        if let image = image {
            action.setValue(image, forKey: "image")
        }
        
        // button title color
        if let color = color {
            action.setValue(color, forKey: "titleTextColor")
        }
        
        addAction(action)
    }
    
    /// Set alert's title, font and color
    ///
    /// - Parameters:
    ///   - title: alert title
    ///   - font: alert title font
    ///   - color: alert title color
    func set(title: String?, font: UIFont, color: UIColor) {
        if title != nil {
            self.title = title
        }
        setTitle(font: font, color: color)
    }
    
    func setTitle(font: UIFont, color: UIColor) {
        guard let title = self.title else { return }
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        let attributedTitle = NSMutableAttributedString(string: title, attributes: attributes)
        setValue(attributedTitle, forKey: "attributedTitle")
    }
    
    /// Set alert's message, font and color
    ///
    /// - Parameters:
    ///   - message: alert message
    ///   - font: alert message font
    ///   - color: alert message color
    func set(message: String?, font: UIFont, color: UIColor) {
        if message != nil {
            self.message = message
        }
        setMessage(font: font, color: color)
    }
    
    func setMessage(font: UIFont, color: UIColor) {
        guard let message = self.message else { return }
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        let attributedMessage = NSMutableAttributedString(string: message, attributes: attributes)
        setValue(attributedMessage, forKey: "attributedMessage")
    }
    
    /// Set alert's content viewController
    ///
    /// - Parameters:
    ///   - vc: ViewController
    ///   - height: height of content viewController
    func set(vc: UIViewController?, width: CGFloat? = nil, height: CGFloat? = nil) {
        guard let vc = vc else { return }
        setValue(vc, forKey: "contentViewController")
        if let height = height {
            vc.preferredContentSize.height = height
            preferredContentSize.height = height
        }
    }
}




final class PickerViewViewController: UIViewController {
    
    public typealias Values = [[String]]
    public typealias Index = (column: Int, row: Int)
    public typealias Action = (_ vc: UIViewController, _ picker: UIPickerView, _ index: Index, _ values: Values) -> ()
    
    fileprivate var action: Action?
    fileprivate var values: Values = [[]]
    fileprivate var initialSelection: Index?
    
    fileprivate lazy var pickerView: UIPickerView = {
        return $0
    }(UIPickerView())
    
    init(values: Values, initialSelection: Index? = nil, action: Action?) {
        super.init(nibName: nil, bundle: nil)
        self.values = values
        self.initialSelection = initialSelection
        self.action = action
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Slog("has deinitialized")
    }
    
    override func loadView() {
        view = pickerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = self
        pickerView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let initialSelection = initialSelection, values.count > initialSelection.column, values[initialSelection.column].count > initialSelection.row {
            pickerView.selectRow(initialSelection.row, inComponent: initialSelection.column, animated: true)
        }
    }
}

extension PickerViewViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    // returns the number of 'columns' to display.
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return values.count
    }
    
    
    // returns the # of rows in each component..
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return values[component].count
    }
    /*
     // returns width of column and height of row for each component.
     public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
     
     }
     
     public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
     
     }
     */
    
    // these methods return either a plain NSString, a NSAttributedString, or a view (e.g UILabel) to display the row for the component.
    // for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
    // If you return back a different object, the old one will be released. the view will be centered in the row rect
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return values[component][row]
    }
    /*
     public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
     // attributed title is favored if both methods are implemented
     }
     
     
     public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
     
     }
     */
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        action?(self, pickerView, Index(column: component, row: row), values)
    }
}




extension UIView {
    
    func searchVisualEffectsSubview() -> UIVisualEffectView? {
        if let visualEffectView = self as? UIVisualEffectView {
            return visualEffectView
        } else {
            for subview in subviews {
                if let found = subview.searchVisualEffectsSubview() {
                    return found
                }
            }
        }
        return nil
    }
    
    /// This is the function to get subViews of a view of a particular type
    /// https://stackoverflow.com/a/45297466/5321670
    func subViews<T : UIView>(type : T.Type) -> [T]{
        var all = [T]()
        for view in self.subviews {
            if let aView = view as? T{
                all.append(aView)
            }
        }
        return all
    }
    
    
    /// This is a function to get subViews of a particular type from view recursively. It would look recursively in all subviews and return back the subviews of the type T
    /// https://stackoverflow.com/a/45297466/5321670
    func allSubViewsOf<T : UIView>(type : T.Type) -> [T]{
        var all = [T]()
        func getSubview(view: UIView) {
            if let aView = view as? T{
                all.append(aView)
            }
            guard view.subviews.count>0 else { return }
            view.subviews.forEach{ getSubview(view: $0) }
        }
        getSubview(view: self)
        return all
    }
}

