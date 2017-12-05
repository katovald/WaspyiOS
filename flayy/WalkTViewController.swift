//
//  WalkTViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 11/28/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class WalkTViewController: UIPageViewController {

    weak var walkDelegate: WalkTViewControllerDelegate?
    
    var menuActionDelegate: MenuActionDelegate? = nil
    
    fileprivate(set) lazy var orderViewControllers: [UIViewController] = {
        return [self.WalkViewController("1"),
                self.WalkViewController("2"),
                self.WalkViewController("3"),
                self.WalkViewController("4")]
    }()
    
    fileprivate func WalkViewController(_ page: String) -> UIViewController{
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WT\(page)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self
        
        if let primeraPagina = orderViewControllers.first{
            scrollToView(primeraPagina)
        }
        
        walkDelegate?.wtPageViewController(self, didUpdatePageCount: orderViewControllers.count)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollToNext() {
        if let visibleController = viewControllers?.first,
            let nextView = pageViewController(self, viewControllerAfter: visibleController) {
            scrollToView(nextView)
        }
    }
    
    func scrollToView(index newIndex: Int){
        if let firstController = viewControllers?.first,
            let currentIndex = orderViewControllers.index(of: firstController) {
            let direction: UIPageViewControllerNavigationDirection = newIndex >= currentIndex ? .forward : .reverse
            let nextView = orderViewControllers[newIndex]
            scrollToView(nextView, direction: direction)
        }
    }
    
    fileprivate func scrollToView(_ viewController: UIViewController, direction: UIPageViewControllerNavigationDirection = .forward){
        setViewControllers([viewController], direction: direction, animated: true) { (finished) -> Void in
            self.notifyDelegateOfNewIndex()
        }
    }

    fileprivate func notifyDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first,
            let index = orderViewControllers.index(of: firstViewController){
            walkDelegate?.wtPageViewController(self, didUpdatePageIndex: index)
        }
    }/*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func exitWT(){
        self.dismiss(animated: true, completion: nil)
    }

}

extension WalkTViewController: UIPageViewControllerDataSource{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return orderViewControllers.last
        }
        
        guard orderViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderViewControllers[previousIndex]
    }
    
    func  pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return orderViewControllers.first
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderViewControllers[nextIndex]
    }
}

extension WalkTViewController: UIPageViewControllerDelegate{
    @objc(pageViewController:didFinishAnimating:previousViewControllers:transitionCompleted:) func pageViewController(_ pageViewController: UIPageViewController,
                                                                                                                      didFinishAnimating finished: Bool,
                                                                                                                      previousViewControllers previousView: [UIViewController],
                                                                                                                      transitionCompleted completed: Bool){
        notifyDelegateOfNewIndex()
    }
}

protocol WalkTViewControllerDelegate: class {
    
    /**
     Called when the number of pages is updated.
     
     - parameter helpPageViewController: the HelpController instance
     - parameter count: the total number of pages.
     */
    func wtPageViewController(_ helpPageViewController: WalkTViewController,
                                didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter elpPageViewController: the HelpController instance
     - parameter index: the index of the currently visible page.
     */
    func wtPageViewController(_ helpPageViewController: WalkTViewController,
                                didUpdatePageIndex index: Int)
    
    func exitWT()
    
}
