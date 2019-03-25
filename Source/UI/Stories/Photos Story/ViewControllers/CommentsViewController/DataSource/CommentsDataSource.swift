//
//  CommentsDataSource.swift
//  MyMobileED
//
//  Created by Maks Ovcharuk on 10/18/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

protocol CommentsDataSourceDelegate: class {
    func commentsDataSource(_ sender: CommentsDataSourceProtocol, isEmptyComments isEmpty: Bool)
    func commentsDataSource(_ sender: CommentsDataSourceProtocol, selectedComments: [Comment])
    func commentsDataSource(_ sender: CommentsDataSourceProtocol, canDeleteComments canDelete: Bool)
    func commentsDataSourceWillBeginScrolling(_ sender: CommentsDataSourceProtocol)
    func commentsDataSource(_ sender: CommentsDataSourceProtocol, didSelectLinkWith url: URL)
}

class CommentsDataSource: NSObject, CommentsDataSourceProtocol, UITableViewDelegate, UITableViewDataSource, CommentTableViewCellDelegate {
    
    private let estimatedRowHeight: CGFloat = 150.0
    
    weak var delegate: CommentsDataSourceDelegate?
    var tableView: UITableView
    var networkManager: CommentsNetworkProtocol?
    var photo: Photo?
    
    private var comments: [Comment] = []
    private var viewModels: [CommentViewModel] = []
    private var paginationQuery: CommentsPaginationQuery = CommentsPaginationQuery()
    private var commentsRequest: NetworkRequest?
    
    init(tableView: UITableView, networkManager: CommentsNetworkProtocol?, delegate: CommentsDataSourceDelegate, photo: Photo?) {
        self.tableView = tableView
        self.networkManager = networkManager
        self.delegate = delegate
        self.photo = photo
        
        super.init()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        configureTableView()
    }
    
    func reloadContent() {
        commentsRequest?.dataRequest?.cancel()
        
        viewModels.removeAll()
        comments.removeAll()
        
        paginationQuery.nodeID = photo?.nodeID
        paginationQuery.page = 0

        commentsRequest = networkManager?.getComments(withQuery: paginationQuery, successBlock: { (response) -> (Void) in
            let commentLoadingResponse = response.object as! CommentLoadingPageResponse
            let canDeleteComments = commentLoadingResponse.canDeleteComments
            self.paginationQuery.limit = commentLoadingResponse.limit
            
            let comments = commentLoadingResponse.comments
            self.comments = comments
            self.setupViewModels(forComments: comments)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.scrollToLastRow()
            }
            
            let isEmpty = (comments.count == 0)
            self.delegate?.commentsDataSource(self, isEmptyComments: isEmpty)
            self.delegate?.commentsDataSource(self, canDeleteComments: canDeleteComments)
            
            self.commentsRequest = nil
        }, failureBlock: { (error) -> (Void) in
            self.commentsRequest = nil
        })
    }
    
    // MARK: - CommentsDataSourceProtocol
    
    func setEditing(editing: Bool, animated: Bool) {
        tableView.allowsSelection = editing
        tableView.allowsMultipleSelectionDuringEditing = editing
        tableView.setEditing(editing, animated: animated)
    }
    
    func selectedComments() -> [Comment] {
        guard viewModels.count > 0 else { return [] }
        
        var selectedComments: [Comment] = []
        
        for index in 0..<viewModels.count {
            if viewModels[index].isSelected { selectedComments.append(comments[index]) }
        }

        return selectedComments
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setupSelectedState(forCommentIndex: indexPath.row, isSelected: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        setupSelectedState(forCommentIndex: indexPath.row, isSelected: false)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if paginationQuery.page >= (paginationQuery.limit - 1) {
            return
        }

        if indexPath.row == 0 {
            paginationQuery.nextPage()
            
            commentsRequest = networkManager?.getComments(withQuery: paginationQuery, successBlock: { (response) -> (Void) in
                let commentLoadingResponse = response.object as! CommentLoadingPageResponse
                self.paginationQuery.limit = commentLoadingResponse.limit

                let comments = commentLoadingResponse.comments
                self.comments.append(contentsOf: comments)
                self.setupViewModels(forComments: comments)

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    
                    let indexPath = IndexPath(row: comments.count, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                }
                self.commentsRequest = nil
            }, failureBlock: { (error) -> (Void) in
                self.commentsRequest = nil
            })
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.commentsDataSourceWillBeginScrolling(self)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = (viewModels.count - indexPath.row - 1)
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell") as! CommentTableViewCell
        cell.configureCell(withViewModel: viewModels[index])
        cell.delegate = self
        
        if viewModels[index].isSelected {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
        
        return cell
    }
    
    // MARK: - CommentTableViewCellDelegate
    func commentTableViewCell(_ cell: CommentTableViewCell, didSelectLinkWith url: URL) {
       
        guard let requiredDelegate = self.delegate else { return }
        requiredDelegate.commentsDataSource(self, didSelectLinkWith: url)
    }

    // MARK: - Private
    
    private func convertToViewModel(_ comment: Comment) -> CommentViewModel {
        let dateFromTS = Date(timeIntervalSince1970: Double(comment.createdDate!)!)
        let formattedTimestamp = DateHelper.formattedStringDateForComment(fromDate: dateFromTS)
        let commentViewModel = CommentViewModel(username: comment.username,
                                                timestamp: formattedTimestamp,
                                                comment: comment.comment,
                                                isSelected: false)
        
        return commentViewModel
    }
        
    private func configureTableView() {
        tableView.estimatedRowHeight = estimatedRowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(UINib.init(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentTableViewCell")
        tableView.tableFooterView = UIView()
    }
    
    private func setupViewModels(forComments comments: [Comment]) {
        comments.forEach({ (comment) in
            let viewModel = self.convertToViewModel(comment)
            self.viewModels.append(viewModel)
        })
    }
    
    private func setupSelectedState(forCommentIndex index: Int, isSelected: Bool) {
        let index = (comments.count - index - 1)
        viewModels[index].isSelected = isSelected
        delegate?.commentsDataSource(self, selectedComments: selectedComments())
    }
    
    private func scrollToLastRow() {
        guard comments.count > 0 else { return }
        
        let indexPath = IndexPath(row: comments.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }

}
