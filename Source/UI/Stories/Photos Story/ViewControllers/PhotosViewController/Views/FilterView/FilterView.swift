//
//  FilterView.swift
//  MyMobileED
//
//  Created by Admin on 1/23/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

class FilterView: PopUpView, UITableViewDelegate, UITableViewDataSource {
    
    var selectRowCallback: ((PhotosFilterDate) -> Void)?
    var selectedRow: Int = -1
    var clearFilterCallback: (() -> (Void))?
    var closeCallback: (() -> (Void))?
    var filters: [PhotosFilterDate] = [PhotosFilterDate.yesterday,
                                       PhotosFilterDate.week,
                                       PhotosFilterDate.month,
                                       PhotosFilterDate.custom]
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonClearFilter: UIButton!

    class func viewHeight() -> CGFloat {
        return 284.0
    }
    
    override func height() -> CGFloat {
        return FilterView.viewHeight()
    }
    
    override func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "FilterView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    @IBAction func buttonClearFilterTapped(_ sender: UIButton) {
        selectedRow = -1
        tableView.reloadData()
        buttonClearFilter.isEnabled = false
        
        if let validCallback = selectRowCallback {
            validCallback(PhotosFilterDate.none)
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        if let validCloseCallback = closeCallback {
            validCloseCallback()
        }
    }
    
    func setupViewState(withFilter filter: PhotosFilterDate) {
        if let selectedRow = filters.index(of: filter) {
            self.selectedRow = selectedRow
            buttonClearFilter.isEnabled = true
            tableView.reloadData()
        }
    }
    
    // MARK: UITableViewDelegate & UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.textLabel?.text = filters[indexPath.row].title
        cell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 14)
        
        if indexPath.row == selectedRow {
            cell.textLabel?.textColor = BaseColors.darkBlue.color()
        } else {
            cell.textLabel?.textColor = BaseColors.deviceGray.color()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        selectedRow = index
        tableView.reloadData()
        
        let filter = filters[index]
        self.buttonClearFilter.isEnabled = true
        
        if let validCallback = selectRowCallback {
            validCallback(filter)
        }
    }

}
