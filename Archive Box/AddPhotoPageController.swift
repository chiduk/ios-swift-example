//
//  AddPhotoPageController.swift
//  BuxBox
//
//  Created by SongChiduk on 12/03/2019.
//  Copyright © 2019 BuxBox. All rights reserved.
//

import Foundation
import UIKit

protocol AddphotoDelegate : class {
    func goTo(pageNumber: Int, direction: UIPageViewController.NavigationDirection)
    func dismissView()
    func saveIntoFolder(sender: HistoryDataModel)
    func goBack(pageNumber: Int, direction: UIPageViewController.NavigationDirection)
}

class AddPhotoPageController : UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, AddphotoDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setupViewControllers()
        navigationController?.navigationBar.isHidden = true
    }
    
    deinit {
        print("AddPhotoPageController deinit successfull")
        pageOne = nil
        pageTwo = nil
        pageThree.folder = nil
        pageThree = nil
        
    }
    
    var saveDelegate : SaveFolderDelegate?
    
    var pageOne : TakePhotoController!
    var pageTwo : SelectAndCropViewController!
    var pageThree : ImageFolderSaveViewController!
    
    func setupViewControllers() {
        pageOne = TakePhotoController()
        pageOne.delegate = self
        
        pageTwo = SelectAndCropViewController()
        pageTwo.delegate = self
        
        pageThree = ImageFolderSaveViewController()
        pageThree.delegate = self
        
        pages.append(pageOne)
        pages.append(pageTwo)
        pages.append(pageThree)
        
        setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)

    }
    
    func goTo(pageNumber: Int, direction: UIPageViewController.NavigationDirection) {
        if pageNumber == 1 {
            pageTwo.imageArray = pageOne.imagePreviewArray
            pageTwo.photoCollectionView.reloadData()
            pageTwo.pager?.numberOfPages = pageTwo.imageArray.count
            
        } else if pageNumber == 2 {
            pageThree.imageListSet = pageTwo.imageArray
        }
        setViewControllers([pages[pageNumber]], direction: direction, animated: true, completion: nil)
    }
    
    func goBack(pageNumber: Int, direction: UIPageViewController.NavigationDirection) {
        if pageNumber == 0 {
            pageOne.imagePreviewArray = pageTwo.imageArray
            pageOne.setupPreviewImage()
        } else if pageNumber == 1 {
            pageTwo.imageArray = pageThree.imageListSet!
        }
        setViewControllers([pages[pageNumber]], direction: direction, animated: true, completion: nil)
    }
    
    func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    var pages = [UIViewController]()
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = self.pages.index(of: viewController) {
            if index == 0 {
                return nil
            } else {
                return self.pages[index - 1]
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = self.pages.index(of: viewController) {
            if index < self.pages.count - 1 {
                if index == 0 {
                    return self.pages[index + 1]
                } else if index == 1 {
                    
                } else {
                    
                }
                
                return self.pages[index + 1]
                
            } else {
                return nil
            }
        }
        
        return nil
    }
    
    func saveIntoFolder(sender: HistoryDataModel) {
        saveDelegate?.saveIntoFolder(sender: sender)
    }
}
