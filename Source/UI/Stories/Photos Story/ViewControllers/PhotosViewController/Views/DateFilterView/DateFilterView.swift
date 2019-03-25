//
//  DatePickerView.swift
//  MyMobileED
//
//  Created by Admin on 1/31/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

class DateFilterView: PopUpView {

    @IBOutlet weak var startDateTextField: DateTextField!
    @IBOutlet weak var endDateTextField: DateTextField!
    @IBOutlet weak var buttonDone: UIButton!
    
    var cancelButtonTapCallback: (() -> (Void))?
    var doneButtonTapCallback: ((_ startDate: Date, _ endDate: Date) -> (Void))?
    
    private var picker: UIDatePicker?
    private var pickerToolbar: UIToolbar?
    private var startDate: Date?
    private var endDate: Date?
    
    class func viewHeight() -> CGFloat {
        return 260.0
    }
    
    override func height() -> CGFloat {
        return DateFilterView.viewHeight()
    }

    override func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "DateFilterView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        setupTextFieldsInputView()
        setupDisabledButtonState()
        
        return view
    }

    private func setupTextFieldsInputView() {
        setupDatePicker()
        
        startDateTextField.inputView = picker
        startDateTextField.inputAccessoryView = pickerToolbar
        endDateTextField.inputView = picker
        endDateTextField.inputAccessoryView = pickerToolbar
    }
    
    private func setupDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.backgroundColor = BaseColors.pickerGray.color()
        self.picker = datePicker
        
        setupToolbarPicker()
    }
    
    private func setupToolbarPicker() {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.backgroundColor = BaseColors.pickerGray.color()
        toolBar.sizeToFit()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(didSelectDate(_:)))
        doneButton.tintColor = UIColor.black
        toolBar.setItems([spaceButton, doneButton], animated: false)
        
        self.pickerToolbar = toolBar
    }
    
    func setupStartDate(_ startDate: Date, endDate: Date) {
        setupStartDate(startDate)
        setupEndDate(endDate)
        
        if startDateTextField.text!.count > 0 && endDateTextField.text!.count > 0 {
            setupEnabledButtonState()
        }
    }
    
    private func setupStartDate(_ date: Date) {
        startDateTextField.text = "Start date: " + DateHelper.stringFilterDateFrom(date)
        self.startDate = date
    }
    
    private func setupEndDate(_ date: Date) {
        endDateTextField.text = "End date: " + DateHelper.stringFilterDateFrom(date)
        self.endDate = date
    }
    
    func didSelectDate(_ barItem: UIBarButtonItem) {
        let calendar = Calendar.current
        let pickerDate = picker?.date
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: pickerDate!)
        let date = calendar.date(from: dateComponents)
        
        if startDateTextField.resignFirstResponder() {
            startDate = date!
            setupStartDate(date!)
            picker?.minimumDate = date!
            
            if let end = endDate {
                if end < startDate! {
                    endDateTextField.text = ""
                }
            }
        } else {
            setupEndDate(date!)
            endDate = date!
            picker?.maximumDate = date!
            endDateTextField.resignFirstResponder()
            
            if let start = startDate {
                if start > endDate! {
                    startDateTextField.text = ""
                }
            }
        }
        
        if startDateTextField.text!.count > 0 && endDateTextField.text!.count > 0 {
            setupEnabledButtonState()
        } else {
            setupDisabledButtonState()
        }
    }
    
    private func setupDisabledButtonState() {
        buttonDone.alpha = 0.3
        buttonDone.isEnabled = false
    }
    
    private func setupEnabledButtonState() {
        buttonDone.alpha = 1.0
        buttonDone.isEnabled = true
    }
    
    // MARK: Actions
    
    @IBAction func buttonCancelTapped(_ sender: Any) {
        if let validCancelCallback = cancelButtonTapCallback {
            validCancelCallback()
        }
    }
    
    @IBAction func buttonDoneTapped(_ sender: Any) {
        if let validDoneCallback = doneButtonTapCallback {
            validDoneCallback(startDate!, endDate!)
        }        
    }
    
}
