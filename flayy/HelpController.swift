//
//  HelpController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/7/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class HelpController: UIPageViewController {
    
    weak var helpDelegate: HelpViewControllerDelegate?
    
    fileprivate(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.HelpViewController("1"),
                self.HelpViewController("2"),
                self.HelpViewController("3"),
                self.HelpViewController("4")]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let primerapagina = orderedViewControllers.first{
            scrollToViewController(primerapagina)
        }
        
        helpDelegate?.helpPageViewController(self, didUpdatePageCount: orderedViewControllers.count)
    }
    
    func scrollToNext() {
        if let visibleViewController = viewControllers?.first,
            let nextView = pageViewController(self,
            viewControllerAfter: visibleViewController) {
            scrollToViewController(nextView)
        }
    }
    
    func scrollToViewController(index newIndex: Int) {
        if let firstViewController = viewControllers?.first,
            let currentIndex = orderedViewControllers.index(of: firstViewController) {
            let direction: UIPageViewControllerNavigationDirection = newIndex >= currentIndex ? .forward : .reverse
            let nextViewController = orderedViewControllers[newIndex]
            scrollToViewController(nextViewController, direction: direction)
        }
    }
    
    fileprivate func HelpViewController(_ page: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Ayuda\(page)")
    }
    
    fileprivate func scrollToViewController(_ viewController: UIViewController, direction: UIPageViewControllerNavigationDirection = .forward){
        setViewControllers([viewController], direction: direction, animated: true, completion: {(finished) -> Void in
            self.notifyDelegateOfNewIndex()
        })
    }
    
    fileprivate func notifyDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.index(of: firstViewController){
            helpDelegate?.helpPageViewController(self, didUpdatePageIndex: index)
        }
    }
    
}

extension HelpController: UIPageViewControllerDataSource{
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func  pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
}

extension HelpController: UIPageViewControllerDelegate {
    @objc(pageViewController:didFinishAnimating:previousViewControllers:transitionCompleted:) func pageViewController(_ pageViewController: UIPageViewController,
                                                                                                                      didFinishAnimating finished: Bool,
                                                                                                                      previousViewControllers previousView: [UIViewController],
                            transitionCompleted completed: Bool){
        notifyDelegateOfNewIndex()
    }
}

protocol HelpViewControllerDelegate: class {
    
    /**
     Called when the number of pages is updated.
     
     - parameter helpPageViewController: the HelpController instance
     - parameter count: the total number of pages.
     */
    func helpPageViewController(_ helpPageViewController: HelpController,
                                didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter elpPageViewController: the HelpController instance
     - parameter index: the index of the currently visible page.
     */
    func helpPageViewController(_ helpPageViewController: HelpController,
                                didUpdatePageIndex index: Int)
    
}
